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



######################### 
counting_sort:
    # Save return address and s-registers we'll use
    addi    sp, sp, -24
    sw      ra, 0(sp)
    sw      s0, 4(sp)      # for keys pointer
    sw      s1, 8(sp)      # for output pointer
    sw      s2, 12(sp)     # for numkeys
    sw      s3, 16(sp)     # for maxnumber
    sw      s4, 20(sp)     # for count array pointer

    # Save arguments in saved registers
    mv      s0, a0         # s0 = keys pointer
    mv      s1, a1         # s1 = output pointer
    mv      s2, a2         # s2 = numkeys
    mv      s3, a3         # s3 = maxnumber

    # Allocate space for count array on stack
    addi    s3, s3, 1      # maxnumber + 1
    slli    t0, s3, 2      # multiply by 4 to get bytes needed
    sub     sp, sp, t0     # allocate space on stack
    mv      s4, sp         # s4 = count array pointer

    # First loop: Initialize count array to 0
    mv      t0, zero       # n = 0
init_loop:
    bgt     t0, s3, init_done
    slli    t1, t0, 2      # t1 = n * 4
    add     t1, s4, t1     # t1 = address of count[n]
    sw      zero, 0(t1)    # count[n] = 0
    addi    t0, t0, 1      # n++
    j       init_loop
init_done:

    # Second loop: Count occurrences
    mv      t0, zero       # n = 0
count_loop:
    bge     t0, s2, count_done
    slli    t1, t0, 2      # t1 = n * 4
    add     t1, s0, t1     # t1 = address of keys[n]
    lw      t2, 0(t1)      # t2 = keys[n]
    slli    t1, t2, 2      # t1 = keys[n] * 4
    add     t1, s4, t1     # t1 = address of count[keys[n]]
    lw      t3, 0(t1)      # t3 = count[keys[n]]
    addi    t3, t3, 1      # count[keys[n]]++
    sw      t3, 0(t1)      # store updated count
    addi    t0, t0, 1      # n++
    j       count_loop
count_done:

    # Third loop: Cumulative sum
    li      t0, 1          # n = 1
sum_loop:
    bgt     t0, s3, sum_done
    slli    t1, t0, 2      # t1 = n * 4
    add     t1, s4, t1     # t1 = address of count[n]
    addi    t2, t1, -4     # t2 = address of count[n-1]
    lw      t3, 0(t1)      # t3 = count[n]
    lw      t4, 0(t2)      # t4 = count[n-1]
    add     t3, t3, t4     # count[n] = count[n] + count[n-1]
    sw      t3, 0(t1)      # store sum
    addi    t0, t0, 1      # n++
    j       sum_loop
sum_done:

    # Fourth loop: Build output array
    mv      t0, zero       # n = 0
build_loop:
    bge     t0, s2, build_done
    slli    t1, t0, 2      # t1 = n * 4
    add     t1, s0, t1     # t1 = address of keys[n]
    lw      t2, 0(t1)      # t2 = keys[n]
    slli    t1, t2, 2      # t1 = keys[n] * 4
    add     t1, s4, t1     # t1 = address of count[keys[n]]
    lw      t3, 0(t1)      # t3 = count[keys[n]]
    addi    t3, t3, -1     # count[keys[n]]--
    sw      t3, 0(t1)      # store decremented count
    slli    t4, t3, 2      # t4 = (count[keys[n]]-1) * 4
    add     t4, s1, t4     # t4 = address of output[count[keys[n]]-1]
    sw      t2, 0(t4)      # output[count[keys[n]]-1] = keys[n]
    addi    t0, t0, 1      # n++
    j       build_loop
build_done:

    # Restore stack and registers
    slli    t0, s3, 2      # size of count array
    add     sp, sp, t0     # deallocate count array
    lw      ra, 0(sp)
    lw      s0, 4(sp)
    lw      s1, 8(sp)
    lw      s2, 12(sp)
    lw      s3, 16(sp)
    lw      s4, 20(sp)
    addi    sp, sp, 24
    
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
