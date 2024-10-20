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
counting_sort:
    # Prologue: Save registers on the stack
    addi sp, sp, -32         # Adjust stack pointer for local variables
    sw ra, 28(sp)            # Save return address
    sw s0, 24(sp)            # Save s0
    sw s1, 20(sp)            # Save s1
    sw s2, 16(sp)            # Save s2
    sw s3, 12(sp)            # Save s3
    sw s4, 8(sp)             # Save s4

    # Initialize count array to 0
    mv s0, sp                # Use s0 as a pointer for the count array (on stack)
    mv s1, a3                # s1 = maxnumber
    addi s1, s1, 1           # s1 = maxnumber + 1
    li t0, 0                 # t0 = index n (starts from 0)

init_count:
    beq t0, s1, count_done   # If n > maxnumber, exit loop
    sw zero, 0(s0)           # count[n] = 0
    addi s0, s0, 4           # Move to the next count element
    addi t0, t0, 1           # n++
    j init_count             # Repeat

count_done:
    # Count occurrences from keys array
    mv s0, sp                # Reset s0 to point to the count array
    mv t0, zero              # t0 = 0 (index n)
    mv s2, a2                # s2 = numkeys (length of keys array)
    
count_keys:
    beq t0, s2, cumulative_sum  # If n >= numkeys, exit loop
    slli t1, t0, 2           # t1 = n * 4 (byte offset for accessing keys)
    add a4, a0, t1           # a4 = address of keys[n]
    lw t2, 0(a4)             # t2 = keys[n]
    slli t3, t2, 2           # t3 = keys[n] * 4 (offset into count array)
    add t4, s0, t3           # t4 = address of count[keys[n]]
    lw t5, 0(t4)             # Load count[keys[n]]
    addi t5, t5, 1           # count[keys[n]]++
    sw t5, 0(t4)             # Store updated count[keys[n]]
    addi t0, t0, 1           # n++
    j count_keys             # Repeat

cumulative_sum:
    # Calculate cumulative sum in count array
    li t0, 1                 # Start from count[1] (skip count[0])
    mv s3, a3                # s3 = maxnumber (for looping)
    addi s3, s3, 1           # s3 = maxnumber + 1
    mv s0, sp                # Reset s0 to point to the count array

sum_loop:
    beq t0, s3, fill_output  # If n > maxnumber, exit loop
    slli t1, t0, 2           # t1 = n * 4 (byte offset)
    add t4, s0, t1           # t4 = address of count[n]
    lw t2, 0(t4)             # Load count[n]
    addi t5, t0, -1          # t5 = n - 1
    slli t6, t5, 2           # t6 = (n - 1) * 4
    add t7, s0, t6           # t7 = address of count[n-1]
    lw t8, 0(t7)             # Load count[n-1]
    add t2, t2, t8           # count[n] = count[n] + count[n-1]
    sw t2, 0(t4)             # Store updated count[n]
    addi t0, t0, 1           # n++
    j sum_loop               # Repeat

fill_output:
    # Fill output array
    mv t0, zero              # n = 0
    mv s0, sp                # Reset s0 to point to count array

fill_output_loop:
    beq t0, s2, sort_done    # If n >= numkeys, exit loop
    slli t1, t0, 2           # t1 = n * 4 (byte offset for keys)
    add a4, a0, t1           # a4 = address of keys[n]
    lw t2, 0(a4)             # Load keys[n]
    slli t3, t2, 2           # t3 = keys[n] * 4 (offset into count array)
    add t4, s0, t3           # t4 = address of count[keys[n]]
    lw t5, 0(t4)             # Load count[keys[n]]
    addi t5, t5, -1          # count[keys[n]]-- (decrement)
    sw t5, 0(t4)             # Store updated count[keys[n]]
    slli t5, t5, 2           # Convert count[keys[n]] to byte offset
    add t6, a1, t5           # t6 = address of output[count[keys[n]] - 1]
    sw t2, 0(t6)             # output[count[keys[n]] - 1] = keys[n]
    addi t0, t0, 1           # n++
    j fill_output_loop       # Repeat

sort_done:
    # Epilogue: Restore registers and return
    lw ra, 28(sp)            # Restore return address
    lw s0, 24(sp)            # Restore s0
    lw s1, 20(sp)            # Restore s1
    lw s2, 16(sp)            # Restore s2
    lw s3, 12(sp)            # Restore s3
    lw s4, 8(sp)             # Restore s4
    addi sp, sp, 32          # Restore stack pointer
    jr ra                    # Return


#########################
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
