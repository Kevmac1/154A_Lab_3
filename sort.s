##############################################################################
# File: sort.s
# Skeleton for ECE 154A
##############################################################################

	.data
student:
	.asciz "Student: Your Name Here\n"  # Replace with your name
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

key:	.word 268632064			# Provide the base address of array where input key is stored
output:	.word 268632144			# Provide the base address of array where sorted output will be stored
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
	lw	a0, 0(t0)             # Load base address of keys array
	la	t0, output
	lw	a1, 0(t0)             # Load base address of output array
	la	t0, numkeys
	lw	a2, 0(t0)             # Load numkeys
	la	t0, maxnumber
	lw	a3, 0(t0)             # Load maxnumber
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
	# Function Prologue
	addi	sp, sp, -16           # Allocate stack space for 4 registers
	sw ra, 12(sp)              # Save return address
	sw s0, 8(sp)               # Save s0
	sw s1, 4(sp)               # Save s1
	sw s2, 0(sp)               # Save s2

	# Load parameters
	mv s0, a0                  # s0 = base address of keys (a0)
	mv s1, a1                  # s1 = base address of output (a1)
	mv s2, a2                  # s2 = numkeys (a2)
	lw t0, maxnumber           # Load maxnumber

	# Initialize count array to 0
	addi t1, zero, 0           # t1 = 0 (index for count array)
	
	# Allocate space for count array
	la t3, count               # Load address for count array
init_count:
	sw zero, 0(t3)             # count[t1] = 0
	addi t3, t3, 4             # Move to the next count slot
	addi t1, t1, 1             # t1++
	bne t1, t0, init_count     # Repeat until t1 >= maxnumber + 1

	# Count occurrences of each key
	addi t1, zero, 0           # t1 = 0 (index for keys)
	
count_keys:
	lw t3, 0(s0)               # t3 = keys[t1]
	addi t4, t3, 0             # t4 = keys[t1]
	slli t4, t4, 2             # t4 = t4 * 4 (word offset)
	add t4, t4, t3             # Get address in count array
	lw t5, 0(t4)               # Load count[keys[t1]]
	addi t5, t5, 1             # Increment count
	sw t5, 0(t4)               # Store updated count
	addi s0, s0, 4             # Move to the next key
	addi t1, t1, 1             # t1++
	bne t1, s2, count_keys     # Repeat until t1 >= numkeys

	# Calculate the cumulative count
	addi t1, zero, 1           # t1 = 1 (start from index 1)
	t3 = count                 # Reset t3 to point to count array
	
cumulative_count:
	lw t5, 0(t3)               # Load count[t1]
	lw t6, -4(t3)              # Load count[t1-1]
	add t5, t5, t6             # count[t1] += count[t1 - 1]
	sw t5, 0(t3)               # Store updated count
	addi t3, t3, 4             # Move to the next count slot
	addi t1, t1, 1             # t1++
	bne t1, t0, cumulative_count # Repeat until t1 > maxnumber

	# Build the output array
	addi t1, zero, 0           # t1 = 0 (index for keys)
	
build_output:
	lw t3, 0(s0)               # Get keys[t1]
	addi t4, t3, 0             # t4 = keys[t1]
	slli t4, t4, 2             # t4 = keys[t1] * 4 (word offset)
	lw t5, 0(t4)               # Load count[keys[t1]]
	addi t5, t5, -1            # Decrement count[keys[t1]]
	sw t5, 0(t4)               # Update count[keys[t1]]
	sw t3, 0(s1 + t5)          # Place keys[t1] into the output array
	addi s0, s0, 4             # Move to the next key
	addi t1, t1, 1             # t1++
	bne t1, s2, build_output   # Repeat until t1 >= numkeys

	# Function Epilogue
	lw ra, 12(sp)               # Restore return address
	lw s0, 8(sp)                # Restore s0
	lw s1, 4(sp)                # Restore s1
	lw s2, 0(sp)                # Restore s2
	addi sp, sp, 16             # Deallocate stack space
	jr ra                       # Return from function


##################################
#Don't modify code below this line
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
	addi t0, t0, -1
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
	jal print

