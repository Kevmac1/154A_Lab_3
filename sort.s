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
	# Prologue
	addi    sp, sp, -16     # Allocate stack space
	sw      ra, 12(sp)      # Save return address
	sw      s0, 8(sp)       # Save s0
	sw      s1, 4(sp)       # Save s1
	sw      s2, 0(sp)       # Save s2

	# Initialize pointers and variables
	mv      s0, a0          # s0 = keys (input array)
	mv      s1, a1          # s1 = output (sorted array)
	mv      s2, a3          # s2 = maxnumber

	# Initialize count array
	li      t0, 0           # t0 = counter index
	li      t1, 0           # t1 = zero value
	la      t2, count       # t2 = address of count array
	li      t3, 0           # t3 = maxnumber + 1

init_count:
	beq     t0, t3, count_keys # if counter equals maxnumber + 1, go to count_keys
	sw      t1, 0(t2)       # count[t0] = 0
	addi    t2, t2, 4       # Move to next count index
	addi    t0, t0, 1       # Increment counter
	j       init_count

count_keys:
	# Count occurrences of each key
	li      t0, 0           # t0 = key index
	la      t2, count       # Reset address of count array

count_loop:
	beq     t0, a2, cum_count # if t0 == numkeys, go to cumulative count
	lw      t1, 0(s0)       # Load key from keys array
	addi    t2, t2, 4       # Move to corresponding count index
	addi    t1, t1, -1      # Decrement key to use as index
	slli    t1, t1, 2       # Multiply index by 4 (word size)
	lw      t3, 0(t2)       # Load current count
	addi    t3, t3, 1       # Increment count
	sw      t3, 0(t2)       # Store updated count back
	addi    s0, s0, 4       # Move to next key
	addi    t0, t0, 1       # Increment key index
	j       count_loop

cum_count:
	# Calculate cumulative counts
	li      t0, 1           # Start from index 1
	la      t2, count       # Reset address of count array

cumulative_loop:
	beq     t0, t3, sort_output # if t0 == maxnumber + 1, go to sort output
	lw      t1, 0(t2)       # Load current count
	lw      t4, 4(t2)       # Load next count
	add     t1, t1, t4      # Update count[t0] = count[t0] + count[t0 - 1]
	sw      t1, 0(t2)       # Store back the cumulative count
	addi    t2, t2, 4       # Move to next count index
	addi    t0, t0, 1       # Increment counter
	j       cumulative_loop

sort_output:
	# Sort the keys into the output array
	li      t0, 0           # t0 = key index
	la      t2, count       # Reset address of count array

sort_loop:
	beq     t0, a2, done_sorting # if t0 == numkeys, done sorting
	lw      t1, 0(s0)       # Load key from keys array
	addi    t3, t1, -1      # Decrement key to use as index
	slli    t3, t3, 2       # Multiply index by 4 (word size)
	lw      t4, 0(t2)       # Load cumulative count
	addi    t4, t4, -1      # Decrement to get the correct index in output
	sw      t1, 0(s1)       # Place key in output array
	sw      t4, 0(t2)       # Decrement the count
	addi    s0, s0, 4       # Move to next key
	addi    s1, s1, 4       # Move to next output position
	addi    t0, t0, 1       # Increment key index
	j       sort_loop

done_sorting:
	# Epilogue
	lw      ra, 12(sp)      # Restore return address
	lw      s0, 8(sp)       # Restore s0
	lw      s1, 4(sp)       # Restore s1
	lw      s2, 0(sp)       # Restore s2
	addi    sp, sp, 16      # Deallocate stack space
	jr      ra              # Return to the main program

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
