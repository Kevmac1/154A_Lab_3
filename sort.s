##############################################################################
# File: sort.s
# Counting Sort Implementation for ECE 154A
##############################################################################

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

# Data section for the arrays and parameters
.align 2
key:    .word 0x10030000      # Base address for input array
output: .word 0x10030050      # Base address for output array
numkeys: .word 6              # Number of elements
maxnumber: .word 10           # Maximum value in the input

# Input data array
data1:  .word 1
data2:  .word 2
data3:  .word 3
data4:  .word 5
data5:  .word 6
data6:  .word 8

# Count array - allocate space for maxnumber + 1 elements (44 bytes for 11 numbers 0-10)
count:  .space 44

    .text
    .globl main

main:
    addi    sp, sp, -4        # Adjust stack for return address
    sw      ra, 0(sp)         # Save return address
    
    li      a7, 4             # print_str system call
    la      a0, student       # Load student name string
    ecall
    
    jal     process_arguments  # Load arguments into registers
    jal     read_data          # Read input data
    j       ready

process_arguments:
    la      t0, key
    lw      a0, 0(t0)        # Load key array address
    la      t0, output
    lw      a1, 0(t0)        # Load output array address
    la      t0, numkeys
    lw      a2, 0(t0)        # Load number of keys
    la      t0, maxnumber
    lw      a3, 0(t0)        # Load maximum number
    jr      ra

read_data:
    mv      t1, a0           # Save key array address
    li      a7, 4
    la      a0, read_msg
    ecall
    mv      a0, t1           # Restore key array address

    # Load input data into the key array
    li      t0, 0            # Counter
    li      t4, 0            # Data array index

load_data:
    bge     t0, 6, finish_loading_data  # Stop when 6 elements are loaded
    lw      t5, data1(t4)   # Load data element
    sw      t5, 0(a0)       # Store data in key array
    addi    a0, a0, 4       # Move to the next position in key array
    addi    t0, t0, 1       # Increment counter
    addi    t4, t4, 4       # Move to the next data element
    j       load_data

finish_loading_data:
    jr      ra

counting_sort:
    # Save registers
    addi    sp, sp, -32
    sw      ra, 0(sp)
    sw      s0, 4(sp)
    sw      s1, 8(sp)
    sw      s2, 12(sp)
    sw      s3, 16(sp)
    sw      s4, 20(sp)
    sw      s5, 24(sp)
    sw      s6, 28(sp)

    # Save arguments in saved registers
    mv      s0, a0           # s0 = key array address
    mv      s1, a1           # s1 = output array address
    mv      s2, a2           # s2 = numkeys
    mv      s3, a3           # s3 = maxnumber
    la      s4, count        # s4 = count array address

    # Initialize count array to 0
    mv      t0, s4           # t0 = count array pointer
    li      t1, 0             # t1 = counter
init_count:
    bgt     t1, s3, count_keys  # Check if count array is initialized
    sw      zero, 0(t0)      # Set count[t1] to 0
    addi    t0, t0, 4        # Move to the next count position
    addi    t1, t1, 1        # Increment counter
    j       init_count

count_keys:
    mv      t0, s0          # t0 = key array pointer
    li      t1, 0           # t1 = counter
count_loop:
    bge     t1, s2, prep_cumulative
    lw      t2, 0(t0)       # t2 = current key
    bgt     t2, s3, count_loop_next # Ensure the key is within bounds
    slli    t3, t2, 2       # t3 = offset in count array
    add     t3, s4, t3      # t3 = address in count array
    lw      t4, 0(t3)       # t4 = current count
    addi    t4, t4, 1       # increment count
    sw      t4, 0(t3)       # store updated count

count_loop_next:
    addi    t0, t0, 4       # next key
    addi    t1, t1, 1       # increment counter
    j       count_loop

prep_cumulative:
    li      t1, 1          # start from index 1
cumulative_loop:
    bgt     t1, s3, build_output
    slli    t2, t1, 2       # t2 = current offset
    add     t2, s4, t2      # t2 = current address
    addi    t3, t2, -4      # t3 = previous address
    lw      t4, 0(t2)       # t4 = current value
    lw      t5, 0(t3)       # t5 = previous value
    add     t4, t4, t5      # add previous to current
    sw      t4, 0(t2)       # store sum
    addi    t1, t1, 1
    j       cumulative_loop

build_output:
    mv      t0, s0         # t0 = key array pointer
    mv      t6, s2         # t6 = counter (starting from numkeys)
    addi    t6, t6, -1     # adjust to 0-based index
output_loop:
    bltz    t6, sort_done
    slli    t1, t6, 2      # t1 = offset in key array
    add     t1, s0, t1     # t1 = address in key array
    lw      t2, 0(t1)      # t2 = current key
    slli    t3, t2, 2      # t3 = offset in count array
    add     t3, s4, t3     # t3 = address in count array
    lw      t4, 0(t3)      # t4 = position
    addi    t4, t4, -1     # decrement position
    sw      t4, 0(t3)      # store updated position
    slli    t5, t4, 2      # t5 = offset in output array
    add     t5, s1, t5     # t5 = address in output array
    sw      t2, 0(t5)      # store key in output
    addi    t6, t6, -1     # decrement counter
    j       output_loop

sort_done:
    # Restore registers
    lw      ra, 0(sp)
    lw      s0, 4(sp)
    lw      s1, 8(sp)
    lw      s2, 12(sp)
    lw      s3, 16(sp)
    lw      s4, 20(sp)
    lw      s5, 24(sp)
    lw      s6, 28(sp)
    addi    sp, sp, 32
    
    jr      ra

ready:
    jal     initial_values    # print initial values
    
    li      a7, 4
    la      a0, code_start_msg
    ecall
    
    jal     counting_sort     # perform counting sort
    
    jal     sorted_list_print # print sorted values
    
    lw     
