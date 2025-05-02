.section .text.init
.globl rvtest_entry_point

rvtest_entry_point:
    # set up PMP so all of memory is accessible and we don't trap when entering supervisor mode
    li t0, -1
    csrw pmpaddr0, t0         # Set pmpaddr0 to all 1s
    li t0, 0x1F
    csrw pmpcfg0, t0        # Set pmpcfg0 to RWX for region 0
    nop

    # switch to supervisor mode   
    li t2, 0x0800           # set MPP to 2'b01, supervisor mode        # Read mstatus  
    #andi t0, t0, 0x07FF     # anding mstatus with 0x07FF to clear MPP bits             
    #or t0, t0, t1           # set MPP in mstatus to 2'b01   
    csrw mstatus, t2       
    la t0, supervisorstart  
    csrw mepc, t0           
    mret                    # enter supervisor mode at supervisorstart
    nop

supervisorstart:
    la t0, root_pagetable     # t0 = physical addr of root page table
    srli t0, t0, 12           # t1 = PPN
    lui t1, 0x80000
    or t0, t0, t1
   # li t2, 1                  # MODE = 1 (Sv32)
   # slli t2, t2, 31           # MODE in bit 31
   # or t1, t1, t2             # OR in the MODE
    csrw satp, t0             # write to satp


    
    li t0, 0x90000300       
    li t1, 42
    sw t1, 0(t0)

    la t0, testcode         # address of a routine to run
    lui t1, 0x10000         
    add t0, t0, t1          # address of testcode on virtual page 0x90000 
    jr t0                   # jump to the testcode on Virtual page 0x90000

testcode:
    li t0, 42               # do something

write_tohost:
    la s1, tohost           # terminate with write tohost
    li t0, 1                # 1 for success, 3 for failure
    sw t0, 0(s1)            # send success code (yay)
    sw zero, 4(s1)          # not obvious why Sail isn't terminating unless this write is done

self_loop:
    j self_loop

.align 4
tohost:
    .word 0

.data

.align 16
# root (L1) Page table situated at 0x80010000
root_pagetable:
    .space 2048
    .4byte 0x20004401
    .space 252
    .4byte 0x20004401

.align 12
# L0 page table situated at 0x80011000
.4byte 0x200000CF
