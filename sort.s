
##############################################################################
# File: sort.s
# Skeleton for ECE 154A
##############################################################################

	.data
student:
	.asciz "Student:\n" 	# Place your name in the quotations in place of Student
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

key:	.word 268632064			# Provide the base address of array where input key is stored(Assuming 0x10030000 as base address)
output:	.word 268632144			# Provide the base address of array where sorted output will be stored (Assuming 0x10030050 as base address)
numkeys:	.word 6				# Provide the number of inputs
maxnumber:	.word 10			# Provide the maximum key value


## Specify your input data-set in any order you like. I'll change the data set to verify
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


counting_sort:
######################### 
## your code goes here ##
#########################
counting_sort:
	# Load the number of keys and maximum value
	la    t0, numkeys        # Load address of numkeys
	lw    t1, 0(t0)          # Load the number of keys into t1
	la    t0, maxnumber      # Load address of maxnumber
	lw    t2, 0(t0)          # Load the maximum key value into t2
	addi  t2, t2, 1          # maxnumber + 1 to account for zero-based indexing

	# Initialize count array to 0
	la    t3, count          # Address of the count array
	li    t4, 0              # Value 0
count_init_loop:
	beq   t2, zero, done_init_count # Break when maxnumber reaches 0
	sw    t4, 0(t3)          # Store 0 at the current count index
	addi  t3, t3, 4          # Move to next index
	addi  t2, t2, -1         # Decrement maxnumber
	j     count_init_loop    # Repeat until count array initialized
done_init_count:

	# Step 1: Count the occurrences of each key
	la    t3, key            # Address of the key array
	la    t4, count          # Address of the count array
	lw    t5, numkeys        # Load the number of keys
key_count_loop:
	beq   t5, zero, done_count_keys  # Break if no more keys
	lw    t6, 0(t3)          # Load the key value
	sll   t7, t6, 2          # Multiply key by 4 to index count array
	add   t8, t4, t7         # Address of count[key]
	lw    t9, 0(t8)          # Load count[key]
	addi  t9, t9, 1          # Increment count[key]
	sw    t9, 0(t8)          # Store updated count[key]
	addi  t3, t3, 4          # Move to the next key
	addi  t5, t5, -1         # Decrement numkeys
	j     key_count_loop
done_count_keys:

	# Step 2: Accumulate the counts
	la    t4, count          # Address of the count array
	addi  t5, t2, -1         # Set loop counter for accumulation
accum_loop:
	blt   t5, zero, done_accum # If done accumulating
	lw    t6, 0(t4)          # Load count[i]
	addi  t4, t4, 4          # Move to the next count
	lw    t7, 0(t4)          # Load count[i+1]
	add   t7, t7, t6         # Accumulate count[i+1] += count[i]
	sw    t7, 0(t4)          # Store accumulated value
	addi  t5, t5, -1         # Decrement loop counter
	j     accum_loop
done_accum:

	# Step 3: Place the keys into output array
	la    t3, key            # Address of the key array
	la    t4, count          # Address of the count array
	la    t8, output         # Address of the output array
	lw    t5, numkeys        # Load the number of keys
place_loop:
	beq   t5, zero, done_place_keys  # Break when all keys are placed
	lw    t6, 0(t3)          # Load the key value
	sll   t7, t6, 2          # Multiply key by 4 to index count array
	add   t9, t4, t7         # Address of count[key]
	lw    t10, 0(t9)         # Load count[key]
	addi  t10, t10, -1       # Decrement count[key]
	sw    t10, 0(t9)         # Store updated count[key]
	sll   t10, t10, 2        # Multiply count[key] by 4 (for word offset)
	add   t11, t8, t10       # Address of output[count[key]]
	sw    t6, 0(t11)         # Place key in the output array
	addi  t3, t3, 4          # Move to the next key
	addi  t5, t5, -1         # Decrement numkeys
	j     place_loop
done_place_keys:



 	jr ra
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
