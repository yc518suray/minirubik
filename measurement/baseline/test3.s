	.bss
	.align 4

memory:
	.zero 3145728

	.text
	.global main

main:
	la		s0, memory
	li		s1, 0
	li		s2, 3145728
	li		t0, 1			# data to be written
loop:
	add		s3, s0, s1
	sb		t0, 0(s3)
	addi	s1, s1, 1
	bne		s1, s2, loop

	li		a7, 10
	ecall
