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
        //memfilename = {"../riscvtest/xor-test.memfile"};
        //memfilename = {"../testing/xor.memfile"};
        //memfilename = {"../testing/bne.memfile"};
        //memfilename = {"../riscvtest/bne-test.memfile"};
        memfilename = {"../testing/lui.memfile"};
        $readmemh(memfilename, dut.imem.RAM);
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

module riscvsingle (input  logic        clk, reset,
		    output logic [31:0] PC,
		    input  logic [31:0] Instr,
		    output logic 	MemWrite,
		    output logic [31:0] ALUResult, WriteData,
		    input  logic [31:0] ReadData);
   
   logic 				      ALUSrc, RegWrite, Jump, Zero;
   logic [1:0] 				ResultSrc; 
   logic [2:0]        ImmSrc;
   logic [3:0] 				ALUControl;
   logic              ALUSrcA, ALUSrcB;
   
   controller c (Instr[6:0], Instr[14:12], Instr[30], Zero, Carry, Neg, Overflow,
		 ResultSrc, MemWrite, PCSrc,
		 ALUSrcA, ALUSrcB, RegWrite, Jump,
		 ImmSrc, ALUControl);
   datapath dp (clk, reset, ResultSrc, PCSrc,
		ALUSrcA, ALUSrcB, RegWrite,
		ImmSrc, ALUControl,
		Zero, Carry, Neg, Overflow, PC, Instr,
		ALUResult, WriteData, ReadData);
   
endmodule // riscvsingle

module controller (input  logic [6:0] op,
		   input  logic [2:0] funct3,
		   input  logic       funct7b5,
		   input  logic       Zero, Carry, Neg, Overflow,
		   output logic [1:0] ResultSrc,
		   output logic       MemWrite,
		   output logic       PCSrc, ALUSrcA, ALUSrcB,
		   output logic       RegWrite, Jump,
		   output logic [2:0] ImmSrc,
		   output logic [3:0] ALUControl);
   
   logic [1:0] 			      ALUOp;
   logic 			      Branch;
   logic            BranchControl;
   
   maindec md (op, ResultSrc, MemWrite, Branch,
	       ALUSrcA, ALUSrcB, RegWrite, Jump, ImmSrc, ALUOp);
   aludec ad (op[5], funct3, funct7b5, ALUOp, ALUControl);
   always_comb begin
      case(funct3)
        3'b000:   BranchControl = Zero;    //beq
        3'b001:   BranchControl = ~Zero;    //bne
        3'b100:   BranchControl = Neg ^ Overflow;    //blt  
        3'b101:   BranchControl = ~(Neg ^ Overflow);    //bge
        3'b110:   BranchControl = Zero | ~Carry;   //bltu
        3'b111:   BranchControl = Carry;  //bgeu
        default:  BranchControl = 1'b0;
      endcase
   end
   //assign Branch = Zero ^ funct3; 
   assign PCSrc = (Branch & BranchControl) /*(Zero ^ funct3[0])*/ | Jump;

endmodule // controller

module maindec (input  logic [6:0] op,
		output logic [1:0] ResultSrc,
		output logic 	   MemWrite,
		output logic 	   Branch, ALUSrcA, ALUSrcB,
		output logic 	   RegWrite, Jump,
		output logic [2:0] ImmSrc,
		output logic [1:0] ALUOp);
   
   logic [12:0] 		   controls;
   
   assign {RegWrite, ImmSrc, ALUSrcA, ALUSrcB, MemWrite,
	   ResultSrc, Branch, ALUOp, Jump} = controls;
   
   always_comb
     case(op)
       // RegWrite_ImmSrc_ALUSrcA_ALUSrcB_MemWrite_ResultSrc_Branch_ALUOp_Jump
       7'b0000011: controls = 13'b1_000_0_1_0_01_0_00_0; // lw
       7'b0100011: controls = 13'b0_001_0_1_1_xx_0_00_0; // sw
       7'b0110011: controls = 13'b1_xxx_0_0_0_00_0_10_0; // R–type
       7'b1100011: controls = 13'b0_010_0_0_0_xx_1_01_0; // beq & bne
       7'b0110111: controls = 13'b1_100_1_1_0_00_0_xx_0; // LUI
       7'b0010011: controls = 13'b1_000_0_0_0_00_0_10_0; // I–type ALU
       7'b1101111: controls = 13'b1_011_x_x_0_10_0_xx_1; // jal
       7'b0010111: controls = 13'b1_100_0_1_0_00_0_10_0; // AUIPC
       default: controls = 12'bx_xxx_x_x_xx_x_xx_x;    // ???
     endcase // case (op)
   
endmodule // maindec

module aludec (input  logic       opb5,
	       input  logic [2:0] funct3,
	       input  logic 	  funct7b5,
	       input  logic [1:0] ALUOp,
	       output logic [3:0] ALUControl);
   
   logic 			  RtypeSub;
   
   assign RtypeSub = funct7b5 & opb5;  // TRUE for R–type subtract
   
   always_comb
     case(ALUOp)
       2'b00: ALUControl = 4'b0000;    // addition
       2'b01: ALUControl = 4'b0001;    // subtraction
       default: case(funct3)           // R–type or I–type ALU
		    3'b000: if (RtypeSub)
		      ALUControl = 4'b0001;        // sub
		    else
		      ALUControl = 4'b0000;        // add, addi
		    3'b111: ALUControl = 4'b0010;  // and, andi
		    3'b110: ALUControl = 4'b0011;  // or, ori
        3'b100: ALUControl = 4'b0100;  // xor, xori
		    3'b010: ALUControl = 4'b0101;  // slt, slti
        3'b001: ALUControl = 4'b0110;  // sll, slli
        3'b011: ALUControl = 4'b0111;  //sltu, sltui
        3'b101: if(funct7b5) 
          ALUControl = 4'b1000;  //sra, srai
        else
          ALUControl = 4'b1001;  //srl, srli
		  default: ALUControl = 4'bxxxx;   // ???
		endcase // case (funct3)       
     endcase // case (ALUOp)
   
endmodule // aludec

module datapath (input  logic        clk, reset,
		 input  logic [1:0]  ResultSrc,
		 input  logic 	     PCSrc, ALUSrcA, ALUSrcB,
		 input  logic 	     RegWrite,
		 input  logic [2:0]  ImmSrc,
		 input  logic [3:0]  ALUControl,
		 output logic 	     Zero, Carry, Neg, Overflow,
		 output logic [31:0] PC,
		 input  logic [31:0] Instr,
		 output logic [31:0] ALUResult, WriteData,
		 input  logic [31:0] ReadData);
   
   logic [31:0] 		     PCNext, PCPlus4, PCTarget;
   logic [31:0] 		     ImmExt;
   logic [31:0] 		     SrcA, SrcB;
   logic [31:0] 		     SrcA0;
   logic [31:0] 		     Result;
   
   // next PC logic
   flopr #(32) pcreg (clk, reset, PCNext, PC);
   adder  pcadd4 (PC, 32'd4, PCPlus4);
   adder  pcaddbranch (PC, ImmExt, PCTarget);
   mux2 #(32)  pcmux (PCPlus4, PCTarget, PCSrc, PCNext);
   // register file logic
   regfile  rf (clk, RegWrite, Instr[19:15], Instr[24:20],
	       Instr[11:7], Result, SrcA0, WriteData);
   extend  ext (Instr[31:7], ImmSrc, ImmExt);
   // ALU logic
   mux2 #(32)  srcamux (SrcA0, 32'h0, ALUSrcA, SrcA);
   mux2 #(32)  srcbmux (WriteData, ImmExt, ALUSrcB, SrcB);
   alu  alu (SrcA, SrcB, ALUControl, ALUResult, Zero, Carry, Neg, Overflow);
   mux4 #(32) resultmux (ALUResult, ReadData, PCPlus4, ImmExt, ResultSrc, Result);
endmodule // datapath

module adder (input  logic [31:0] a, b,
	      output logic [31:0] y);
   
   assign y = a + b;
   
endmodule

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
       // U-type
       3'b100:  immext = {instr[31:12], 12'b0};
       default: immext = 32'bx; // undefined
     endcase // case (immsrc)
   
endmodule // extend

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

module mux4 #(parameter WIDTH = 8)
   (input  logic [WIDTH-1:0] d0, d1, d2, d3,
    input logic [1:0] 	     s,
    output logic [WIDTH-1:0] y);
   
  assign y = s[1] ? (s[0] ? d3 : d2) : (s[0] ? d1 : d0);

endmodule // mux4

module top (input  logic        clk, reset,
	    output logic [31:0] WriteData, DataAdr,
	    output logic 	MemWrite);
   
   logic [31:0] 		PC, Instr, ReadData;
   
   // instantiate processor and memories
   riscvsingle rv32single (clk, reset, PC, Instr, MemWrite, DataAdr,
			   WriteData, ReadData);
   imem imem (PC, Instr);
   dmem dmem (clk, MemWrite, DataAdr, WriteData, ReadData);
   
endmodule // top

module imem (input  logic [31:0] a,
	     output logic [31:0] rd);
   
   logic [31:0] 		 RAM[1023:0];
   
   assign rd = RAM[a[31:2]]; // word aligned
   
endmodule // imem

module dmem (input  logic        clk, we,
	     input  logic [31:0] a, wd,
	     output logic [31:0] rd);
   
   logic [31:0] 		 RAM[255:0];
   
   assign rd = RAM[a[31:2]]; // word aligned
   always_ff @(posedge clk)
     if (we) RAM[a[31:2]] <= wd;
   
endmodule // dmem

module alu (input  logic [31:0] a, b,
            input  logic [3:0] 	alucontrol,
            output logic [31:0] result,
            output logic 	zero, carry, neg, overflow);

   logic [31:0] 	 condinvb, sum;
   logic 		       v;              // overflow
   logic 		       isAddSub;       // true when is add or subtract operation

   assign condinvb = alucontrol[0] ? ~b : b;
   assign sum = a + condinvb + alucontrol[0];
   assign isAddSub = ~alucontrol[2] & ~alucontrol[1] |
                     ~alucontrol[1] & alucontrol[0];   

   always_comb
     case (alucontrol)
       4'b0000:  result = sum;            // add
       4'b0001:  result = sum;            // subtract
       4'b0010:  result = a & b;          // and
       4'b0011:  result = a | b;          // or
       4'b0100:  result = a ^ b;          //xor
       4'b0101:  result = sum[31] ^ v;    // slt  
       4'b0110:  result = a << b[4:0];    // sll
       4'b0111:  result = a < b;          //sltu
       4'b1000:  result = a >>> b[4:0];   // sra
       4'b1001:  result = a >> b[4:0];    // srl
       default: result = 32'bx;
     endcase

   assign zero = (result == 32'b0);
   assign carry = a < b;
   assign neg = result[31];
   //assign overflow = ~(alucontrol[0] ^ a[31] ^ b[31]) & (a[31] ^ sum[31]) & isAddSub;
   assign v = ~(alucontrol[0] ^ a[31] ^ b[31]) & (a[31] ^ sum[31]) & isAddSub;
   assign overflow = v;
   
endmodule // alu

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
