// riscvpipelined.sv

// RISC-V pipelined processor
// From Section 7.6 of Digital Design & Computer Architecture: RISC-V Edition
// 27 April 2020
// David_Harris@hmc.edu 
// Sarah.Harris@unlv.edu

// run 210
// Expect simulator to print "Simulation succeeded"
// when the value 25 (0x19) is written to address 100 (0x64)

// Pipelined implementation of RISC-V (RV32I)
// User-level Instruction Set Architecture V2.2 (May 7, 2017)
// Implements a subset of the base integer instructions:
//    lw, sw
//    add, sub, and, or, slt, 
//    addi, andi, ori, slti
//    beq
//    jal
// Exceptions, traps, and interrupts not implemented
// little-endian memory

// 31 32-bit registers x1-x31, x0 hardwired to 0
// R-Type instructions
//   add, sub, and, or, slt
//   INSTR rd, rs1, rs2
//   Instr[31:25] = funct7 (funct7b5 & opb5 = 1 for sub, 0 for others)
//   Instr[24:20] = rs2
//   Instr[19:15] = rs1
//   Instr[14:12] = funct3
//   Instr[11:7]  = rd
//   Instr[6:0]   = opcode
// I-Type Instructions
//   lw, I-type ALU (addi, andi, ori, slti)
//   lw:         INSTR rd, imm(rs1)
//   I-type ALU: INSTR rd, rs1, imm (12-bit signed)
//   Instr[31:20] = imm[11:0]
//   Instr[24:20] = rs2
//   Instr[19:15] = rs1
//   Instr[14:12] = funct3
//   Instr[11:7]  = rd
//   Instr[6:0]   = opcode
// S-Type Instruction
//   sw rs2, imm(rs1) (store rs2 into address specified by rs1 + immm)
//   Instr[31:25] = imm[11:5] (offset[11:5])
//   Instr[24:20] = rs2 (src)
//   Instr[19:15] = rs1 (base)
//   Instr[14:12] = funct3
//   Instr[11:7]  = imm[4:0]  (offset[4:0])
//   Instr[6:0]   = opcode
// B-Type Instruction
//   beq rs1, rs2, imm (PCTarget = PC + (signed imm x 2))
//   Instr[31:25] = imm[12], imm[10:5]
//   Instr[24:20] = rs2
//   Instr[19:15] = rs1
//   Instr[14:12] = funct3
//   Instr[11:7]  = imm[4:1], imm[11]
//   Instr[6:0]   = opcode
// J-Type Instruction
//   jal rd, imm  (signed imm is multiplied by 2 and added to PC, rd = PC+4)
//   Instr[31:12] = imm[20], imm[10:1], imm[11], imm[19:12]
//   Instr[11:7]  = rd
//   Instr[6:0]   = opcode

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

   logic [31:0] WriteData, DataAdr;
   logic        MemWrite;

   // instantiate device to be tested
   top dut(clk, reset, WriteData, DataAdr, MemWrite);

   initial
     begin
	string memfilename;
    // memfilename = {"riscvtest/riscvtest.memfile"};
		// memfilename = {"riscvtest/fib.memfile"};
		// memfilename = {"riscvtest/bne-test.memfile"};
		
		
        // memfilename = {"testing/add.memfile"};   
        // memfilename = {"testing/addi.memfile"};   
        // memfilename = {"testing/and.memfile"};	 
        // memfilename = {"testing/andi.memfile"};	 
        // memfilename = {"testing/auipc.memfile"};	 
        // memfilename = {"testing/beq.memfile"};	 
        // memfilename = {"testing/bge.memfile"};	 
        // memfilename = {"testing/bgeu.memfile"};	 
        // memfilename = {"testing/blt.memfile"};	
        // memfilename = {"testing/bltu.memfile"};	
        // memfilename = {"testing/bne.memfile"};	 
        // memfilename = {"testing/jal.memfile"};	 
        // memfilename = {"testing/jalr.memfile"};   
        // memfilename = {"testing/lb.memfile"};	 
        // memfilename = {"testing/lbu.memfile"};	 
        // memfilename = {"testing/lh.memfile"};	 
        // memfilename = {"testing/lhu.memfile"};    
        // memfilename = {"testing/lui.memfile"};    
        // memfilename = {"testing/lw.memfile"};     
        // memfilename = {"testing/or.memfile"};	 
        // memfilename = {"testing/ori.memfile"};	 
        // memfilename = {"testing/sb.memfile"};	 
        // memfilename = {"testing/sh.memfile"};	 
        // memfilename = {"testing/sll.memfile"};	 
        // memfilename = {"testing/slli.memfile"};	 
        // memfilename = {"testing/slt.memfile"};	 
        // memfilename = {"testing/slti.memfile"};   
        // memfilename = {"testing/sltiu.memfile"};  
        // memfilename = {"testing/sltu.memfile"};	 
        // memfilename = {"testing/sra.memfile"};	
        // memfilename = {"testing/srai.memfile"};   
        // memfilename = {"testing/srl.memfile"};	 
        // memfilename = {"testing/srli.memfile"};	 
        // memfilename = {"testing/sub.memfile"};	 
        // memfilename = {"testing/sw.memfile"};	 
        // memfilename = {"testing/xor.memfile"};	 
        // memfilename = {"testing/xori.memfile"};	 
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
endmodule

//========================================================
// TOP

module top(input  logic        clk, reset, 
           output logic [31:0] WriteDataM, DataAdrM, 
           output logic        MemWriteM);

   logic [31:0] 	       PCF, InstrF, ReadDataM;
   logic [2:0]           funct3M; //added
   
   // instantiate processor and memories
   riscv rv32pipe (clk, reset, PCF, InstrF, MemWriteM, DataAdrM, 
		   WriteDataM, ReadDataM, funct3M);
   imem imem (PCF, InstrF);
   dmem dmem (clk, MemWriteM, DataAdrM, WriteDataM, funct3M, ReadDataM);
   
endmodule
//========================================================
// RISCV
module riscv(input  logic        clk, reset,
             output logic [31:0] PCF,
             input logic [31:0]  InstrF,
             output logic 	     MemWriteM,
             output logic [31:0] ALUResultM, WriteDataM,
             input logic [31:0]  ReadDataM
             output logic [2:0]  funct3M);

   logic [6:0] 			 opD;
   logic [2:0] 			 funct3D;
   logic 			       funct7b5D;
   logic [1:0] 			 ImmSrcD;
   logic 			       ZeroE;
   logic 			       PCSrcE;
   logic [2:0] 			 ALUControlE;
   logic [1:0]       ALUSrcE;
   logic 			       ResultSrcEb0;
   logic 			       RegWriteM;
   logic [1:0] 			 ResultSrcW;
   logic 			       RegWriteW;

   logic [1:0] 			 ForwardAE, ForwardBE;
   logic 			       StallF, StallD, FlushD, FlushE;

   logic [4:0] 			 Rs1D, Rs2D, Rs1E, Rs2E, RdE, RdM, RdW;
   logic             PCTargetSrcE; //Added

   controller c(clk, reset,
		opD, funct3D, funct7b5D, ImmSrcD,
		FlushE, ZeroE, PCSrcE, ALUControlE, ALUSrcE, ResultSrcEb0,
		MemWriteM, RegWriteM, 
		RegWriteW, ResultSrcW, PCTargetSrcE);

   datapath dp(clk, reset,
               StallF, PCF, InstrF,
	             opD, funct3D, funct3M, funct7b5D, StallD, FlushD, ImmSrcD,
	             FlushE, ForwardAE, ForwardBE, PCSrcE, ALUControlE, ALUSrcE, ZeroE,
               MemWriteM, WriteDataM, ALUResultM, ReadDataM,
               RegWriteW, ResultSrcW,
               Rs1D, Rs2D, Rs1E, Rs2E, RdE, RdM, RdW, PCTargetSrcE);

   hazard  hu(Rs1D, Rs2D, Rs1E, Rs2E, RdE, RdM, RdW,
              PCSrcE, ResultSrcEb0, RegWriteM, RegWriteW,
              ForwardAE, ForwardBE, StallF, StallD, FlushD, FlushE);			 
endmodule

// =====================================================================================
// CONTROLLER

module controller(input  logic		 clk, reset,
                  // Decode stage control signals
                  input logic [6:0]  opD,
                  input logic [2:0]  funct3D,
                  input logic 	     funct7b5D,
                  output logic [2:0] ImmSrcD,
                  // Execute stage control signals
                  input logic 	     FlushE, 
                  input logic 	     ZeroE, NegativeE, v, CarryE,
                  output logic 	     PCSrcE, // for datapath and Hazard Unit
                  output logic [3:0] ALUControlE, 
                  output logic [1:0] ALUSrcE,
                  output logic 	     ResultSrcEb0, // for Hazard Unit
                  // Memory stage control signals
                  output logic 	     MemWriteM,
                  output logic 	     RegWriteM, // for Hazard Unit	
                  output logic [2:0] funct3M,			  
                  // Writeback stage control signals
                  output logic 	     RegWriteW, // for datapath and Hazard Unit
                  output logic [1:0] ResultSrcW);

   // pipelined control signals
   logic 			     RegWriteD, RegWriteE;
   logic [1:0] 			     ResultSrcD, ResultSrcE, ResultSrcM;
   logic 			     MemWriteD, MemWriteE;
   logic 			     JumpD, JumpE;
   logic 			     BranchD, BranchE;
   logic            BranchControlE;
   logic [1:0] 			     ALUOpD;
   logic [3:0] 			     ALUControlD;
   logic [1:0]      ALUSrcD;
   logic [2:0]      funct3E;
   
   // Decode stage logic
   maindec md(opD, ResultSrcD, MemWriteD, BranchD,
              ALUSrcD, RegWriteD, JumpD, ImmSrcD, ALUOpD);
   aludec  ad(opD[5], funct3D, funct7b5D, ALUOpD, ALUControlD);
   
   // Execute stage pipeline control register and logic
   floprc #(15) controlregE(clk, reset, FlushE,
                            {RegWriteD, ResultSrcD, MemWriteD, JumpD, BranchD, ALUControlD, ALUSrcD, funct3D},
                            {RegWriteE, ResultSrcE, MemWriteE, JumpE, BranchE, ALUControlE, ALUSrcE, funct3E});

     always_comb
    case(funct3E)
    3'b000: BranchControlE = ZeroE;                     //beq
    3'b001: BranchControlE = ~ZeroE;                    //bne
    3'b100: BranchControlE = NegativeE ^ v;     //blt
    3'b101: BranchControlE = ~(NegativeE ^ v);  //bge
    3'b110: BranchControlE = CarryE;                    //bltu
    3'b111: BranchControlE = ~CarryE;                   //bgeu
    default: BranchControlE = 1'b0;
    endcase

   assign PCSrcE = (BranchE & BranchControlE) | JumpE;
   assign ResultSrcEb0 = ResultSrcE[0];
   
   // Memory stage pipeline control register
   flopr #(7) controlregM(clk, reset,
                          {RegWriteE, ResultSrcE, MemWriteE, funct3E},
                          {RegWriteM, ResultSrcM, MemWriteM, funct3M});
   
   // Writeback stage pipeline control register
   flopr #(3) controlregW(clk, reset,
                          {RegWriteM, ResultSrcM},
                          {RegWriteW, ResultSrcW});     
endmodule

//==========================================================================
// MAINDEC

module maindec(input  logic [6:0] op,
               output logic [1:0] ResultSrc,
               output logic 	    MemWrite,
               output logic 	    Branch, 
               output logic [1:0] ALUSrc,
               output logic 	    RegWrite, Jump,
               output logic [1:0] ImmSrc,
               output logic [1:0] ALUOp,
               output logic       PCTargetSrc);

   logic [12:0] 		  controls;

   assign {RegWrite, ImmSrc, ALUSrc, MemWrite,
           ResultSrc, Branch, ALUOp, Jump, PCTargetSrc} = controls;

   always_comb
     case(op)
       // RegWrite_ImmSrc_ALUSrc_MemWrite_ResultSrc_Branch_ALUOp_Jump
        7'b0000011: controls = 13'b1_000_01_0_01_0_00_0; // lw
        7'b0100011: controls = 13'b0_001_01_1_00_0_00_0; // sw
        7'b0110011: controls = 13'b1_xxx_00_0_00_0_10_0; // R–type
        7'b1100011: controls = 13'b0_010_00_0_00_1_01_0; // B-type
        7'b0010011: controls = 13'b1_000_01_0_00_0_10_0; // I–type ALU
        7'b1101111: controls = 13'b1_011_00_0_10_0_00_1; // jal
        7'b1100111: controls = 13'b1_000_01_0_10_0_00_1; // jalr
        7'b0110111: controls = 13'b1_100_01_0_00_0_11_0; // lui
        7'b0010111: controls = 13'b1_100_11_0_00_0_00_0; // auipc
        7'b0000000: controls = 13'b0_000_00_0_00_0_00_0; // need valid values at reset
        default:    controls = 13'bx_xxx_xx_x_xx_x_xx_x; // ???
     endcase
endmodule

// ==========================================================================================
// ALUDEC

module aludec(input  logic       opb5,
              input logic [2:0]  funct3,
              input logic 	     funct7b5, 
              input logic [1:0]  ALUOp,
              output logic [2:0] ALUControl);

   logic 			 RtypeSub;
   assign RtypeSub = funct7b5 & opb5;  // TRUE for R-type subtract instruction

   always_comb
     case(ALUOp)
       2'b00:                ALUControl = 4'b000; // addition
       2'b01:                ALUControl = 4'b001; // subtraction
       2'b11:                ALUControl = 4'b1111 //LUI
       default: case(funct3) // R-type or I-type ALU
                  3'b000:  if (RtypeSub) 
                    ALUControl = 4'b0001; // sub
                  else          
                    ALUControl = 4'b0000; // add, addi
                  3'b010:    ALUControl = 4'b0101; // slt, slti
                  3'b110:    ALUControl = 4'b0011; // or, ori
                  3'b111:    ALUControl = 4'b0010; // and, andi
                                   3'b100:	 ALUControl = 4'b0100; // xor, xori
				                           3'b101:    ALUControl = funct7b5 ? 4'b1000 : 4'b0110; // sra, srai || srl, srli
				                           3'b001:	 ALUControl = 4'b0111; // sll, slli
				                           3'b011:	 ALUControl = 4'b1001; // sltiu sltu
                  default:   ALUControl = 4'bxxxx; // ???
		endcase
     endcase
endmodule

// ========================================================================
// DATAPATH (dp)

module datapath(input logic clk, reset,
                // Fetch stage signals
                input logic 	    StallF,
                output logic [31:0] PCF,
                input logic [31:0]  InstrF,
                // Decode stage signals
                output logic [6:0]  opD,
                output logic [2:0]  funct3D, funct3M, 
                output logic 	      funct7b5D,
                input logic 	      StallD, FlushD,
                input logic [2:0]   ImmSrcD,
                // Execute stage signals
                input logic 	      FlushE,
                input logic [1:0]   ForwardAE, ForwardBE,
                input logic 	      PCSrcE,
                input logic [2:0]   ALUControlE,
                input logic [1:0]   ALUSrcE, //ADDED [1:0]
                output logic 	      ZeroE, NegativeE, v, CarryE,
                // Memory stage signals
                input logic 	      MemWriteM, 
                output logic [31:0] WriteDataM, ALUResultM,
                input logic [31:0]  ReadDataM,
                // Writeback stage signals
                input logic 	    RegWriteW, 
                input logic [1:0]   ResultSrcW,
                // Hazard Unit signals 
                output logic [4:0]  Rs1D, Rs2D, Rs1E, Rs2E,
                output logic [4:0]  RdE, RdM, RdW
                input  logic        PCTargetSrcE); //ADDED

   // Fetch stage signals
   logic [31:0] 		    PCNextF, PCPlus4F;
   // Decode stage signals
   logic [31:0] 		    InstrD;
   logic [31:0] 		    PCD, PCPlus4D;
   logic [31:0] 		    RD1D, RD2D;
   logic [31:0] 		    ImmExtD;
   logic [4:0] 			    RdD;
   // Execute stage signals
   logic [31:0] 		    RD1E, RD2E;
   logic [31:0] 		    PCE, ImmExtE;
   logic [31:0] 		    SrcAE, SrcBE;
   logic [31:0] 		    ALUResultE;
   logic [31:0] 		    WriteDataBE, WriteDataAE;
   logic [31:0] 		    PCPlus4E;
   logic [31:0] 		    PCTargetE;
   logic [31:0]         PCTargetSel; // for jalr
   // funct3
   logic [31:0]         funct3E;
   // Memory stage signals
   logic [31:0] 		    PCPlus4M;
   // Writeback stage signals
   logic [31:0] 		    ALUResultW;
   logic [31:0] 		    ReadDataW;
   logic [31:0] 		    PCPlus4W;
   logic [31:0] 		    ResultW;

   // Fetch stage pipeline register and logic
   mux2    #(32) pcmux(PCPlus4F, PCTargetE, PCSrcE, PCNextF);
   flopenr #(32) pcreg(clk, reset, ~StallF, PCNextF, PCF);
   adder         pcadd(PCF, 32'h4, PCPlus4F);

   // Decode stage pipeline register and logic
   flopenrc #(96) regD(clk, reset, FlushD, ~StallD, 
                       {InstrF, PCF, PCPlus4F},
                       {InstrD, PCD, PCPlus4D});
   assign opD       = InstrD[6:0];
   assign funct3D   = InstrD[14:12];
   assign funct7b5D = InstrD[30];
   assign Rs1D      = InstrD[19:15];
   assign Rs2D      = InstrD[24:20];
   assign RdD       = InstrD[11:7];
   
   regfile        rf(clk, RegWriteW, Rs1D, Rs2D, RdW, ResultW, RD1D, RD2D);
   extend         ext(InstrD[31:7], ImmSrcD, ImmExtD);
   
   // Execute stage pipeline register and logic
   floprc #(178) regE(clk, reset, FlushE, 
                      {RD1D, RD2D, PCD, Rs1D, Rs2D, RdD, ImmExtD, funct3D, PCPlus4D}, 
                      {RD1E, RD2E, PCE, Rs1E, Rs2E, RdE, ImmExtE, funct3E, PCPlus4E});
   
   //mux3   #(32)  faemux(RD1E, ResultW, ALUResultM, ForwardAE, SrcAE);
   mux3	  #(32)  faemux(RD1E, ResultW, ALUResultM, ForwardAE, WriteDataAE);
   mux3   #(32)  fbemux(RD2E, ResultW, ALUResultM, ForwardBE, WriteDataBE);
   
   mux2	  #(32)  srcamux(WriteDataAE, PCE,     ALUSrcE[1], SrcAE); //ADDED ALUSrcE[1]
   mux2   #(32)  srcbmux(WriteDataBE, ImmExtE, ALUSrcE[0], SrcBE); //ADDED mux2 and ALUSrcE[0]
   
   // mux to switch between RS1 and PCE for jalr
   mux2   #(32)  pcTargetmux(PCE, WriteDataAE, PCTargetSrcE, PCTargetSel); 
   
   alu           alu(SrcAE, SrcBE, ALUControlE, funct3E, ALUResultE, ZeroE, NegativeE, v, CarryE);
   adder         branchadd(ImmExtE, PCTargetSel, PCTargetE);

   // Memory stage pipeline register
   flopr  #(104) regM(clk, reset, 
                      {ALUResultE, WriteDataE, RdE, PCPlus4E, funct3E},
                      {ALUResultM, WriteDataM, RdM, PCPlus4M, funct3M});
   
   // Writeback stage pipeline register and logic
   flopr  #(101) regW(clk, reset, 
                      {ALUResultM, ReadDataM, RdM, PCPlus4M},
                      {ALUResultW, ReadDataW, RdW, PCPlus4W});
   mux3   #(32)  resultmux(ALUResultW, ReadDataW, PCPlus4W, ResultSrcW, ResultW);	
endmodule

// ========================================================================
//  HAZARD UNIT

// Hazard Unit: forward, stall, and flush
module hazard(input  logic [4:0] Rs1D, Rs2D, Rs1E, Rs2E, RdE, RdM, RdW,
              input logic 	      PCSrcE, ResultSrcEb0, 
              input logic 	      RegWriteM, RegWriteW,
              output logic [1:0]  ForwardAE, ForwardBE,
              output logic 	      StallF, StallD, FlushD, FlushE);

   logic 			 lwStallD;
   
   // forwarding logic
   always_comb begin
      ForwardAE = 2'b00;
      ForwardBE = 2'b00;
      if (Rs1E != 5'b0)
	      if      ((Rs1E == RdM) & RegWriteM) ForwardAE = 2'b10;
	      else if ((Rs1E == RdW) & RegWriteW) ForwardAE = 2'b01;
      
      if (Rs2E != 5'b0)
	      if      ((Rs2E == RdM) & RegWriteM) ForwardBE = 2'b10;
	      else if ((Rs2E == RdW) & RegWriteW) ForwardBE = 2'b01;
   end
   
   // stalls and flushes
   assign lwStallD = ResultSrcEb0 & ((Rs1D == RdE) | (Rs2D == RdE));  
   assign StallD = lwStallD;
   assign StallF = lwStallD;
   assign FlushD = PCSrcE;
   assign FlushE = lwStallD | PCSrcE;
endmodule

// ========================================================================
//  REGFILE

module regfile(input  logic         clk, 
               input  logic 	      we3, 
               input  logic [ 4:0]  a1, a2, a3, 
               input  logic [31:0]  wd3, 
               output logic [31:0]  rd1, rd2);

   logic [31:0] 		   rf[31:0];

   // three ported register file
   // read two ports combinationally (A1/RD1, A2/RD2)
   // write third port on rising edge of clock (A3/WD3/WE3)
   // write occurs on falling edge of clock
   // register 0 hardwired to 0

   always_ff @(negedge clk)
     if (we3) rf[a3] <= wd3;	

   assign rd1 = (a1 != 0) ? rf[a1] : 0;
   assign rd2 = (a2 != 0) ? rf[a2] : 0;
endmodule

// ========================================================================
//  ADDER

module adder(input  [31:0] a, b,
             output [31:0] y);

   assign y = a + b;
endmodule

// ========================================================================
//  EXTEND (ext)

module extend(input  logic [31:7] instr,
              input logic [2:0]   immsrc,
              output logic [31:0] immext);
   
   always_comb
     case(immsrc) 
       // I-type 
       2'b00:   immext = {{20{instr[31]}}, instr[31:20]};  
       // S-type (stores)
       2'b01:   immext = {{20{instr[31]}}, instr[31:25], instr[11:7]}; 
       // B-type (branches)
       2'b10:   immext = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0}; 
       // J-type (jal)
       2'b11:   immext = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0}; 
       // U-type (lui, auipc)
       3'b100: immext = {instr[31:12], 12'b0};
       default: immext = 32'bx; // undefined
     endcase             
endmodule

// ========================================================================
//  FLOPR (Flip flop)

module flopr #(parameter WIDTH = 8)
   (input  logic             clk, reset,
    input logic [WIDTH-1:0]  d, 
    output logic [WIDTH-1:0] q);

   always_ff @(posedge clk, posedge reset)
     if (reset) q <= 0;
     else       q <= d;
endmodule

// ========================================================================
//  FLOPENR (flip flop w/ enable)

module flopenr #(parameter WIDTH = 8)
   (input  logic             clk, reset, en,
    input logic [WIDTH-1:0]  d, 
    output logic [WIDTH-1:0] q);

   always_ff @(posedge clk, posedge reset)
     if (reset)   q <= 0;
     else if (en) q <= d;
endmodule

// ========================================================================
//  FLOPENRC (flip flop w/ enable and clear)

module flopenrc #(parameter WIDTH = 8)
   (input  logic             clk, reset, clear, en,
    input logic [WIDTH-1:0]  d, 
    output logic [WIDTH-1:0] q);

   always_ff @(posedge clk, posedge reset)
     if (reset)   q <= 0;
     else if (en) 
       if (clear) q <= 0;
       else       q <= d;
endmodule

// ========================================================================
//  FLOPRC (flip flop w/ clear)

module floprc #(parameter WIDTH = 8)
   (input  logic clk,
    input logic 	     reset,
    input logic 	     clear,
    input logic [WIDTH-1:0]  d, 
    output logic [WIDTH-1:0] q);

   always_ff @(posedge clk, posedge reset)
     if (reset) q <= 0;
     else       
       if (clear) q <= 0;
       else       q <= d;
endmodule

// ========================================================================
//  MUX2 (two input MUX)

module mux2 #(parameter WIDTH = 8)
   (input  logic [WIDTH-1:0] d0, d1, 
    input logic 	           s, 
    output logic [WIDTH-1:0] y);

   assign y = s ? d1 : d0; 
endmodule

// ========================================================================
//  MUX3 (three input MUX)

module mux3 #(parameter WIDTH = 8)
   (input  logic [WIDTH-1:0] d0, d1, d2,
    input logic [1:0] 	     s, 
    output logic [WIDTH-1:0] y);

   assign y = s[1] ? d2 : (s[0] ? d1 : d0); 
endmodule

// ========================================================================
//  IMEM (Intrustion memory)

module imem (input  logic [31:0] a,
	           output logic [31:0] rd);
   
   logic [31:0] 		 RAM[2047:0];
   
   assign rd = RAM[a[31:2]]; // word aligned
   
endmodule // imem

// ========================================================================
//  DMEM (Data memory)

module dmem (input  logic         clk, we,
	         input  logic [31:0]  a, wd,
		     input  logic [2:0]   funct3,
	         output logic [31:0]  rd);
   
   logic [31:0] 		 RAM[2047:0];
   
   logic [31:0] 		 mask, extend_mask, data;
   
   logic [1:0] alignment;
   logic signBit;
   
   assign alignment = a[1:0];
   assign data      = RAM[a[31:2]];
   assign signBit   = data[8 * alignment + ((funct3 == 3'b001) ? 15 : ((funct3 == 3'b000) ? 7 : 31))];
   
   always_comb
	    case(funct3)
		    3'b010:  assign mask = 32'hFFFFFFFF; // load word
		    3'b000:  assign mask = 32'h000000FF << (8 * alignment); // load byte
				 //assign extend_mask = {{24{signBit}}, {8'hFF}};
		    3'b100:  assign mask = 32'h000000FF << (8 * alignment); // load unsigned byte
				 //assign extend_mask = {{24{signBit}}, {8'hFF}};
		    3'b001:  assign mask = 32'h0000FFFF << (8 * alignment); // load half
				 //assign extend_mask = {{16{signBit}}, {16'hFFFF}};
		    3'b101:  assign mask = 32'h0000FFFF << (8 * alignment); // load unsigned half
				 //assign extend_mask = {{16{signBit}}, {16'hFFFF}};
		  default: assign mask = 32'hFFFFFFFF;
				 //assign extend_mask = 32'hFFFFFFFF;
	endcase
	
   always_comb
	    case(funct3)
		    3'b000: assign extend_mask = {{24{signBit}}, {8'h00}};
		    //3'b100: assign extend_mask = {{24{1'b0}}, {8'h00}};
		    3'b001: assign extend_mask = {{16{signBit}}, {16'h0000}};
		    //3'b101: assign extend_mask = {{16{1'b0}}, {16'h0000}};
		  default: assign extend_mask = 32'h00000000;
	endcase
   
   assign rd = ((data & mask) >> (8 * alignment)) | extend_mask; // word aligned
   
   always_ff @(posedge clk)
     if (we) RAM[a[31:2]] <= ((wd << (8 * alignment)) & mask) | (data & (~mask));
   
endmodule // dmem

// ========================================================================
//  ALU 

module alu(input  logic [31:0] a, b,
           input logic  [3:0]  alucontrol,
		       input logic  [2:0]  funct3E,
           output logic [31:0] result,
           output logic        zero);

   logic [31:0] 	   condinvb, sum;
   logic 		         v, carry, negative, BranchControl;              // overflow
   logic 		         isAddSub;       // true when is add or sub
	
   logic [32:0]  carried;

   assign condinvb = alucontrol[0] ? ~b : b;
   assign sum = a + condinvb + alucontrol[0];
   assign isAddSub = ~alucontrol[2] & ~alucontrol[1] |
                     ~alucontrol[1] &  alucontrol[0];

   always_comb
     case (alucontrol)
       4'b0000:  result = sum;         // add
       4'b0001:  result = sum;         // subtract && beq, bne, blt, bge, bltu, bgeu
       4'b0010:  result = a & b;       // and
       4'b0011:  result = a | b;       // or
       4'b0100:  result = a ^ b;       // xor
       4'b0101:  result = sum[31] ^ v; // slt
	
       4'b0110:  result = a >> unsigned'(b[4:0]); // srl, srli
	      4'b0111:  result = a << unsigned'(b[4:0]); // sll, slli
	      4'b1000:  result = $signed(a) >>> unsigned'(b[4:0]); // sra, srai
	      4'b1001:  result = unsigned'(a) < unsigned'(b); // sltiu, sltu
	   
	      4'b1111:  result = b; // lui
       default: result = 32'bx;
     endcase
	
   // sub with extra carry bit
   assign carried = a - b;
   
   assign carry = carried[32];
   assign negative = sum[31];
   assign v = ~(alucontrol[0] ^ a[31] ^ b[31]) & (a[31] ^ sum[31]) & isAddSub;
   
   /*always_comb 
     case (funct3E) //ADDED section 
		    3'b000:  assign BranchControl = (result == 32'b0); 	// beq =
		    3'b001:  assign BranchControl = (result == 32'b0); 	// bne !=
		    3'b100:  assign BranchControl = (negative ^ v);  	// blt <
		    3'b101:  assign BranchControl = (negative ^ v);   	// bge >=
		    3'b110:  assign BranchControl = carry; 				// bltu < unsigned
		    3'b111:  assign BranchControl = carry; 				// bgeu >= unsigned
		    default: assign BranchControl = (result == 32'b0);
     endcase
   
   assign zero = BranchControl ^ funct3E[0];
   */
endmodule
