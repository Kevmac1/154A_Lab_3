##############################################################################
# File: sort.s
# Skeleton for ECE 154A
##############################################################################

	.data
student:
	.asciz "Student: Your Name Here"  # Replace with your name
	.globl	student
nl:	.asciz "\n"
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

key:	.word 268632064			# Base address of input key array
output:	.word 268632144			# Base address of output array
numkeys:	.word 6				# Number of inputs
maxnumber:	.word 10			# Maximum key value

count:  .space  44                  # Allocate space for count array (4 bytes each for maxnumber + 1 = 11)

data1:	.word 1
data2:	.word 2
data3:	.word 3
data4:	.word 5
data5:	.word 6
data6:	.word 8


	.text

	.globl main
main:					# main has to be a global label
	addi	sp, sp, -4		# Move the stack pointer
	sw 	ra, 0(sp)		# save the return address
			
	li	a7, 4			# print_str (system call 4)
	la	a0, student		# takes the address of string as an argument 
	ecall	

	jal process_arguments
	jal read_data			# Read the input data

	j	ready

process_arguments:
	
	la	t0, key
	lw	a0, 0(t0)
	la	t0, output
	lw	a1, 0(t0)
	la	t0, numkeys
	lw	a2, 0(t0)
	la	t0, maxnumber
	lw	a3, 0(t0)
	jr	ra	

### This instructions will make sure you read the data correctly
read_data:
	mv t1, a0
	li a7, 4
	la a0, read_msg
	ecall
	mv a0, t1

	la t0, data1
	lw t4, 0(t0)
	sw t4, 0(a0)
	la t0, data2
	lw t4, 0(t0)
	sw t4, 4(a0)
	la t0, data3
	lw t4, 0(t0)
	sw t4, 8(a0)
	la t0, data4
	lw t4, 0(t0)
	sw t4, 12(a0)
	la t0, data5
	lw t4, 0(t0)
	sw t4, 16(a0)
	la t0, data6
	lw t4, 0(t0)
	sw t4, 20(a0)

	jr	ra



######################### 
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
    bgt     t1, s3, count_keys
    sw      zero, 0(t0)      # Set count[t1] to 0
    addi    t0, t0, 4
    addi    t1, t1, 1
    j       init_count

count_keys:
    mv      t0, s0          # t0 = key array pointer
    li      t1, 0           # t1 = counter
count_loop:
    bge     t1, s2, prep_cumulative
    lw      t2, 0(t0)       # t2 = current key
    slli    t3, t2, 2       # t3 = offset in count array
    add     t3, s4, t3      # t3 = address in count array
    lw      t4, 0(t3)       # t4 = current count
    addi    t4, t4, 1        # Increment count
    sw      t4, 0(t3)       # Store updated count
    addi    t0, t0, 4       # Next key
    addi    t1, t1, 1       # Increment counter
    j       count_loop

prep_cumulative:
    li      t1, 1          # Start from index 1
cumulative_loop:
    bgt     t1, s3, build_output
    slli    t2, t1, 2      # t2 = current offset
    add     t2, s4, t2     # t2 = current address
    addi    t3, t2, -4     # t3 = previous address
    lw      t4, 0(t2)      # t4 = current value
    lw      t5, 0(t3)      # t5 = previous value
    add     t4, t4, t5      # Add previous to current
    sw      t4, 0(t2)      # Store sum
    addi    t1, t1, 1
    j       cumulative_loop

build_output:
    mv      t0, s0         # t0 = key array pointer
    mv      t6, s2         # t6 = counter (starting from numkeys)
    addi    t6, t6, -1     # Adjust to 0-based index
output_loop:
    bltz    t6, sort_done
    slli    t1, t6, 2      # t1 = offset in key array
    add     t1, s0, t1     # t1 = address in key array
    lw      t2, 0(t1)      # t2 = current key
    slli    t3, t2, 2      # t3 = offset in count array
    add     t3, s4, t3     # t3 = address in count array
    lw      t4, 0(t3)      # t4 = position
    addi    t4, t4, -1     # Decrement position
    sw      t4, 0(t3)      # Store updated position
    slli    t5, t4, 2      # t5 = offset in output array
    add     t5, s1, t5     # t5 = address in output array
    sw      t2, 0(t5)      # Store key in output
    addi    t6, t6, -1      # Decrement counter
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

#########################


##################################
#Dont modify code below this line
##################################
ready:
	jal	initial_values		# print operands to the console
	
	mv 	t2, a0
	li 	a7, 4
	la 	a0, code_start_msg
	ecall
	mv 	a0, t2

	jal	counting_sort		# call counting sort algorithm

	jal	sorted_list_print


				# Usual stuff at the end of the main
	lw	ra, 0(sp)		# restore the return address
	addi	sp, sp, 4
	jr	ra			# return to the main program

print_results:
	add t0, zero, a2 # No of elements in the list
	add t1, zero, a0 # Base address of the array
	mv t2, a0    # Save a0, which contains base address of the array

loop:	
	beq t0, zero, end_print
	addi, t0, t0, -1
	lw t3, 0(t1)
	
	li a7, 1
	mv a0, t3
	ecall

	li a7, 4
	la a0, nl
	ecall

	addi t1, t1, 4
	j loop
end_print:
	mv a0, t2 
	jr ra	

initial_values: 
	mv 	t2, a0
        addi	sp, sp, -4		# Move the stack pointer
	sw 	ra, 0(sp)		# save the return address

	li a7, 4
	la a0, initial_print
	ecall
	
	mv 	a0, t2
	jal print_results
 	
	lw	ra, 0(sp)		# restore the return address
	addi	sp, sp, 4

	jr ra

sorted_list_print:
	mv 	t2, a0
	addi	sp, sp, -4		# Move the stack pointer
	sw 	ra, 0(sp)		# save the return address

	li a7,4
	la a0,sort_print
	ecall
	
	mv a0, t2
	
	#swap a0,a1
	mv t2, a0
	mv a0, a1
	mv a1, t2
	
	jal print_results
	
    #swap back a1,a0
	mv t2, a0
	mv a0, a1
	mv a1, t2
	
	lw	ra, 0(sp)		# restore the return address
	addi	sp, sp, 4	
	jr ra
