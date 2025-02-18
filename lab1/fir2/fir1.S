# fir.S 
# assembly language of Finite Impulse Response (FIR)

// a0: base address of x
// a1: base address of c
// a2: base address of y, later used as pointer to y[j] in j loop
// a3: n
// a4: m

// t0: &y[n-m] to check termination of j loop
// t1: &c[m] to check termination of i loop
// t2: &x[j+m-1]
// t3: sum
// t4: pointer to c[i] in i loop
// t5: pointer to x[j-i+(m-1)] 
// t6: value of c[i]
// a5: value of x[j-1+(m-1)]
// a6: multiplication result
// a7: address limit for c[m]


.global fir

fir:
    sub t0, a3, a4       #n - m
    addi t0, t0, 1
    slli t0, t0, 2      # offset t0 before adding a2
    add t0, a2, t0
    slli t1, a4, 2      # offset t1 before adding a1
    add t1, t1, a1
forj:
    bge a2, t0, donej    # if y[j] reaches end branch to donej
    li t3, 0             # reset sum (Don't remove again)
    li t1, 0              # reset i  for next part
    mv t4, a1            # set pointer to c[0]
    slli t6, a4, 2 
    add t5, a0, t6
    addi t5, t5, -4
fori:
    bge t1, a4, donei    # If c[i] reaches end exit to donei
    lw t6, 0(t4)
    lw a5, 0(t5)
    mul a6, t6, a5       # Multiply c[i] with x[j-1+(m-1)].
    srli a6, a6, 31       # Q_31 fixed point shift
    add t3, t3, a6      # sum += result
    addi t4, t4, 4      # go to next coefficient c[i+1]
    addi t5, t5, -4     # go to previous x value
    addi t1, t1, 1      # Increment by i

    j fori         
donei:
    sw t3, 0(a2)        # Store y[j] with sum
    addi a2, a2, 4       
    addi a0, a0, 4
    j forj              
donej:
    ret             # Return from function
