	.equ	DELAY, 1048576 # 2^20
	.equ	LED_MATRIX_0_USED_SIZE, 700

	.equ	ORANGE,	0x00FFA000
	.equ	WHITE,	0x00FFFFFF
	.equ	GREEN,	0x0000FF00
	.equ	YELLOW,	0x00FFFF00
	.equ	RED,	0x00FF0000
	.equ	BLUE,	0x000080FF
	.equ	BLACK,	0x00000000
	
	.data

	.align 4
facelet_colors:
	.word	BLACK, 	BLACK, 	WHITE, 	WHITE, 	BLACK, 	BLACK, 	BLACK, 	BLACK
	.word	BLACK, 	BLACK, 	WHITE, 	WHITE, 	BLACK, 	BLACK, 	BLACK, 	BLACK
	.word	ORANGE, ORANGE, GREEN, 	GREEN, 	RED, 	RED, 	BLUE,  	BLUE
	.word	ORANGE, ORANGE, GREEN, 	GREEN, 	RED, 	RED, 	BLUE,  	BLUE
	.word	BLACK,	BLACK,	YELLOW,	YELLOW,	BLACK,	BLACK,	BLACK,	BLACK
	.word	BLACK,	BLACK,	YELLOW,	YELLOW,	BLACK,	BLACK,	BLACK,	BLACK

	.align 4
R_side_facelet_set:
	.byte	27, 19, 11, 3, 22, 30, 43, 35
R_face_facelet_set:
	.byte	28, 20, 21, 29
B_side_facelet_set:
	.byte	19, 18, 17, 16, 23, 22, 21, 20
B_face_facelet_set:
	.byte	11, 10, 2, 3
D_side_facelet_set:
	.byte	42, 43, 29, 21, 3, 2, 16, 24
D_face_facelet_set:
	.byte	31, 30, 22, 23

	.align 4
divide_three_table:
	.byte	0, 0, 0, 1, 1, 1, 2, 2, 2, 3, 3, 3
	.byte	4, 4, 4, 5, 5, 5, 6, 6, 6, 7, 7, 7
modulo_three_table:
	.byte	0, 1, 2, 0, 1, 2, 0, 1, 2, 0, 1, 2

	.align 4
solution:
	.word	0x03020104
	.word	0x02000801
	.word	0x7F7F0503

	.text
	.global main

# ========== main ========== #
# variable mapping:
#
# s0 -> base of frame buffer
# s1 -> number of all LED elements
# s2 -> count of walked steps
# s3 -> x index of the current facelet
# s4 -> y idnex of the current facelet
# s5 -> base of facelet_colors
# s6 -> x coordinate of the current LED element
# s7 -> y coordinate of the current LED element
# s8 -> color of the current LED element
#
# a5 -> index of the current LED element
#
# note that x axis is along one row, and y axis is along one column
main:
	li		s0, LED_MATRIX_0_BASE
	li		s1, LED_MATRIX_0_USED_SIZE
	li		s2, 0
	la		s5, facelet_colors
start_render:
	li		s6, 0
	li		s7, 0
	li		a5, 0
fill_colors:
	li		a0, 0
	add		a1, s6, x0
	add		a2, s7, x0
	jal		ra, check_if_separator
	beqz	a0, get_facelet_color
	li		s8, BLACK
	jal		x0, fill_in_color
get_facelet_color:
	add		a0, s6, x0
	add		a1, s7, x0
	jal		ra, get_facelet_index
	add		s3, a0, x0
	add		s4, a1, x0
	slli	s4, s4, 3
	add		t3, s4, s3
	slli	t3, t3, 2
	add		t3, s5, t3
	lw		s8, 0(t3)		# get the facelet color
fill_in_color:
	slli	t3, a5, 2
	add		t3, s0, t3
	sw		s8, 0(t3)		# fill in the color
# update x and y index of the LED element
	addi	s6, s6, 1
	li		t3, LED_MATRIX_0_WIDTH
	blt		s6, t3, to_next_LED_element
	li		s6, 0
	addi	s7, s7, 1
to_next_LED_element:
	addi	a5, a5, 1
	blt		a5, s1, fill_colors
# delay for a while
	jal		ra, time_delay
# check if update the facelet colors
	la		a0, solution
	add		a0, a0, s2
	lbu		t3, 0(a0)
	li		t0, 9
	bge		t3, t0, exit_program
# update facelet colors
	addi	s2, s2, 1
	add		a2, t3, x0
	jal		ra, update_facelet_colors
	jal		x0, start_render
exit_program:
	li		a7, 10
	ecall

# === check_if_separator === #
# variable mapping:
# a0 -> the return value, 0 for NOT, 1 for YES
# a1 -> the x index of the LED element
# a2 -> the y index of the LED element
check_if_separator:
# check the x index
	li		t5, 8
	beq		a1, t5, is_separator
	li		t5, 17
	beq		a1, t5, is_separator
	li		t5, 26
	beq		a1, t5, is_separator
# check the y index
	li		t5, 6
	beq		a2, t5, is_separator
	li		t5, 13
	beq		a2, t5, is_separator
	li		a0, 0
	jal		x0, finish_check_if_separator
is_separator:
	li		a0, 1
finish_check_if_separator:
	ret

# ==== get_facelet_idnex === #
# variable mapping:
# a0 -> x coordinate of the current element, returned x index of facelet
# a1 -> y coordinate of the current element, returned y index of facelet
get_facelet_index:
# remove x offset caused by separators
	li		t3, 0
	li		t5, 8
	blt		a0, t5, remove_y_offset
	addi	t3, t3, 1
	li		t5, 17
	blt		a0, t5, remove_y_offset
	addi	t3, t3, 1
	li		t5, 26
	blt		a0, t5, remove_y_offset
	addi	t3, t3, 1
remove_y_offset:
	sub		a0, a0, t3		# x offset is removed
# remove y offset caused by separators
	li		t3, 0
	li		t5, 6
	blt		a1, t5, offset_removed
	addi	t3, t3, 1
	li		t5, 13
	blt		a1, t5, offset_removed
	addi	t3, t3, 1
offset_removed:
	sub		a1, a1, t3		# y offset is removed
	srli	a0, a0, 2		# x index /= 4
	la		t3, divide_three_table
	add		t3, a1, t3
	lbu		a1, 0(t3)		# y index /= 3
	ret

# ======= time_delay ======= #
# variable mapping:
time_delay:
	li		t0, DELAY
delay_loop:
	addi	t0, t0, -1
	blt		x0, t0, delay_loop
	ret

# == update_facelet_colors = #
# variable mapping:
# a0 -> several usages
# a1 -> several usages
# a2 -> move
update_facelet_colors:
	addi	sp, sp, -16		# save ra
	sw		ra, 12(sp)
# decompose the move
	la		t0, divide_three_table
	add		t0, t0, a2
	lbu		a3, 0(t0)		# a3 = move / 3 = face
	la		t0, modulo_three_table
	add		t0, t0, a2
	lbu		a4, 0(t0)		# a4 = move % 3 = turn
	addi	a4, a4, 1		# turn += 1
							# notice that a2 is free to use now
# load the correct base of facelet set
	li		t3, 0
	la		a0, R_side_facelet_set
	la		a1, R_face_facelet_set
	bge		t3, a3, perform_rotations
	addi	t3, t3, 1
	addi	a0, a0, 12
	addi	a1, a1, 12
	bge		t3, a3, perform_rotations
	addi	a0, a0, 12		# a0 = base of the "side" facelet set
	addi	a1, a1, 12		# a1 = base of the "face" facelet set
							# notice that a3 is free to use now
perform_rotations:
# rotate the side facelets
	li		a2, 0x7			# a2 = modulo 8 mask
	add		a3, a0, x0		# a3 = base of the "side" facelet set
	li		t6, 8
	jal		ra, rotate_colors
# rotate the face facelets
	li		a2, 0x3			# a2 = modulo 4 mask
	add		a3, a1, x0		# a3 = base of the "face" facelet set
	li		t6, 4
	jal		ra, rotate_colors
	lw		ra, 12(sp)
	addi	sp, sp, 16		# restore ra
	ret

# ====== rotate_colors ===== #
# variable mapping:
# a2 -> mask for modulo arithmetics
# a3 -> base of the facelet set
# a4 -> number of turns
# t6 -> size of the facelet set
rotate_colors:
	addi	sp, sp, -32		# create the color stack
	add		t0, sp, x0		# t0 = base of the color stack
	la		t1, facelet_colors
							# t1 = base of facelet_colors
	li		t2, 0
store_facelet_colors:
	add		t4, a3, t2
	lbu		t3, 0(t4)		# source facelet index
	slli	t3, t3, 2
	add		t4, t1, t3
	lw		t3, 0(t4)		# source facelet color
	slli	t4, t2, 2
	add		t4, t0, t4
	sw		t3, 0(t4)
	addi	t2, t2, 1
	blt		t2, t6, store_facelet_colors
	li		t2, 0
rotate_facelet_colors:
	slli	t4, t2, 2
	add		t4, t0, t4
	lw		t3, 0(t4)		# source facelet color
	li		t5, 4
	blt		t5, a2, double_the_stride
	add		t5, a4, x0		# t5 = number of turns
	jal		x0, stride_determined
double_the_stride:
	slli	t5, a4, 1		# t5 = number of turns * 2
stride_determined:
	add		t4, t2, t5
	and		t4, t4, a2		# modulo arithmetics
	add		t4, a3, t4
	lbu		t5, 0(t4)		# destination facelet index
	slli	t4, t5, 2
	add		t4, t1, t4
	sw		t3, 0(t4)
	addi	t2, t2, 1
	blt		t2, t6, rotate_facelet_colors
	addi	sp, sp, 32		# release the color stack
	ret
