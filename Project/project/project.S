.section .text.init
.globl rvtest_entry_point

rvtest_entry_point:
    # set up PMP so all of memory is accessible and we don't trap when entering supervisor mode
    li t0, -1
    csrw pmpaddr0, t0          # Set pmpaddr0 to all 1s
    li t0, 0x7F
    csrw pmpcfg0, t0          # Set pmpcfg0 to RWX for region 0
    nop

    # switch to supervisor mode    
    csrr t0, mstatus        # Read mstatus
    li t1, 0x1800           # Mask for MPP bits (12:11)
    not t2, t1
    and t0, t0, t2         # Clear MPP bits
    li t1, 0x800            # Set MPP to 01
    or t0, t0, t1           # Set MPP to 01
    csrw mstatus, t0        # Write back to mstatus
    la t0, supervisorstart  # Load supervisorstart address
    csrw mepc, t0           # Set mepc
    mret                    # enter supervisor mode at supervisorstart
    nop

supervisorstart:
    la t0, pagetable        # get address of root page table
    srli t1, t0, 12         # Get PPN (t0 >> 12)
    li t2, 8                # Sv32 mode
    slli t2, t2, 31         # Shift mode to bit 31
    or t1, t1, t2           # Combine PPN and mode
    mv t0, t1               # Move to t0 for csrw
    csrw satp, t0           # enable virtual memory
    
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

tohost:
    .word 0

.data

.align 16
# root (L1) Page table situated at 0x80010000
pagetable:

.align 12
# L0 page table situated at 0x80011000
