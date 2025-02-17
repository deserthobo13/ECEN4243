This lab focuses on gaining experience with RISC-V assebmly, simulation, and debugging. The main objectives indluded
    - Simulation RISC-V program swith Spike
    - Debugging and simulating the riscv-wally SystemVerilog modle with Verilator        and Questa
RISC-V is a open source instruction set architecture widely used in the industry. This lab introduces essential RISC-V toolchiand, including GNU GCC, Binutils, and simulation frameworks. By the end of this lab we gained a better understanding of RISC-V development workflows and debugging techniques


#################################################################################################################

Section 2 Command History

    1  source /opt/modpath.sh
    2  vsim -do fsm.do
    3  source /opt/modpath.sh
    4  vsim -do fsm.do
    5  vsim -do regfile.do
    6  vsim -do fsm.do
    7  vsim -do regfile.do
    8  cd cvw
    9  git clone --recurse-submodules https://github.com/SamShankle/cvw
    10  cd cvw
    11  source ./setup.sh
    12  cd examples/
    13  cd C
    14  cd hello
    15  make
    16  wsim --sim questa rv64gc --elf hello
    17  history

#################################################################################################################

Section 3 Command History

    1  source /opt/modpath.sh
    2  vsim -do fsm.do
    3  source /opt/modpath.sh
    4  vsim -do fsm.do
    5  vsim -do regfile.do
    6  vsim -do fsm.do
    7  vsim -do regfile.do
    8  cd cvw
    9  git clone --recurse-submodules https://github.com/SamShankle/cvw
    10  cd cvw
    11  source ./setup.sh
    12  cd examples/
    13  cd C
    14  cd hello
    15  make
    16  wsim --sim questa rv64gc --elf hello
    17  history
    18  command > part2.txt
    19  ls
    20  mv part2.txt Home/Documents/Lab 2
    21  mv part2.txt Home/Documents/Lab_2
    22  mv part2.txt Home/Documents/"Lab 2"
    23  cd..
    24  cd ..
    25  mv part2.txt Home/Documents/"Lab 2"
    26  cd cvw
    27  cd $WALLY/example/asm/example
    28  cd example/asm/example
    29  cd examples/
    30  cd asm/example/
    31  ls
    32  riscv64-unknown-elf-gcc -o example -march=rv32i -mabi=ilp32 -mcmodel=medany -nostartfiles -T../../link/link.ld example.S
    33  riscv64-unknown-elf-objdump -D example > example.objdump
    34  ls
    35  cd ..
    36  cat common/test.ld
    37  cd c
    38  cd examples/
    39  cd c
    40  cd C
    41  cat common/test.ld
    42  cat makefile
    43  cd ..
    44  cat makefile
    45  cd asm/example/
    46  cat makefile
    47  cd Makefile
    48  cat Makefile
    49  make
    50  make clean
    51  cd -
    52  cd ..
    53  $WALLY/examples/asm/sumtest
    54  $WALLY$
    55  cd examples/asm/sumtest/
    56  make
    57  spike +signature=sumtest.signature.output sumtest
    58  diff sumtest.signature.output sumtest.reference_output 
    59  make clean 
    60  make
    61  make sim
    62  riscv64-unknown-elf-readelf -a sumtest
    63  cd --
    64  cd cvw/examples/C/sum
    65  make
    66  spike sum
    67  cd --
    68  cd cvw/
    69  lint-wally
    70  cd sim
    71  make deriv
    72  lint-wally
    73  cd ..
    74  cd examples/C/sum
    75  make
    76  spike sum
    77  wsim --sim questa rv64gc --elf sum
    78  history
    79  history > part3.txt

#################################################################################################################

Markdown table resutls of Section 3

Results

optimization level: 
None
-O
-O2

Mcycle Questa:
1609952 / 1028970
1598787 / 739395
1598749 / 721025

mcycle spike:
392150 / 392166
149531 / 149538
116478 / 116483

#################################################################################################################

To run both fir1 and fir2 you will follow these steps
    - cd to the fir1 or fir2 foulder 
    - run "make clean"
    - run "make"
    - run "spike fir1 or fir2"
        - This gets the .objdump file 
    - run "wsim -sim questa rv64gc --elf sum"
        - This will get the .memfile, objdump.addr, and objdump.lab files also
    - When you run spike and Questa you can compare the CPI values you get
