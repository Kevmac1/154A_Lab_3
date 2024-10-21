    .data
student:
    .asciz "Student Name\n"    # Replace with your name
    .globl  student
nl: .asciz "\n"
    .globl nl
sort_print:
    .asciz "[Info] Sorted values\n"
    .globl sort_print
initial_print:
    .asciz "[Info] Initial values\n"
    .globl initial_print
read_msg: 
    .asciz "[Info] Reading input data\n"
    .globl read_msg
code_start_msg:
    .asciz "[Info] Entering your section of code\n"
    .globl code_start_msg

# Input data array
input_keys: .word 1, 2, 3, 5, 6, 8  # Example input data
numkeys:    .word 6                # Number of elements in input
maxnumber:  .word 10               # Maximum value in input (0 to 10)

# Output array (to be filled by the sorting algorithm)
output:     .space 24              # Space for 6 integers (6 * 4 bytes)

# Count array (to store counts of each number)
count:      .space 44              # Space for maxnumber + 1 (11 * 4 bytes)

    .text
    .globl main

main:
    # Set up stack frame
    addi    sp, sp, -16        # Create space on stack
    sw      ra, 12(sp)         # Save return address
    sw      s0, 8(sp)          # Save s0
    sw      s1, 4(sp)          # Save s1
    sw      s2, 0(sp)          # Save s2

    # Load input arguments
    la      a0, input_keys     # Load address of keys array
    la      a1, output          # Load address of output array
    lw      a2, numkeys        # Load number of keys
    lw      a3, maxnumber      # Load maximum number

    # Call counting sort function
    jal     counting_sort

    # Print sorted output
    li      a7, 4              # print_str system call
    la      a0, sort_print
    ecall
    
    mv      t0, a1             # t0 = output array address
    li      t1, 0               # index for output array
print_output:
    bge     t1, a2, end        # If index >= numkeys, end printing
    lw      a0, 0(t0)          # Load sorted value from output
    li      a7, 1               # print_int system call
    ecall
    li      a7, 4              # print_str system call for newline
    la      a0, nl
    ecall
    addi    t0, t0, 4          # Move to the next integer
    addi    t1, t1, 1          # Increment index
    j       print_output

end:
    # Restore registers and exit
    lw      ra, 12(sp)         # Restore return address
    lw      s0, 8(sp)          # Restore s0
    lw      s1, 4(sp)          # Restore s1
    lw      s2, 0(sp)          # Restore s2
    addi    sp, sp, 16         # Restore stack pointer
    li      a7, 10             # exit system call
    ecall

# Counting sort function
counting_sort:
    # Initialize local variables
    addi    sp, sp, -32         # Create stack frame
    sw      ra, 0(sp)          # Save return address
    sw      s0, 4(sp)          # Save s0
    sw      s1, 8(sp)          # Save s1
    sw      s2, 12(sp)         # Save s2
    sw      s3, 16(sp)         # Save s3
    sw      s4, 20(sp)         # Save s4
    sw      s5, 24(sp)         # Save s5

    # Initialize count array to 0
    la      s0, count          # s0 = address of count array
    li      s1, 0              # s1 = n
    li      s2, 0              # s2 = maxnumber
init_count:
    bgt     s2, a3, count_keys # If n > maxnumber, go to count_keys
    sw      zero, 0(s0)        # count[n] = 0
    addi    s0, s0, 4          # Move to the next position
    addi    s2, s2, 1          # Increment n
    j       init_count

count_keys:
    la      s0, input_keys     # s0 = address of keys array
    li      s2, 0              # Reset s2 for numkeys
count_loop:
    bge     s2, a2, cumulate   # If index >= numkeys, go to cumulate
    lw      s3, 0(s0)          # Load key
    bgt     s3, a3, count_next # If key > maxnumber, skip
    la      s4, count          # s4 = address of count array
    slli    t0, s3, 2          # t0 = key * 4 (word size)
    add     t0, s4, t0         # Get address of count[key]
    lw      t1, 0(t0)          # Load current count
    addi    t1, t1, 1          # Increment count
    sw      t1, 0(t0)          # Store updated count
count_next:
    addi    s0, s0, 4          # Move to the next key
    addi    s2, s2, 1          # Increment index
    j       count_loop

cumulate:
    la      s0, count          # s0 = address of count array
    li      s2, 1              # Start from count[1]
cumulate_loop:
    bgt     s2, a3, build_output # If n > maxnumber, go to build_output
    slli    t0, s2, 2          # t0 = n * 4
    add     t1, s0, t0         # t1 = address of count[n]
    lw      t2, 0(t1)          # Load count[n]
    addi    t3, t2, -4         # t3 = count[n-1]
    add     t2, t2, t3         # count[n] += count[n-1]
    sw      t2, 0(t1)          # Store updated count
    addi    s2, s2, 1          # Increment n
    j       cumulate_loop

build_output:
    la      s0, input_keys     # s0 = address of keys array
    la      s1, output          # s1 = address of output array
    li      s2, 0              # Reset index
output_loop:
    bge     s2, a2, sort_done  # If index >= numkeys, done
    lw      s3, 0(s0)          # Load key
    la      s4, count          # s4 = address of count array
    slli    t0, s3, 2          # t0 = key * 4
    add     t0, s4, t0         # Get address of count[key]
    lw      t1, 0(t0)          # Load count[key]
    addi    t1, t1, -1         # Decrement count
    sw      t1, 0(t0)          # Store updated count
    slli    t2, t1, 2          # t2 = (count[key]-1) * 4
    add     t2, s1, t2         # t2 = address in output
    sw      s3, 0(t2)          # Store key in output
    addi    s0, s0, 4          # Move to next key
    addi    s2, s2, 1          # Increment index
    j       output_loop

sort_done:
    # Restore registers
    lw      ra, 0(sp)          # Restore return address
    lw      s0, 4(sp)          # Restore s0
    lw      s1, 8(sp)          # Restore s1
    lw      s2, 12(sp)         # Restore s2
    lw      s3, 16(sp)         # Restore s3
    lw      s4, 20(sp)         # Restore s4
    lw      s5, 24(sp)         # Restore s5
    addi    sp, sp, 32         # Restore stack pointer
    jr      ra                  # Return from function
