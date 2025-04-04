// riscvsingle.sv

// RISC-V single-cycle processor
// From Section 7.6 of Digital Design & Computer Architecture
// 27 April 2020
// David_Harris@hmc.edu 
// Sarah.Harris@unlv.edu

// run 210
// Expect simulator to print "Simulation succeeded"
// when the value 25 (0x19) is written to address 100 (0x64)

//   Instruction  opcode    funct3    funct7
//   add          0110011   000       0000000
//   sub          0110011   000       0100000
//   and          0110011   111       0000000
//   or           0110011   110       0000000
//   slt          0110011   010       0000000
//   addi         0010011   000       immediate
//   andi         0010011   111       immediate
//   ori          0010011   110       immediate
//   slti         0010011   010       immediate
//   beq          1100011   000       immediate
//   lw	          0000011   010       immediate
//   sw           0100011   010       immediate
//   jal          1101111   immediate immediate

module testbench();

   logic        clk;
   logic        reset;

   logic [31:0] WriteData;
   logic [31:0] DataAdr;
   logic        MemWrite;

   // instantiate device to be tested
    top dut(clk, reset, WriteData, DataAdr, MemWrite);

   initial
     begin
	string memfilename;
      // memfilename = {"riscvtest/riscvtest.memfile"};
	    // memfilename = {"riscvtest/fib.memfile"};
      //memfilename = {"riscvtest/test_hw2.memfile"};

      // memfilename = {"testing/bge.memfile"};
      // memfilename = {"testing/bgeu.memfile"};
      // memfilename = {"testing/blt.memfile"};
      // memfilename = {"testing/bltu.memfile"};
      // memfilename = {"testing/auipc.memfile"};
      // memfilename = {"testing/bne.memfile"};
      // memfilename = {"testing/jalr.memfile"};
      // memfilename = {"testing/lb.memfile"};
      // memfilename = {"testing/lbu.memfile"};
      // memfilename = {"testing/lh.memfile"};
      // memfilename = {"testing/lhu.memfile"};
      // memfilename = {"testing/lui.memfile"};
      // memfilename = {"testing/sb.memfile"};
      // memfilename = {"testing/sh.memfile"};
      // memfilename = {"testing/sll.memfile"};
      // memfilename = {"testing/slli.memfile"};
      // memfilename = {"testing/sltiu.memfile"};
      // memfilename = {"testing/sltu.memfile"};
      // memfilename = {"testing/sra.memfile"};
      // memfilename = {"testing/srai.memfile"};
      // memfilename = {"testing/srl.memfile"};
      // memfilename = {"testing/srli.memfile"};
      // memfilename = {"testing/xor.memfile"};
      // memfilename = {"testing/xori.memfile"}; 
      
		
		
        $readmemh(memfilename, dut.imem.RAM);
		  $readmemh(memfilename, dut.dmem.RAM);
     end

   
   // initialize test
   initial
     begin
	reset <= 1; # 22; reset <= 0;
     end

   // generate clock to sequence tests
   always
     begin
	clk <= 1; # 5; clk <= 0; # 5;
     end

   // check results
   always @(negedge clk)
     begin
		if(MemWrite) begin
			   if(DataAdr === 100 & WriteData === 25) begin
				  $display("Simulation succeeded");
				  $stop;
			   end else if (DataAdr !== 96) begin
				  $display("Simulation failed");
				  $stop;
			   end
		end
     end
endmodule // testbench


// ==========================================================================================
//	riscvsingle		riscvsingle		riscvsingle		riscvsingle		riscvsingle		

module riscvsingle (input  logic  		clk, reset, 
				    output logic [31:0] PC,
		            input  logic [31:0] Instr,
		            output logic 		MemWrite,
					output logic [31:0] ALUResult, WriteData,
					input  logic [31:0] ReadData);
   
   logic 			    RegWrite, Jump;
   logic [1:0]          ALUSrc;
   logic				Zero, Neg, Carry, Overflow;
   logic [1:0] 			ResultSrc;
   logic [2:0]          ImmSrc;
   logic [3:0] 		    ALUControl;
   
   controller c (Instr[6:0], Instr[14:12], Instr[30],
				 Zero, Neg, Carry, Overflow,
				 ResultSrc, MemWrite, PCSrc,
				 ALUSrc, RegWrite, Jump,
				 ImmSrc, ALUControl);
		 
   datapath dp (clk, reset, ResultSrc, PCSrc, Jump,
				ALUSrc, RegWrite,
				ImmSrc, ALUControl,
				Zero, Neg, Carry, Overflow,
				PC,  Instr,
				ALUResult, WriteData, ReadData);
   
endmodule // riscvsingle

// ==========================================================================================
//	controller		controller		controller		controller		controller		controller		

module controller (input  logic [6:0] op,
		   input  logic [2:0] 	funct3,
		   input  logic       	funct7b5,
		   input  logic       	Zero, Neg, Carry, Overflow,
		   output logic [1:0] 	ResultSrc,
		   output logic       	MemWrite,
		   output logic       	PCSrc,
		   output  logic [1:0]  ALUSrc,
		   output logic       	RegWrite, Jump,
		   output logic [2:0] 	ImmSrc,
		   output logic [3:0] 	ALUControl);
   
   logic [1:0] 			  ALUOp;
   logic 			      Branch, BranchControl;
   
   maindec md (op, ResultSrc, MemWrite, Branch,
	       ALUSrc, RegWrite, Jump, ImmSrc, ALUOp);
   aludec ad (op[5], funct3, funct7b5, ALUOp, ALUControl);
   
   always_comb
    case (funct3)
        3'b000:  assign BranchControl = Zero;              // beq 
        3'b001:  assign BranchControl = ~Zero;             // bne 
        3'b100:  assign BranchControl = (Neg ^ Overflow);  // blt 
        3'b101:  assign BranchControl = ~(Neg ^ Overflow); // bge 
        3'b110:  assign BranchControl = Carry;            // bltu 
        3'b111:  assign BranchControl = ~Carry;           // bgeu
        default: assign BranchControl = 1'b0;             // Default case (no branch)
    endcase

   assign PCSrc = (Branch & BranchControl)| Jump;
   
endmodule // controller

// ==========================================================================================
//	maindec		maindec		maindec		maindec		maindec		maindec		maindec		

module maindec (input  logic [6:0] op,
		output logic [1:0] ResultSrc,
		output logic 	   MemWrite,
		output logic 	   Branch,
		output logic [1:0]  ALUSrc,
		output logic 	   RegWrite, Jump,
		output logic [2:0] ImmSrc,
		output logic [1:0] ALUOp);
   
   logic [12:0] 		   controls;
   
   assign {RegWrite, ImmSrc, ALUSrc, MemWrite,
	   ResultSrc, Branch, ALUOp, Jump} = controls;
   
   always_comb
     case(op)
       // RegWrite_ImmSrc_ALUSrc_MemWrite_ResultSrc_Branch_ALUOp_Jump
       7'b0000011: controls = 13'b1_000_01_0_01_0_00_0; // lw
       7'b0100011: controls = 13'b0_001_01_1_00_0_00_0; // sw
       7'b0110011: controls = 13'b1_xxx_00_0_00_0_10_0; // R–type
       7'b1100011: controls = 13'b0_010_00_0_00_1_01_0; // B-Type
       7'b0010011: controls = 13'b1_000_01_0_00_0_10_0; // I–type ALU
       7'b1101111: controls = 13'b1_011_xx_0_10_0_xx_1; // Jal     
       7'b1100111: controls = 13'b1_000_01_0_10_0_00_1; // jalr    
       7'b0010111: controls = 13'b1_100_11_0_00_0_00_0; // auipc    
       7'b0110111: controls = 13'b1_100_01_0_00_0_11_0; // lui      

       default: controls = 13'bx_xxx_x_x_xx_x_xx_x; // ???
     endcase 

endmodule // maindec

// ==========================================================================================
//	aludec		aludec		aludec		aludec		aludec		aludec		aludec		

module aludec (input  logic     opb5,
	       input  logic [2:0]   funct3,
	       input  logic 	    funct7b5,
	       input  logic [1:0]   ALUOp,
	       output logic [3:0]   ALUControl);
   
   logic 			  RtypeSub;
   
   assign RtypeSub = funct7b5 & opb5; // TRUE for R–type subtract


   always_comb
     case(ALUOp)
       2'b00: ALUControl = 4'b0000; // addition
      //  2'b01: ALUControl = 4'b0001; // subtraction
       2'b01: if (funct3 == 3'b000 || funct3 == 3'b001) 
                  ALUControl = 4'b1011; // subtraction beq/bne
              else if (funct3 == 3'b100 || funct3 == 3'b101) 
                  ALUControl = 4'b1101; // subtraction blt/bge
              else 
                  ALUControl = 4'b1111; // subtraction bltu/bgeu
	   2'b11:   // LUI
			  ALUControl = 4'b1110;
       default: case(funct3) // R–type or I–type ALU
		    3'b000: if (RtypeSub)
		                 ALUControl = 4'b0001; // sub
		            else
		                 ALUControl = 4'b0000; // add, addi
		    3'b010:   if (!RtypeSub) // I type set les than
						  ALUControl = 4'b0101; // slt, slti
					  else
						  if (!funct7b5)
							 ALUControl = 4'b0101; // slt
						  else
							 ALUControl = 4'b1010; // sgt
		    3'b110:   ALUControl = 4'b0011; // or, ori
		    3'b111:   ALUControl = 4'b0010; // and, andi
            3'b100:   ALUControl = 4'b0100; // xor, xori
            3'b101: if (funct7b5)   
                         ALUControl = 4'b0111; // sra, srai
                    else
                         ALUControl = 4'b0110; // srl, srli
            3'b001:   ALUControl = 4'b1000; // sll, slli
            3'b011:   if (!RtypeSub) // I type
						ALUControl = 4'b1001; // sltiu
					  else // R type
						if (!funct7b5)
							ALUControl = 4'b1001; // sltu
						else
							ALUControl = 4'b1100;
		    default:  ALUControl = 4'bxxxx; 
		   endcase        
     endcase 
   
endmodule // aludec

// ==========================================================================================
//	datapath	datapath	datapath	datapath	datapath	datapath	datapath			

module datapath (input  logic        clk, reset,
		 input  logic [1:0]  ResultSrc,
		 input  logic 	     PCSrc, Jump,
	     input  logic [1:0]  ALUSrc,
		 input  logic 	     RegWrite,
		 input  logic [2:0]  ImmSrc,
		 input  logic [3:0]  ALUControl,
		 output logic 	     Zero, Neg, Carry, Overflow,
		 output logic [31:0] PC,
		 input  logic [31:0] Instr,
		 output logic [31:0] ALUResult, WriteData,
		 input  logic [31:0] ReadData);
   
   logic [31:0] 		     PCNext, PCPlus4, PCTarget, PCAdr;
   logic [31:0] 		     ImmExt;
   logic [31:0] 		     SrcA, SrcB, RegOutA;
   logic [31:0] 		     Result;
   
   // next PC logic
   flopenr #(32) pcreg (clk, reset, PCPCNext, PC);
   adder  pcadd4 (PC, 32'd4, PCPlus4);
   adder  pcaddbranch (PC, ImmExt, PCTarget);
   
   // register file logic
   regfile  rf (clk, RegWrite, Instr[19:15], Instr[24:20],
	       Instr[11:7], Result, RegOutA, WriteData);
   extend  ext (Instr[31:7], ImmSrc, ImmExt);
   
   // ALU logic
   mux2 #(32)  srcamux (RegOutA, PC, ALUSrc[1], SrcA);		// mux for A input
   mux2 #(32)  srcbmux (WriteData, ImmExt, ALUSrc[0], SrcB); // mux for B input
   
   alu  alu (SrcA, SrcB, ALUControl, ALUResult, Zero, Neg, Carry, Overflow);
   
   mux3 #(32) resultmux (ALUResult, ReadData, PCPlus4, ResultSrc, Result);
   
   mux2 #(32)  pxAddrMux (PCTarget, ALUResult, (Jump & (ALUSrc === 2'b01)), PCAdr);
   // update PCNext
   mux2 #(32)  pcmux (PCPlus4, PCAdr, PCSrc, PCNext);

endmodule // datapath

// ==========================================================================================
//	adder		adder		adder		adder		adder		adder		adder					

module adder (input  logic [31:0] a, b,
	      output logic [31:0] y);
   
   assign y = a + b;
   
endmodule


// ==========================================================================================
//	extend		extend		extend		extend		extend		extend		extend						



module extend (input  logic [31:7] instr,
	       input  logic [2:0]  immsrc,
	       output logic [31:0] immext);
   
   always_comb
     case(immsrc)
       // I−type
       3'b000:  immext = {{20{instr[31]}}, instr[31:20]};
       // S−type (stores)
       3'b001:  immext = {{20{instr[31]}}, instr[31:25], instr[11:7]};
       // B−type (branches)
       3'b010:  immext = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};       
       // J−type (jal)
       3'b011:  immext = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
       // U−type (lui, auipc)
       3'b100: immext = {instr[31:12], 12'b0};
       default: immext = 32'bx; // undefined
     endcase // case (immsrc)
   
endmodule // extend

// ==========================================================================================
//	flopr		flopr		flopr		flopr		flopr		flopr		flopr						
module flopr #(parameter WIDTH = 8)
   (input  logic             clk, reset,
    input logic [WIDTH-1:0]  d,
    output logic [WIDTH-1:0] q);
   
   always_ff @(posedge clk, posedge reset)
     if (reset) q <= 0;
     else  q <= d;
   
endmodule // flopr


module flopenr #(parameter WIDTH = 8)
   (input  logic             clk, reset, en,
    input logic [WIDTH-1:0]  d,
    output logic [WIDTH-1:0] q);
   
   always_ff @(posedge clk, posedge reset)
     if (reset)  q <= 0;
     else if (en) q <= d;
   
endmodule // flopenr

// ==========================================================================================
//	mux			mux			mux			mux			mux			mux			mux			mux							

module mux2 #(parameter WIDTH = 8)
   (input  logic [WIDTH-1:0] d0, d1,
    input logic 	     s,
    output logic [WIDTH-1:0] y);
   
  assign y = s ? d1 : d0;
   
endmodule // mux2



module mux3 #(parameter WIDTH = 8)
   (input  logic [WIDTH-1:0] d0, d1, d2,
    input logic [1:0] 	     s,
    output logic [WIDTH-1:0] y);
   
  assign y = s[1] ? d2 : (s[0] ? d1 : d0);
   
endmodule // mux3

 // ==========================================================================================
 // top top   top top   top top   top top   top top   top top
module top (input  logic        clk, reset,
	    output logic [31:0] WriteData, DataAdr,
	    output logic 	MemWrite);
   
   logic [31:0] 		PC, Instr, ReadData;
   
   // instantiate processor and memories
   riscvsingle rv32single (clk, reset, PC, Instr, MemWrite, DataAdr,
			   WriteData, ReadData);
   imem imem (PC, Instr);
   dmem dmem (clk, MemWrite, DataAdr, WriteData, funct3, ReadData);
   
endmodule // top

// ==========================================================================================
//	memory		memory		memory		memory		memory		memory		memory									

module imem (input  logic [31:0] a,
	     output logic [31:0] rd);
   
   logic [31:0] 		 RAM[2047:0];
   
   assign rd = RAM[a[31:2]]; // word aligned
   
endmodule // imem


module dmem (input  logic        clk, we,
	     input  logic [31:0] a, wd,
		 input  logic [2:0]  funct3,
	     output logic [31:0] rd);
   
   logic [31:0] 		 RAM[2047:0];
   logic [31:0] 		 mask, extend_mask, data;
   
   logic [1:0] alignment;
   logic signBit;
   
   assign alignment = a[1:0];
   assign data      = RAM[a[31:2]];
   assign signBit   = data[8 * alignment + ((funct3 == 3'b001) ? 15 : ((funct3 == 3'b000) ? 7 : 31))];
   
   always_comb
	case(funct3)
		3'b010:  assign mask = 32'hFFFFFFFF; // lw
		3'b000:  assign mask = 32'h000000FF << (8 * alignment); // lB
		3'b100:  assign mask = 32'h000000FF << (8 * alignment); // load unsigned byte
		3'b001:  assign mask = 32'h0000FFFF << (8 * alignment); // load half
		3'b101:  assign mask = 32'h0000FFFF << (8 * alignment); // load unsigned half
		default: assign mask = 32'hFFFFFFFF;
	endcase
	
   always_comb
	case(funct3)
		3'b000: assign extend_mask = {{24{signBit}}, {8'h00}};
		3'b001: assign extend_mask = {{16{signBit}}, {16'h0000}};
		default: assign extend_mask = 32'h00000000;
	endcase
   
   assign rd = ((data & mask) >> (8 * alignment)) | extend_mask; 
   
   always_ff @(posedge clk)
     if (we) RAM[a[31:2]] <= ((wd << (8 * alignment)) & mask) | (data & (~mask));
   
endmodule // dmem

// ==========================================================================================
//	ALU		ALU		ALU		ALU		ALU		ALU		ALU		ALU		ALU		ALU		ALU											

module alu (input  logic [31:0] a, b,
            input  logic [3:0] 	alucontrol,
            output logic [31:0] result,
            output logic 	zero, Neg, carry, overflow);

   logic [31:0] 	       condinvb, sum, xorOut, sltuOut;
   logic [32:0]			   carried;
   logic 		       Cout;
   logic 		       isAddSub;       // true when is add or subtract operation


   assign condinvb = alucontrol[0] ? ~b : b;
   assign sum = a + condinvb + alucontrol[0];
   assign isAddSub = ~alucontrol[2] & ~alucontrol[1] |
                     ~alucontrol[1] & alucontrol[0];   
   assign xorOut = a ^ b;
   assign sltuOut = unsigned'(a) < unsigned'(b);

   always_comb
     case (alucontrol)
       4'b0000:  result = sum;         // add
       4'b0001:  result = sum;         // subtract
       4'b0010:  result = a & b;       // and
       4'b0011:  result = a | b;       // or
       4'b0101:  result = sum[31] ^ overflow; // slt 
       4'b0110:  result = a >> unsigned'(b[4:0]);      // srl  
       4'b0111:  result = $signed(a) >>> unsigned'(b[4:0]);     // sra
       4'b0100:  result = xorOut;      // xor  
       4'b1000:  result = a << unsigned'(b[4:0]);      // sll
       4'b1001:  result = sltuOut;     // sltu
       4'b1011:  result = sum;         // beq, bne
       4'b1101:  result = sum;         // blt, bge
       4'b1111:  result = sum;         // bltu, bgeu
	   4'b1110:  result = b;		   // LUI
	   4'b1010:  result = ~(sum[31] ^ overflow); // sgt
	   4'b1100:  result = ~sltuOut;    // sgtu
       default:  result = 32'bx;
     endcase
   assign overflow = ~(alucontrol[0] ^ a[31] ^ b[31]) & (a[31] ^ sum[31]) & isAddSub;
   assign Neg = sum[31];
   assign carried = a - b;
   assign carry = carried[32];
   // zero
   assign zero = (result == 32'b0);

   
endmodule // alu

// ==========================================================================================
//	Regfile		Regfile		Regfile		Regfile		Regfile		Regfile		Regfile													

module regfile (input  logic        clk, 
		input  logic 	    we3, 
		input  logic [4:0]  a1, a2, a3, 
		input  logic [31:0] wd3, 
		output logic [31:0] rd1, rd2);

   logic [31:0] 		    rf[31:0];

   // three ported register file
   // read two ports combinationally (A1/RD1, A2/RD2)
   // write third port on rising edge of clock (A3/WD3/WE3)
   // register 0 hardwired to 0

   always_ff @(posedge clk)
     if (we3) rf[a3] <= wd3;	

   assign rd1 = (a1 != 0) ? rf[a1] : 0;
   assign rd2 = (a2 != 0) ? rf[a2] : 0;
   
endmodule // regfile
