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
    sub t0, a3, a4       # Compute (n - m)
    addi t0, t0, 1       # Add 1 to get (n - m + 1)
    slli t0, t0, 2       # Convert to byte offset (4 bytes per word)
    add t0, a2, t0       # Compute end address of y (y[n-m])

forj:
    bge a2, t0, donej    # If y[j] reaches end, exit loop

    li t3, 0             # sum = 0

    mv t4, a1            # Set pointer to c[0] (coefficient array)
    add t5, a2, a4       # Compute address of x[j + m - 1]
    slli t5, t5, 2       # Convert to byte offset

    add a7, a1, a4   # Compute end address of c[m] (byte offset)

fori:
    bge t4, a7, donei    # If c[i] reaches end, exit loop

    lw t6, 0(t4)         # Load c[i]
    lw a5, -4(t5)        # Load x[j-1+(m-1)]

    mul a6, t6, a5       # Multiply c[i] * x[j-1+(m-1)]
    add t3, t3, a6       # sum += result

    addi t4, t4, 4       # Move to next coefficient c[i+1]
    addi t5, t5, -4      # Move to previous x value

    j fori               # Loop over i

donei:
    sw t3, 0(a2)         # Store y[j] = sum
    addi a2, a2, 4       # Move to next y[j+1]

    j forj               # Loop over j

donej:
    ret                  # Return from function


