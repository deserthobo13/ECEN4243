=======================================================================================================================

File used for simulation: riscv_single1.sv
File used for implementation: riscv_single.sv

To run the design through simulation, just type:

vsim -do riscv_single.do -c

or

vsim -do riscv_single.do

=======================================================================================================================

Main updates to the simulation file:
  In the Controller:
    Implemented Neg, Carry, and Overflow as inputs from the datapath
    Updated PCSrc lgoic: Uses the new BranchControl signal to determine when a condition branch should be taken
  In Main Decoder:
    Increased Control Signal Width
    Added Support for more instructions
  In ALU Decoder:
    Handels Branch Comparion ALU Control
    Added Differntiates between signed/unsigend comparisons an dhandles shift operations
  In Datapath
    Output ALU Flags: Zero, Neg, Carry, and Overflow from the ALU
    Updated PC logic to use PCSrc to selcet between PC+4 and the branch/jump target
  In ALU:
    Generates Neg, Carry, and Overflow flags
    
=======================================================================================================================

Main updates to the implemintation file:
  Added MemStrobe and PCReady for implemntation
  In Decoder:
    Increased Control signal width form 13 to 14
  Took out the testbench, top, imem and dmem
  
======================================================================================================================= 
