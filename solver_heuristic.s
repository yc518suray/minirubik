# Author: Raymond Su, q36141155@gs.ncku.edu.tw
#
# RISC-V assembly implementation of solver_heuristic.c
# The heuristic values of orientation and permutation are stored in table.s

	.equ	CUBIES, 7
	.equ	PERMUTATIONS, 5040
	.equ	ORIENTATIONS, 729
	.equ	MOVES, 9
	.equ	GOD_NUMBER, 11

	.data
	
	.align 2
	.global o_table

o_table:
    .byte 0, 5, 5, 4, 4, 5, 4, 6, 3, 6, 3, 4, 4, 3, 5, 5
    .byte 1, 5, 5, 4, 4, 5, 5, 3, 3, 5, 4, 4, 3, 6, 4, 5
    .byte 4, 5, 4, 4, 4, 4, 2, 3, 5, 4, 5, 5, 4, 5, 5, 4
    .byte 5, 4, 3, 5, 3, 5, 4, 5, 4, 5, 5, 5, 4, 4, 5, 5
    .byte 4, 5, 4, 5, 4, 5, 4, 5, 4, 4, 4, 5, 5, 5, 3, 4
    .byte 4, 5, 3, 5, 4, 5, 4, 5, 4, 5, 4, 4, 4, 4, 5, 5
    .byte 4, 4, 5, 4, 5, 5, 5, 4, 5, 4, 4, 5, 4, 5, 3, 5
    .byte 6, 5, 5, 4, 6, 4, 5, 5, 4, 5, 5, 6, 5, 4, 6, 5
    .byte 4, 5, 6, 4, 4, 5, 5, 6, 3, 4, 4, 5, 6, 4, 3, 5
    .byte 2, 5, 4, 5, 5, 5, 3, 5, 5, 5, 4, 5, 4, 5, 6, 5
    .byte 5, 5, 5, 5, 3, 6, 4, 3, 4, 3, 5, 4, 5, 5, 2, 5
    .byte 4, 5, 4, 5, 4, 5, 4, 4, 4, 4, 3, 5, 4, 5, 5, 4
    .byte 4, 5, 3, 5, 6, 4, 5, 5, 4, 5, 4, 5, 5, 5, 4, 4
    .byte 5, 5, 4, 4, 5, 5, 5, 5, 4, 4, 5, 4, 6, 5, 5, 5
    .byte 6, 6, 5, 4, 3, 4, 4, 5, 5, 6, 4, 6, 5, 5, 5, 5
    .byte 5, 4, 5, 5, 3, 5, 4, 4, 5, 4, 5, 5, 5, 4, 3, 3
    .byte 5, 4, 4, 5, 5, 6, 4, 3, 4, 4, 4, 4, 2, 5, 4, 4
    .byte 4, 4, 5, 4, 4, 4, 4, 4, 5, 5, 4, 3, 5, 5, 5, 5
    .byte 4, 5, 2, 4, 5, 3, 4, 5, 3, 4, 5, 5, 4, 5, 5, 3
    .byte 4, 4, 4, 5, 6, 4, 5, 4, 5, 3, 5, 4, 5, 5, 5, 4
    .byte 5, 4, 5, 4, 3, 3, 5, 3, 4, 4, 5, 5, 4, 4, 4, 5
    .byte 5, 4, 5, 4, 4, 3, 3, 5, 4, 4, 5, 3, 5, 2, 4, 4
    .byte 5, 4, 4, 4, 5, 5, 5, 5, 5, 4, 5, 4, 5, 4, 5, 4
    .byte 5, 5, 4, 5, 5, 5, 5, 4, 5, 5, 4, 5, 3, 4, 4, 5
    .byte 4, 4, 5, 4, 5, 5, 5, 3, 4, 3, 3, 4, 2, 3, 3, 5
    .byte 4, 4, 5, 5, 4, 5, 5, 2, 5, 4, 4, 5, 4, 4, 4, 4
    .byte 5, 5, 5, 2, 5, 5, 5, 4, 5, 4, 1, 5, 6, 5, 2, 5
    .byte 5, 4, 3, 4, 5, 4, 5, 5, 4, 5, 6, 3, 4, 4, 4, 4
    .byte 4, 5, 4, 4, 5, 3, 4, 5, 4, 4, 3, 5, 5, 5, 4, 5
    .byte 4, 5, 5, 6, 5, 4, 6, 5, 5, 5, 5, 4, 5, 5, 5, 5
    .byte 3, 5, 4, 5, 4, 4, 5, 5, 3, 4, 5, 5, 4, 4, 4, 5
    .byte 4, 5, 4, 5, 4, 5, 4, 4, 5, 4, 4, 5, 5, 4, 4, 5
    .byte 5, 4, 5, 5, 3, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 5
    .byte 5, 3, 4, 5, 6, 4, 5, 5, 5, 4, 4, 5, 4, 5, 4, 4
    .byte 5, 5, 4, 4, 5, 5, 4, 5, 5, 4, 6, 4, 4, 5, 4, 5
    .byte 6, 5, 6, 6, 5, 5, 4, 5, 2, 5, 5, 5, 5, 5, 3, 4
    .byte 3, 4, 5, 5, 4, 4, 3, 6, 6, 5, 5, 5, 5, 5, 6, 4
    .byte 4, 5, 5, 4, 4, 5, 6, 5, 5, 4, 5, 6, 5, 3, 4, 4
    .byte 5, 5, 5, 6, 5, 6, 4, 5, 5, 5, 6, 4, 4, 5, 4, 4
    .byte 4, 4, 5, 4, 4, 5, 4, 5, 4, 3, 4, 5, 5, 5, 5, 5
    .byte 5, 5, 4, 4, 5, 4, 4, 5, 3, 5, 3, 4, 3, 5, 4, 4
    .byte 5, 4, 5, 5, 5, 2, 4, 4, 3, 4, 3, 4, 4, 5, 3, 4
    .byte 5, 5, 4, 5, 4, 5, 4, 5, 4, 5, 5, 5, 4, 5, 5, 5
    .byte 5, 5, 6, 5, 4, 5, 6, 5, 4, 5, 3, 5, 5, 4, 3, 4
    .byte 4, 4, 5, 4, 4, 5, 4, 5, 6, 5, 4, 5, 5, 4, 4, 5
    .byte 5, 5, 4, 5, 4, 5, 3, 5, 5

	.align 2
	.global p_table

p_table:
    .byte 0, 7, 7, 6, 6, 6, 7, 5, 6, 1, 6, 6, 6, 6, 6, 6
    .byte 1, 6, 1, 6, 6, 7, 6, 5, 7, 3, 3, 6, 6, 6, 5, 5
    .byte 6, 6, 4, 4, 4, 5, 5, 4, 6, 5, 6, 4, 5, 5, 3, 5
    .byte 5, 5, 4, 6, 5, 4, 6, 4, 6, 4, 4, 5, 6, 5, 3, 4
    .byte 5, 5, 5, 5, 6, 5, 5, 4, 6, 4, 5, 5, 6, 3, 6, 4
    .byte 7, 6, 4, 4, 3, 6, 4, 4, 6, 5, 5, 5, 6, 6, 4, 3
    .byte 6, 4, 4, 5, 5, 5, 4, 5, 6, 6, 4, 4, 4, 5, 4, 5
    .byte 6, 5, 5, 4, 5, 5, 3, 5, 7, 4, 5, 5, 5, 5, 4, 5
    .byte 5, 6, 4, 5, 5, 4, 5, 5, 6, 5, 6, 5, 5, 5, 5, 6
    .byte 5, 5, 5, 6, 3, 5, 6, 5, 3, 4, 4, 6, 6, 2, 4, 5
    .byte 5, 6, 5, 5, 6, 3, 6, 5, 3, 4, 4, 5, 6, 6, 6, 6
    .byte 6, 3, 5, 4, 5, 5, 5, 5, 3, 5, 2, 5, 6, 5, 5, 6
    .byte 6, 5, 5, 2, 5, 5, 1, 6, 6, 5, 5, 6, 6, 5, 6, 5
    .byte 5, 2, 6, 6, 2, 5, 5, 6, 6, 5, 5, 7, 3, 4, 6, 5
    .byte 3, 5, 4, 5, 5, 2, 5, 5, 5, 6, 5, 5, 6, 3, 6, 4
    .byte 5, 5, 5, 3, 6, 5, 3, 4, 6, 6, 5, 5, 4, 6, 5, 5
    .byte 5, 3, 5, 6, 2, 7, 5, 4, 6, 5, 4, 5, 5, 6, 6, 5
    .byte 4, 6, 4, 4, 4, 5, 6, 4, 5, 5, 6, 3, 5, 5, 4, 5
    .byte 6, 4, 5, 5, 4, 6, 4, 6, 5, 5, 4, 4, 4, 5, 5, 5
    .byte 5, 4, 5, 5, 5, 5, 3, 6, 5, 4, 5, 6, 4, 5, 6, 6
    .byte 4, 4, 5, 5, 5, 4, 5, 6, 5, 6, 4, 6, 6, 3, 5, 5
    .byte 5, 6, 6, 3, 5, 6, 3, 5, 5, 6, 5, 5, 5, 6, 6, 5
    .byte 5, 3, 6, 5, 2, 5, 6, 5, 6, 5, 6, 5, 2, 5, 6, 6
    .byte 1, 6, 6, 5, 5, 2, 6, 5, 6, 5, 5, 5, 5, 2, 6, 5
    .byte 6, 5, 4, 6, 5, 3, 7, 4, 6, 6, 3, 5, 4, 6, 4, 3
    .byte 5, 6, 6, 4, 6, 6, 5, 3, 4, 6, 6, 3, 6, 5, 3, 5
    .byte 6, 5, 6, 5, 5, 6, 5, 6, 5, 3, 5, 5, 2, 6, 6, 4
    .byte 4, 5, 5, 5, 4, 6, 5, 5, 3, 5, 5, 4, 5, 4, 6, 4
    .byte 4, 5, 5, 5, 4, 4, 5, 5, 5, 5, 4, 6, 6, 5, 6, 5
    .byte 6, 5, 3, 5, 4, 5, 5, 4, 5, 6, 5, 4, 6, 6, 5, 6
    .byte 3, 4, 4, 6, 5, 6, 6, 5, 6, 3, 5, 4, 5, 6, 6, 5
    .byte 2, 6, 3, 5, 5, 5, 5, 6, 4, 4, 6, 5, 5, 4, 6, 3
    .byte 6, 5, 6, 4, 4, 6, 4, 5, 5, 5, 5, 5, 5, 6, 5, 4
    .byte 5, 4, 4, 5, 5, 5, 6, 6, 6, 5, 4, 4, 3, 6, 6, 3
    .byte 6, 6, 5, 3, 5, 6, 4, 5, 5, 5, 5, 6, 6, 2, 5, 2
    .byte 6, 4, 5, 6, 6, 5, 1, 6, 5, 5, 4, 6, 6, 5, 5, 2
    .byte 5, 3, 5, 5, 5, 6, 5, 6, 6, 5, 4, 4, 4, 5, 5, 5
    .byte 5, 4, 5, 5, 5, 5, 4, 6, 4, 6, 5, 3, 6, 5, 3, 4
    .byte 5, 5, 6, 5, 5, 5, 5, 5, 5, 3, 5, 6, 2, 6, 6, 4
    .byte 6, 4, 4, 5, 5, 5, 6, 5, 5, 7, 4, 3, 3, 6, 5, 3
    .byte 6, 6, 6, 3, 5, 6, 4, 6, 5, 4, 4, 6, 5, 5, 5, 5
    .byte 5, 5, 4, 5, 5, 5, 4, 5, 5, 5, 4, 5, 6, 4, 4, 5
    .byte 5, 5, 6, 5, 3, 5, 6, 6, 3, 5, 6, 4, 4, 4, 6, 6
    .byte 5, 6, 4, 6, 5, 4, 5, 6, 4, 6, 6, 3, 5, 5, 3, 4
    .byte 6, 5, 5, 5, 5, 6, 5, 6, 4, 3, 5, 6, 2, 6, 6, 5
    .byte 7, 5, 4, 5, 5, 5, 5, 6, 5, 6, 5, 5, 5, 5, 5, 5
    .byte 6, 4, 6, 5, 5, 4, 4, 5, 3, 7, 5, 5, 5, 5, 5, 5
    .byte 5, 4, 4, 6, 6, 6, 5, 4, 4, 5, 4, 4, 6, 6, 6, 4
    .byte 5, 5, 6, 4, 6, 4, 4, 4, 6, 5, 5, 5, 4, 5, 4, 6
    .byte 4, 4, 5, 6, 3, 6, 5, 3, 5, 4, 5, 6, 4, 6, 6, 5
    .byte 4, 5, 6, 4, 4, 3, 5, 5, 5, 6, 4, 5, 5, 4, 5, 6
    .byte 4, 6, 4, 6, 5, 4, 5, 5, 5, 5, 4, 6, 6, 6, 5, 4
    .byte 4, 6, 4, 3, 6, 6, 6, 5, 6, 5, 4, 4, 4, 5, 4, 5
    .byte 5, 7, 4, 4, 4, 5, 6, 3, 6, 5, 6, 4, 5, 5, 4, 5
    .byte 5, 6, 5, 4, 6, 3, 4, 4, 5, 4, 5, 6, 6, 6, 4, 5
    .byte 5, 4, 5, 4, 3, 5, 5, 4, 6, 3, 5, 5, 4, 6, 4, 5
    .byte 4, 5, 4, 4, 4, 3, 6, 5, 6, 4, 6, 5, 5, 4, 4, 6
    .byte 5, 5, 2, 7, 5, 5, 6, 6, 5, 5, 3, 5, 5, 5, 5, 3
    .byte 4, 6, 4, 3, 6, 4, 6, 5, 4, 5, 5, 5, 6, 3, 4, 4
    .byte 5, 3, 6, 6, 6, 5, 4, 6, 4, 4, 4, 5, 4, 6, 5, 4
    .byte 4, 4, 6, 5, 5, 5, 4, 6, 5, 4, 6, 5, 5, 6, 5, 7
    .byte 4, 5, 3, 6, 5, 5, 4, 5, 6, 5, 6, 5, 2, 5, 6, 5
    .byte 3, 5, 6, 4, 5, 3, 4, 6, 5, 6, 6, 5, 6, 3, 4, 5
    .byte 5, 5, 2, 5, 6, 6, 5, 6, 6, 4, 3, 5, 6, 6, 5, 3
    .byte 5, 5, 4, 3, 4, 5, 6, 6, 5, 3, 5, 3, 5, 5, 2, 6
    .byte 5, 5, 4, 4, 4, 5, 5, 5, 5, 3, 4, 5, 3, 4, 4, 6
    .byte 6, 4, 5, 6, 6, 5, 6, 5, 6, 6, 4, 4, 4, 5, 5, 4
    .byte 6, 6, 5, 5, 6, 5, 5, 4, 6, 4, 3, 5, 6, 6, 4, 5
    .byte 6, 6, 4, 4, 5, 5, 6, 4, 5, 5, 6, 4, 4, 5, 4, 6
    .byte 1, 6, 6, 5, 6, 6, 6, 5, 6, 2, 5, 5, 5, 5, 6, 5
    .byte 2, 5, 2, 6, 5, 6, 5, 5, 6, 4, 5, 5, 5, 4, 6, 5
    .byte 5, 7, 4, 4, 3, 5, 5, 4, 6, 6, 6, 4, 6, 6, 4, 4
    .byte 5, 5, 6, 7, 3, 4, 6, 4, 4, 4, 5, 4, 5, 4, 3, 5
    .byte 5, 6, 5, 6, 6, 4, 4, 4, 3, 5, 6, 5, 4, 4, 5, 3
    .byte 5, 4, 6, 5, 4, 5, 4, 5, 4, 5, 4, 6, 4, 5, 5, 4
    .byte 6, 5, 5, 5, 4, 4, 5, 4, 3, 6, 5, 6, 6, 4, 5, 5
    .byte 6, 5, 5, 6, 4, 4, 6, 4, 6, 5, 5, 2, 5, 5, 3, 6
    .byte 5, 7, 5, 5, 4, 5, 5, 4, 6, 3, 6, 4, 3, 6, 5, 5
    .byte 2, 5, 6, 5, 4, 4, 6, 3, 5, 3, 6, 5, 4, 5, 4, 5
    .byte 3, 6, 3, 5, 5, 5, 5, 4, 5, 5, 6, 4, 4, 5, 4, 5
    .byte 3, 5, 6, 6, 5, 4, 6, 6, 5, 3, 4, 5, 4, 4, 6, 5
    .byte 5, 6, 3, 4, 5, 6, 5, 6, 5, 5, 4, 5, 6, 5, 5, 4
    .byte 5, 5, 4, 4, 4, 4, 6, 5, 5, 4, 6, 5, 6, 5, 4, 5
    .byte 5, 5, 6, 5, 5, 5, 4, 6, 4, 5, 4, 5, 5, 5, 4, 5
    .byte 5, 6, 6, 5, 2, 5, 5, 4, 3, 5, 6, 5, 6, 3, 5, 5
    .byte 4, 6, 5, 5, 6, 3, 5, 4, 6, 6, 3, 4, 6, 6, 4, 5
    .byte 6, 5, 4, 5, 5, 6, 6, 4, 5, 4, 5, 4, 4, 5, 6, 5
    .byte 4, 3, 5, 4, 6, 4, 3, 5, 6, 4, 5, 4, 4, 5, 5, 6
    .byte 4, 4, 3, 6, 4, 5, 4, 5, 5, 4, 4, 5, 6, 5, 6, 5
    .byte 5, 6, 4, 4, 4, 6, 5, 3, 5, 6, 6, 4, 5, 6, 5, 4
    .byte 6, 5, 4, 4, 4, 5, 4, 5, 4, 6, 5, 4, 5, 4, 6, 5
    .byte 6, 4, 7, 4, 3, 5, 5, 5, 4, 4, 6, 5, 5, 5, 6, 4
    .byte 6, 5, 5, 4, 3, 6, 5, 6, 4, 6, 5, 6, 5, 5, 4, 5
    .byte 4, 6, 5, 3, 6, 6, 4, 5, 5, 4, 4, 5, 5, 6, 6, 5
    .byte 5, 4, 5, 4, 4, 5, 6, 5, 5, 6, 5, 5, 4, 4, 6, 4
    .byte 3, 5, 5, 6, 6, 4, 5, 4, 4, 5, 5, 4, 6, 4, 6, 4
    .byte 4, 5, 7, 5, 5, 5, 6, 4, 6, 5, 6, 5, 4, 5, 5, 6
    .byte 4, 5, 5, 6, 5, 5, 4, 5, 6, 5, 5, 5, 5, 4, 5, 4
    .byte 6, 5, 5, 5, 6, 5, 3, 6, 6, 5, 5, 5, 6, 5, 5, 4
    .byte 5, 6, 5, 3, 4, 6, 4, 6, 5, 4, 6, 5, 5, 5, 6, 6
    .byte 5, 4, 4, 5, 4, 5, 6, 6, 5, 6, 5, 5, 3, 4, 5, 5
    .byte 4, 5, 5, 5, 6, 4, 5, 4, 5, 5, 6, 5, 4, 4, 6, 5
    .byte 2, 5, 7, 5, 6, 5, 5, 4, 5, 3, 6, 5, 5, 5, 5, 6
    .byte 3, 4, 3, 6, 4, 5, 6, 5, 5, 5, 5, 3, 4, 6, 4, 5
    .byte 5, 5, 5, 5, 5, 5, 6, 5, 4, 4, 5, 4, 4, 5, 6, 6
    .byte 5, 5, 4, 6, 6, 5, 5, 6, 5, 5, 4, 5, 5, 5, 6, 5
    .byte 5, 5, 4, 5, 6, 5, 4, 6, 3, 6, 5, 4, 6, 5, 5, 6
    .byte 6, 4, 4, 6, 6, 5, 5, 4, 4, 5, 4, 4, 5, 6, 5, 5
    .byte 4, 3, 6, 4, 5, 5, 5, 4, 6, 5, 6, 3, 2, 6, 5, 5
    .byte 5, 5, 5, 5, 4, 6, 3, 5, 5, 5, 6, 5, 3, 4, 5, 4
    .byte 4, 4, 5, 5, 6, 4, 3, 6, 5, 5, 5, 6, 5, 4, 5, 4
    .byte 6, 4, 4, 6, 5, 4, 5, 5, 5, 6, 5, 5, 5, 4, 5, 5
    .byte 6, 5, 5, 5, 5, 5, 5, 5, 5, 6, 5, 4, 5, 5, 4, 6
    .byte 5, 4, 5, 6, 6, 5, 5, 6, 5, 5, 5, 6, 4, 4, 6, 6
    .byte 6, 4, 6, 4, 5, 4, 4, 4, 6, 5, 6, 4, 5, 6, 3, 6
    .byte 6, 5, 5, 5, 5, 6, 4, 4, 5, 4, 3, 6, 5, 4, 5, 5
    .byte 5, 5, 4, 5, 5, 4, 5, 4, 5, 5, 4, 4, 6, 5, 5, 5
    .byte 4, 3, 5, 4, 5, 5, 3, 6, 6, 4, 6, 4, 4, 6, 5, 6
    .byte 4, 4, 3, 6, 4, 5, 4, 6, 5, 6, 4, 4, 6, 5, 5, 4
    .byte 5, 4, 5, 5, 6, 5, 5, 5, 5, 5, 5, 5, 4, 5, 6, 5
    .byte 5, 4, 6, 6, 5, 4, 5, 5, 5, 5, 5, 5, 5, 4, 4, 6
    .byte 6, 5, 5, 6, 6, 5, 5, 5, 5, 4, 5, 5, 4, 6, 4, 6
    .byte 4, 5, 5, 5, 5, 3, 6, 5, 5, 5, 6, 6, 5, 4, 4, 7
    .byte 6, 6, 4, 4, 5, 4, 5, 5, 4, 5, 5, 5, 6, 5, 5, 5
    .byte 6, 5, 6, 4, 4, 5, 6, 5, 3, 6, 5, 4, 4, 6, 5, 5
    .byte 5, 4, 5, 6, 5, 5, 5, 4, 4, 5, 4, 5, 5, 5, 6, 5
    .byte 4, 4, 5, 5, 4, 5, 6, 4, 5, 5, 5, 4, 3, 5, 5, 4
    .byte 5, 6, 5, 5, 5, 5, 4, 5, 5, 5, 5, 5, 5, 6, 4, 6
    .byte 5, 6, 5, 6, 6, 4, 6, 6, 5, 5, 5, 6, 5, 5, 5, 7
    .byte 4, 6, 4, 5, 5, 4, 5, 5, 5, 5, 4, 6, 5, 4, 5, 5
    .byte 5, 5, 4, 5, 6, 5, 6, 5, 4, 4, 5, 5, 5, 5, 6, 4
    .byte 6, 5, 6, 4, 3, 6, 5, 5, 5, 6, 5, 6, 5, 6, 4, 5
    .byte 6, 6, 6, 4, 4, 5, 5, 5, 4, 5, 5, 5, 5, 5, 4, 5
    .byte 6, 4, 6, 6, 4, 5, 6, 5, 5, 4, 4, 7, 5, 3, 6, 4
    .byte 4, 5, 4, 5, 5, 4, 4, 4, 5, 6, 4, 5, 6, 5, 5, 4
    .byte 5, 6, 5, 6, 4, 3, 6, 3, 5, 4, 5, 5, 5, 4, 2, 5
    .byte 5, 6, 5, 6, 7, 5, 5, 3, 6, 5, 6, 2, 5, 5, 1, 6
    .byte 6, 5, 5, 6, 6, 6, 5, 6, 5, 2, 5, 6, 2, 5, 5, 5
    .byte 5, 5, 5, 6, 3, 4, 6, 4, 2, 6, 5, 6, 5, 3, 5, 4
    .byte 5, 5, 5, 5, 5, 3, 6, 4, 2, 6, 5, 5, 5, 6, 5, 5
    .byte 6, 3, 4, 6, 6, 6, 6, 5, 3, 4, 3, 4, 4, 6, 5, 6
    .byte 5, 6, 3, 6, 5, 5, 5, 4, 5, 4, 4, 6, 7, 5, 4, 4
    .byte 4, 5, 4, 4, 5, 4, 6, 5, 5, 6, 5, 4, 3, 6, 5, 6
    .byte 2, 5, 5, 5, 5, 3, 7, 5, 6, 4, 5, 4, 5, 3, 5, 6
    .byte 7, 4, 4, 6, 6, 4, 6, 5, 6, 6, 3, 4, 3, 5, 5, 3
    .byte 6, 5, 6, 4, 5, 6, 4, 4, 5, 6, 5, 4, 5, 5, 4, 4
    .byte 6, 6, 5, 5, 6, 6, 5, 5, 5, 4, 6, 4, 3, 5, 6, 4
    .byte 5, 5, 5, 5, 4, 5, 5, 4, 3, 5, 5, 4, 5, 4, 5, 4
    .byte 4, 5, 5, 4, 4, 4, 5, 5, 4, 5, 5, 5, 5, 6, 6, 5
    .byte 5, 5, 4, 5, 4, 5, 5, 4, 4, 6, 4, 5, 5, 6, 5, 6
    .byte 3, 6, 5, 6, 4, 5, 6, 4, 5, 4, 4, 6, 6, 5, 5, 4
    .byte 4, 5, 4, 4, 5, 5, 6, 4, 4, 5, 5, 5, 5, 6, 6, 5
    .byte 5, 4, 6, 4, 4, 4, 5, 6, 4, 6, 3, 5, 6, 5, 4, 5
    .byte 5, 5, 4, 6, 4, 4, 5, 4, 4, 4, 3, 6, 6, 3, 3, 4
    .byte 5, 5, 4, 4, 6, 4, 5, 4, 6, 3, 5, 6, 5, 4, 6, 4
    .byte 6, 5, 4, 3, 2, 6, 5, 4, 6, 6, 6, 5, 5, 6, 3, 5
    .byte 4, 6, 6, 6, 3, 4, 5, 3, 4, 5, 6, 5, 6, 4, 4, 5
    .byte 4, 6, 5, 5, 6, 4, 5, 4, 4, 3, 5, 6, 5, 4, 5, 4
    .byte 6, 4, 6, 4, 4, 5, 3, 6, 4, 5, 3, 6, 6, 6, 4, 4
    .byte 5, 5, 6, 4, 3, 6, 3, 6, 4, 4, 5, 5, 5, 4, 6, 6
    .byte 4, 4, 5, 5, 4, 4, 4, 7, 5, 5, 5, 5, 4, 5, 6, 4
    .byte 3, 5, 5, 4, 4, 4, 5, 5, 4, 6, 5, 4, 5, 4, 5, 5
    .byte 6, 5, 5, 4, 6, 5, 5, 4, 6, 6, 5, 6, 6, 5, 5, 4
    .byte 6, 5, 6, 4, 4, 5, 5, 4, 5, 4, 6, 6, 6, 4, 5, 5
    .byte 5, 5, 6, 4, 4, 6, 5, 6, 5, 5, 4, 5, 6, 5, 3, 5
    .byte 6, 5, 6, 4, 3, 5, 3, 5, 4, 5, 5, 5, 5, 4, 5, 6
    .byte 5, 4, 5, 6, 4, 4, 4, 5, 4, 4, 5, 6, 5, 3, 5, 3
    .byte 5, 4, 4, 5, 5, 4, 2, 5, 4, 5, 3, 5, 6, 5, 5, 3
    .byte 5, 4, 5, 5, 4, 6, 5, 6, 4, 5, 5, 5, 5, 3, 6, 6
    .byte 5, 5, 4, 6, 6, 4, 4, 6, 5, 6, 6, 4, 4, 6, 3, 5
    .byte 5, 4, 6, 6, 5, 5, 6, 5, 4, 4, 4, 6, 4, 5, 5, 6
    .byte 6, 6, 4, 5, 5, 4, 6, 5, 5, 5, 5, 7, 6, 4, 4, 5
    .byte 6, 5, 6, 5, 5, 4, 6, 5, 4, 5, 5, 6, 4, 4, 6, 4
    .byte 4, 5, 4, 5, 4, 4, 4, 4, 5, 7, 5, 5, 6, 5, 5, 3
    .byte 6, 4, 6, 6, 4, 4, 5, 5, 4, 5, 5, 5, 4, 3, 5, 6
    .byte 6, 5, 5, 6, 6, 4, 4, 5, 5, 5, 5, 3, 6, 5, 2, 5
    .byte 5, 4, 6, 6, 6, 6, 4, 6, 5, 3, 4, 6, 3, 6, 5, 5
    .byte 4, 6, 4, 5, 5, 5, 6, 5, 4, 5, 4, 5, 6, 5, 5, 4
    .byte 4, 6, 5, 3, 5, 5, 6, 4, 5, 4, 6, 5, 4, 7, 6, 6
    .byte 3, 5, 6, 4, 3, 4, 6, 5, 6, 6, 5, 5, 5, 4, 4, 6
    .byte 4, 4, 6, 5, 6, 4, 4, 5, 6, 4, 6, 4, 4, 6, 5, 6
    .byte 4, 4, 3, 5, 5, 5, 3, 5, 6, 5, 5, 6, 3, 5, 6, 5
    .byte 3, 5, 6, 4, 5, 2, 4, 6, 6, 5, 5, 6, 5, 3, 4, 5
    .byte 5, 6, 2, 6, 6, 5, 6, 5, 6, 4, 3, 5, 6, 5, 4, 3
    .byte 5, 6, 4, 3, 5, 5, 6, 5, 6, 4, 4, 4, 4, 5, 3, 6
    .byte 4, 5, 3, 5, 5, 4, 5, 4, 6, 4, 5, 4, 4, 3, 4, 6
    .byte 6, 3, 5, 5, 5, 5, 5, 4, 5, 6, 5, 4, 4, 5, 4, 5
    .byte 5, 6, 6, 6, 5, 6, 4, 4, 4, 6, 5, 4, 5, 5, 5, 5
    .byte 5, 4, 4, 5, 6, 6, 5, 5, 3, 5, 4, 5, 5, 5, 6, 4
    .byte 6, 5, 3, 6, 5, 4, 6, 5, 5, 5, 4, 5, 6, 5, 4, 4
    .byte 5, 5, 5, 4, 6, 4, 5, 4, 4, 4, 5, 6, 4, 5, 6, 5
    .byte 5, 4, 5, 5, 5, 5, 4, 5, 4, 5, 3, 6, 6, 5, 4, 5
    .byte 6, 6, 5, 4, 5, 4, 5, 3, 6, 6, 5, 5, 5, 5, 4, 4
    .byte 5, 5, 6, 5, 4, 6, 6, 4, 6, 4, 4, 5, 4, 5, 5, 6
    .byte 4, 5, 4, 5, 5, 4, 5, 5, 6, 4, 5, 5, 5, 3, 5, 6
    .byte 5, 6, 6, 4, 5, 4, 4, 4, 4, 5, 6, 5, 5, 5, 5, 5
    .byte 6, 4, 6, 5, 3, 4, 6, 5, 6, 5, 4, 3, 4, 5, 4, 6
    .byte 5, 6, 4, 5, 4, 5, 6, 3, 6, 4, 5, 4, 4, 5, 5, 6
    .byte 3, 6, 5, 5, 3, 5, 6, 4, 4, 4, 5, 5, 5, 4, 5, 4
    .byte 4, 6, 4, 5, 6, 4, 6, 5, 5, 5, 5, 4, 3, 5, 5, 5
    .byte 2, 6, 5, 5, 5, 3, 6, 5, 6, 4, 5, 4, 4, 3, 6, 6
    .byte 4, 5, 4, 3, 5, 6, 4, 6, 5, 4, 5, 4, 5, 6, 6, 5
    .byte 4, 4, 3, 5, 4, 5, 5, 5, 5, 4, 5, 5, 4, 5, 5, 5
    .byte 5, 6, 5, 4, 3, 5, 5, 5, 6, 6, 6, 4, 5, 5, 4, 4
    .byte 5, 4, 6, 5, 4, 3, 6, 4, 3, 6, 6, 5, 5, 4, 4, 5
    .byte 6, 5, 5, 6, 5, 4, 5, 4, 6, 4, 5, 2, 6, 5, 1, 6
    .byte 6, 5, 5, 5, 5, 5, 5, 6, 6, 2, 5, 6, 2, 5, 4, 6
    .byte 5, 5, 3, 6, 6, 6, 6, 6, 5, 4, 4, 4, 5, 5, 6, 4
    .byte 4, 6, 4, 4, 5, 6, 5, 5, 4, 5, 5, 5, 5, 6, 6, 6
    .byte 4, 5, 5, 5, 4, 5, 6, 4, 5, 5, 5, 4, 5, 5, 5, 5
    .byte 2, 5, 6, 5, 5, 5, 5, 4, 6, 3, 6, 5, 4, 6, 5, 5
    .byte 3, 5, 3, 5, 4, 6, 5, 4, 6, 4, 2, 6, 6, 5, 5, 4
    .byte 6, 6, 3, 5, 5, 5, 5, 3, 5, 6, 5, 3, 6, 6, 4, 5
    .byte 4, 5, 5, 6, 4, 4, 5, 5, 5, 3, 4, 5, 6, 5, 4, 5
    .byte 4, 6, 4, 5, 6, 5, 5, 5, 6, 4, 5, 6, 6, 3, 5, 4
    .byte 6, 6, 5, 5, 4, 6, 4, 5, 6, 6, 5, 4, 5, 5, 4, 4
    .byte 6, 4, 4, 5, 6, 5, 4, 5, 6, 6, 5, 5, 5, 5, 4, 5
    .byte 6, 5, 5, 5, 5, 5, 4, 5, 6, 5, 4, 4, 6, 5, 4, 4
    .byte 5, 6, 4, 6, 6, 5, 5, 5, 5, 4, 6, 5, 5, 6, 5, 5
    .byte 3, 4, 6, 4, 5, 5, 4, 5, 5, 4, 6, 4, 3, 6, 5, 5
    .byte 4, 4, 4, 5, 3, 6, 4, 4, 4, 4, 3, 6, 6, 6, 5, 6
    .byte 6, 5, 3, 5, 5, 6, 6, 4, 5, 5, 5, 4, 6, 6, 4, 5
    .byte 5, 6, 5, 5, 4, 4, 5, 5, 4, 4, 5, 6, 6, 4, 4, 6
    .byte 5, 6, 5, 6, 6, 3, 6, 5, 4, 5, 6, 3, 5, 5, 4, 4
    .byte 6, 5, 6, 5, 4, 6, 5, 5, 4, 4, 5, 5, 4, 6, 5, 5
    .byte 5, 5, 4, 3, 5, 5, 4, 4, 5, 5, 3, 6, 6, 5, 5, 4
    .byte 6, 4, 6, 4, 4, 4, 6, 5, 3, 6, 4, 6, 5, 4, 6, 5
    .byte 5, 3, 5, 6, 6, 5, 5, 5, 3, 6, 2, 5, 6, 4, 5, 5
    .byte 6, 3, 5, 6, 4, 4, 5, 4, 5, 6, 6, 4, 4, 5, 3, 6
    .byte 5, 5, 5, 6, 6, 5, 4, 4, 5, 4, 5, 5, 3, 6, 5, 6
    .byte 4, 6, 5, 4, 3, 4, 6, 5, 5, 5, 6, 4, 4, 4, 4, 5
    .byte 5, 6, 5, 6, 4, 5, 6, 4, 3, 5, 5, 6, 5, 4, 5, 4
    .byte 5, 5, 4, 5, 6, 4, 6, 5, 5, 6, 6, 4, 5, 6, 4, 5
    .byte 5, 5, 6, 5, 5, 4, 5, 6, 4, 4, 5, 6, 3, 4, 6, 6
    .byte 6, 3, 5, 5, 6, 4, 5, 4, 7, 5, 6, 4, 4, 6, 3, 5
    .byte 6, 5, 5, 5, 6, 6, 3, 4, 6, 5, 3, 5, 5, 4, 5, 5
    .byte 5, 5, 4, 6, 6, 4, 5, 4, 6, 4, 5, 4, 5, 4, 5, 5
    .byte 5, 3, 5, 5, 4, 5, 4, 6, 5, 4, 5, 4, 4, 5, 6, 6
    .byte 5, 5, 4, 5, 5, 5, 4, 6, 5, 6, 4, 4, 5, 5, 4, 4
    .byte 6, 5, 5, 5, 5, 6, 5, 5, 6, 5, 6, 5, 4, 5, 6, 5
    .byte 6, 4, 5, 5, 4, 5, 6, 6, 4, 5, 5, 4, 3, 5, 6, 5
    .byte 5, 6, 6, 4, 5, 5, 4, 6, 5, 6, 5, 6, 4, 4, 5, 4
    .byte 3, 6, 5, 6, 6, 4, 5, 4, 5, 5, 6, 5, 5, 4, 7, 4
    .byte 4, 5, 5, 4, 4, 5, 3, 6, 5, 4, 6, 5, 6, 5, 5, 6
    .byte 4, 4, 3, 6, 4, 5, 6, 6, 6, 4, 2, 5, 6, 6, 4, 5
    .byte 6, 6, 3, 5, 5, 5, 6, 3, 5, 5, 6, 3, 5, 5, 4, 6
    .byte 4, 4, 4, 6, 5, 4, 6, 5, 5, 5, 3, 5, 5, 4, 4, 4
    .byte 5, 6, 4, 4, 7, 5, 5, 4, 6, 6, 4, 5, 5, 5, 5, 4
    .byte 4, 6, 5, 6, 6, 5, 5, 4, 5, 4, 6, 5, 5, 5, 5, 4
    .byte 4, 3, 6, 4, 4, 6, 4, 5, 5, 5, 6, 3, 2, 5, 6, 5
    .byte 5, 4, 5, 5, 3, 5, 3, 5, 3, 5, 4, 5, 5, 6, 6, 5
    .byte 6, 4, 4, 6, 5, 6, 6, 3, 4, 5, 4, 3, 6, 6, 5, 5
    .byte 6, 5, 5, 4, 5, 3, 5, 4, 4, 5, 6, 6, 6, 4, 4, 5
    .byte 6, 5, 6, 6, 5, 4, 6, 4, 5, 6, 6, 4, 5, 6, 4, 5
    .byte 6, 5, 7, 5, 5, 5, 6, 6, 4, 5, 5, 6, 5, 5, 6, 5
    .byte 5, 4, 3, 5, 5, 5, 5, 6, 5, 5, 4, 5, 5, 5, 5, 4
    .byte 5, 4, 4, 4, 5, 4, 5, 6, 3, 6, 5, 4, 5, 6, 5, 6
    .byte 5, 4, 4, 6, 6, 6, 6, 4, 4, 4, 4, 4, 5, 5, 7, 5
    .byte 5, 5, 6, 4, 6, 3, 5, 2, 6, 6, 6, 5, 4, 6, 3, 5
    .byte 5, 5, 6, 6, 5, 6, 5, 3, 5, 5, 6, 5, 4, 6, 6, 6
    .byte 4, 4, 6, 4, 4, 4, 5, 5, 5, 6, 4, 5, 5, 5, 4, 6
    .byte 4, 6, 4, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 6, 5, 4
    .byte 5, 6, 5, 4, 6, 6, 6, 4, 5, 3, 5, 6, 5, 5, 5, 5
    .byte 6, 5, 6, 4, 4, 5, 4, 6, 5, 5, 4, 6, 6, 6, 4, 5
    .byte 5, 5, 6, 4, 3, 5, 4, 6, 4, 5, 6, 6, 6, 4, 5, 6
    .byte 5, 4, 6, 5, 4, 4, 5, 6, 4, 5, 5, 5, 4, 5, 6, 4
    .byte 4, 5, 5, 4, 4, 5, 5, 5, 5, 6, 5, 4, 5, 5, 5, 5
    .byte 6, 5, 4, 4, 6, 6, 4, 5, 6, 6, 4, 6, 6, 5, 5, 5
    .byte 7, 4, 6, 4, 5, 5, 5, 5, 5, 3, 5, 6, 6, 4, 5, 5
    .byte 6, 5, 6, 4, 4, 6, 4, 6, 5, 5, 4, 5, 6, 6, 4, 5
    .byte 4, 6, 5, 5, 4, 4, 5, 4, 5, 3, 5, 6, 5, 4, 3, 6
    .byte 4, 6, 4, 6, 6, 4, 5, 4, 5, 4, 6, 3, 6, 5, 2, 5
    .byte 7, 5, 5, 5, 5, 6, 4, 5, 6, 3, 5, 5, 3, 6, 5, 4
    .byte 4, 5, 5, 6, 4, 4, 7, 4, 3, 5, 5, 5, 4, 4, 5, 4
    .byte 5, 6, 4, 5, 6, 4, 5, 4, 3, 5, 5, 4, 4, 5, 4, 6
    .byte 5, 4, 5, 5, 5, 5, 6, 6, 4, 3, 4, 5, 4, 5, 4, 6
    .byte 5, 6, 3, 6, 6, 4, 6, 4, 6, 4, 4, 5, 6, 5, 3, 4
    .byte 5, 6, 4, 4, 5, 5, 5, 4, 4, 5, 6, 5, 4, 6, 5, 5
    .byte 3, 5, 5, 5, 4, 4, 6, 5, 5, 5, 5, 5, 4, 4, 5, 6
    .byte 6, 4, 3, 6, 5, 4, 5, 5, 5, 6, 4, 5, 4, 4, 5, 4
    .byte 6, 5, 5, 4, 5, 5, 4, 5, 6, 5, 5, 5, 4, 5, 4, 5
    .byte 5, 6, 6, 6, 6, 5, 4, 6, 5, 4, 5, 5, 4, 5, 5, 5
    .byte 5, 5, 4, 4, 4, 6, 5, 5, 4, 6, 4, 5, 4, 5, 6, 4
    .byte 5, 5, 6, 3, 5, 5, 5, 5, 4, 4, 5, 6, 5, 6, 5, 5
    .byte 4, 4, 5, 5, 5, 4, 5, 5, 5, 5, 4, 6, 6, 5, 5, 6
    .byte 4, 6, 4, 6, 5, 5, 5, 4, 5, 5, 5, 6, 6, 6, 5, 5
    .byte 4, 5, 5, 4, 5, 5, 7, 5, 4, 4, 6, 5, 6, 5, 6, 5
    .byte 6, 5, 6, 4, 3, 5, 4, 6, 4, 6, 4, 6, 5, 6, 4, 5
    .byte 4, 5, 4, 5, 5, 5, 6, 5, 5, 5, 3, 6, 6, 4, 4, 4
    .byte 5, 6, 5, 4, 6, 5, 6, 5, 6, 4, 5, 6, 5, 4, 5, 4
    .byte 5, 5, 5, 4, 3, 5, 4, 5, 6, 5, 6, 6, 5, 6, 4, 5
    .byte 4, 7, 5, 5, 3, 5, 5, 4, 4, 4, 5, 6, 6, 4, 4, 5
    .byte 4, 6, 5, 4, 5, 4, 6, 5, 5, 3, 4, 6, 5, 5, 5, 5
    .byte 5, 5, 5, 4, 4, 4, 4, 5, 5, 5, 4, 5, 6, 5, 4, 5
    .byte 4, 6, 5, 5, 3, 5, 4, 5, 4, 5, 5, 6, 6, 4, 6, 5
    .byte 5, 4, 5, 4, 5, 4, 5, 6, 5, 4, 5, 4, 5, 6, 5, 5
    .byte 4, 5, 6, 4, 3, 5, 6, 5, 5, 5, 5, 5, 5, 5, 4, 6
    .byte 6, 5, 4, 5, 5, 5, 4, 5, 5, 5, 5, 6, 6, 4, 4, 5
    .byte 6, 5, 6, 5, 5, 4, 5, 5, 6, 4, 6, 5, 7, 4, 4, 5
    .byte 6, 6, 5, 5, 5, 6, 4, 5, 6, 5, 5, 5, 5, 6, 4, 5
    .byte 5, 6, 6, 5, 4, 5, 4, 5, 5, 5, 5, 6, 6, 5, 4, 5
    .byte 4, 4, 5, 5, 5, 5, 5, 5, 4, 4, 4, 5, 6, 4, 4, 4
    .byte 6, 4, 5, 5, 5, 5, 3, 5, 4, 5, 3, 5, 5, 6, 5, 4
    .byte 5, 4, 6, 6, 4, 6, 6, 5, 3, 5, 6, 5, 5, 4, 5, 5
    .byte 5, 6, 5, 6, 6, 4, 5, 5, 4, 6, 5, 4, 5, 5, 4, 4
    .byte 5, 5, 6, 5, 5, 6, 5, 6, 5, 5, 5, 5, 4, 6, 6, 5
    .byte 5, 5, 5, 5, 4, 4, 6, 5, 4, 4, 5, 6, 5, 3, 5, 6
    .byte 5, 6, 5, 6, 6, 4, 6, 5, 5, 5, 5, 5, 4, 5, 5, 5
    .byte 5, 6, 5, 5, 4, 5, 5, 4, 6, 6, 6, 5, 5, 5, 5, 4
    .byte 5, 4, 6, 6, 5, 4, 6, 5, 4, 6, 6, 5, 4, 4, 5, 5
    .byte 6, 6, 6, 5, 6, 5, 4, 5, 6, 5, 5, 3, 6, 5, 2, 6
    .byte 5, 5, 5, 6, 6, 5, 5, 6, 6, 3, 5, 5, 3, 5, 5, 6
    .byte 5, 5, 4, 6, 5, 6, 6, 5, 5, 5, 5, 5, 6, 6, 6, 5
    .byte 4, 7, 5, 4, 6, 6, 5, 5, 4, 5, 6, 4, 5, 6, 5, 5
    .byte 4, 5, 5, 5, 4, 5, 6, 5, 5, 5, 5, 5, 4, 5, 5, 6
	
	.data
	.align 4
input:
	.asciz	"21345671111111"

move1:
	.asciz	"R"
move2:
	.asciz	"R2"
move3:
	.asciz	"R'"
move4:
	.asciz	"B"
move5:
	.asciz	"B2"
move6:
	.asciz	"B'"
move7:
	.asciz	"D"
move8:
	.asciz	"D2"
move9:
	.asciz	"D'"
separator:
	.asciz	" "

	.align 4
move_names:
	.word 	move1
	.word 	move2
	.word 	move3
	.word 	move4
	.word 	move5
	.word 	move6
	.word 	move7
	.word 	move8
	.word	move9
	.word 	separator

	.align 4
o_vector:
	.word	0
	.word	0
p_vector:
	.word	0
	.word	0
solution:
	.word	0x7F7F7F7F
	.word	0x7F7F7F7F
	.word	0x7F7F7F7F

	.align 4
o_base_values:
	.word	1
	.word	3
	.word	9
	.word	27
	.word	81
	.word	243

p_base_values:
	.word	1
	.word	2
	.word	6
	.word	24
	.word	120
	.word	720

	.align 4
modulo_three_table:
	.byte 0, 1, 2, 0, 1, 2, 0, 1, 2

	.align 4
move_o_table:
	.byte 1, 2, 0, 2, 1, 0, 0, -1
	.byte 0, 0, 0, 1, 2, 1, 2, -1
	.byte 0, 0, 0, 0, 0, 0, 0, -1
move_p_table:
	.byte 1, 4, 2, 0, 3, 5, 6, -1
	.byte 0, 1, 2, 4, 5, 6, 3, -1
	.byte 0, 2, 5, 3, 1, 4, 6, -1

	.text
	.global main

# ========== main ========== #
# variable mapping:
main:
# stage 1: parse the input
	jal		ra, parse_input

# stage 2: IDA* search
	jal 	ra, IDA_Star_search

# stage 3: print solution
	la		a1, move_names
	la		a2, solution
	jal		ra, print_solution

# stage 4: render LED matrix

# stage 5: exit the program
	li 		a7, 10
	ecall

# ======= parse_input ====== #
parse_input:
	la		t0, input	# base of the input string
	li		t1, 14		# number of characters to parse
	li		t2, 0		# index
keep_parsing:
	add		t4, t0, t2
	lbu		t3, 0(t4)	# get the ascii character
	addi	t6, t3, -48	# the integer to store
	li		t3, 6
	blt		t3, t2, parse_o_vector
	la		t4, p_vector
	add		t5, t2, x0
store_parsed:
	add		t4, t4, t5	# positioning the destination byte
	sb		t6, 0(t4)	# store the byte
	jal		x0, parse_loop
parse_o_vector:
	la		t4, o_vector
	addi	t5, t2, -7
	jal		x0, store_parsed
parse_loop:
	addi	t2, t2, 1
	bne		t2, t1, keep_parsing
	ret

# ======= IDA* search ====== #
# variable mapping:
# s0 -> base of o_table
# s1 -> base of p_table
# s2 -> threshold
# s3 -> next_threshold
# s4 -> top
# s5 -> move
# s6 -> rank
# s7 -> path_stack (base)
# s8 -> count_stack (base)
# s9 -> move_stack (base)
# s10 -> o state of the current state
# s11 -> p state of the current state
# a3 -> return value, 0 for solved, 1 for not solved
IDA_Star_search:
# save ra to return to main
	addi	sp, sp, -16
	sw		ra, 12(sp)
# load o state of root state
	la		a1, o_vector
	jal		ra, load_vector
	addi	s10, a0, 0
# load p state of root state
	la		a1, p_vector
	jal		ra, load_vector
	addi	s11, a0, 0
# ----- initializations ----- #
	la		s0, o_table
	la		s1, p_table
	li		s2, 0			# threshold = 0
# create stack
	addi	sp, sp, -16
	add		s8, x0, sp		# space for count_stack
	addi	sp, sp, -16
	add		s9, x0, sp		# space for move_stack
	addi	sp, sp, -96
	add		s7, x0, sp		# space for path_stack
# compute rank of root state
	li		a0, 0
	add		a1, s10, x0
	jal		ra, get_o_rank
	add		a1, s11, x0
	jal		ra, get_p_rank
	add		s6, a0, x0		# s6 = rank of root state
	bnez	s6, not_trivial_solution
	li		a3, 0			# solved
	jal		x0, finish_search
not_trivial_solution:
	sw		s10, 0(s7)
	addi	t0, s7, 4
	sw		s11, 0(t0)		# path_stack[0] = root state
	sb		x0, 0(s9)		# move_stack[0] = 0
# compute the initial threshold
	la		t4, o_table
	li		t0, 0x0000FFFF
	and		t3, s6, t0
	add		t4, t4, t3
	lbu		t5, 0(t4)		# t5 = table value of o
	la		t4, p_table
	srli	t3, s6, 16
	add		t4, t4, t3
	lbu		t6, 0(t4)		# t6 = table value of p
	blt		t5, t6, take_p_value
	add		s2, t5, x0
	jal		x0, DFS_loop
take_p_value:
	add		s2, t6, x0
# ----- start iteration ----- #
DFS_loop:
	li		s3, 0x7FFFFFFF	# next_threshold = maximum positive number
	li		s5, 0			# move = 0
	li		s4, 1			# top = 1
	lw		s10, 0(s7)		# o state = root o state
	addi	t0, s7, 4
	lw		s11, 0(t0)		# p state = root p state
# fill zeros into count_stack
	add		a0, x0, s8
	jal		ra, fill_z_count_stack
# ------ for each move ------ #
move_loop:
# move to next state
	add		a1, s10, x0
	add		a2, s11, x0
	add		a4, s5, x0
	jal		ra, apply_move
	add		s10, a1, x0
	add		s11, a2, x0
# update the stacks
	slli	t1, s4, 3
	add		t1, s7, t1
	sw		s10, 0(t1)
	addi	t1, t1, 4
	sw		s11, 0(t1)		# path_stack[top] = current state
	add		t1, s8, s4
	lbu		t2, 0(t1)
	addi	t2, t2, 1
	sb		t2, 0(t1)		# count_stack[top] += 1
	add		t1, s9, s4
	sb		s5, 0(t1)		# move_stack[top] = move
# compute rank of the current state
	li		a0, 0
	add		a1, s10, x0
	jal		ra, get_o_rank
	add		a1, s11, x0
	jal		ra, get_p_rank
	add		s6, a0, x0
# check if reaching the solved state
	bnez	s6, compute_current_cost
	li		a3, 0			# solved
	add		a0, s9, x0
	add		a4, s4, x0
	jal		ra, save_solution
	jal		x0, finish_search
compute_current_cost:
	la		t4, o_table
	li		t0, 0x0000FFFF
	and		t3, s6, t0
	add		t4, t4, t3
	lbu		t5, 0(t4)		# t5 = table value of o
	la		t4, p_table
	srli	t3, s6, 16
	add		t4, t4, t3
	lbu		t6, 0(t4)		# t6 = table value of p
	blt		t5, t6, compute_cost_take_p_value
	add		t4, t5, s4		# t4 = g + h_o
	jal		x0, check_if_branch
compute_cost_take_p_value:
	add		t4, t6, s4		# t4 = g + h_p
check_if_branch:
	addi	s4, s4, 1		# top += 1
	bge		s2, t4, keep_same_branch
	blt		s3, t4, retreat
	add		s3, t4, x0		# next_threshold = g + h
retreat:
	add		t4, s8, s4
	sb		x0, 0(t4)		# count_stack[top] = 0
	addi	s4, s4, -1		# top -= 1
	slli	t4, s4, 3
	add		t4, s7, t4
	sw		x0, 0(t4)
	addi	t4, t4, 4
	sw		x0, 0(t4)		# path_stack[top] = 0
	li		t2, 1
	bge		t2, s4, check_restart_DFS
	add		t4, s8, s4
	lbu		t3, 0(t4)
	li		t5, 6
	blt		t3, t5, update_after_retreat
	jal		x0, retreat
check_restart_DFS:
	add		t4, s8, s4
	lbu		t3, 0(t4)
	li		t5, 9
	blt		t3, t5, update_after_retreat
	li		s4, 0			# top = 0
	jal		x0, move_loop_update
update_after_retreat:
	add		t4, s9, s4
	lbu		s5, 0(t4)		# move = move_stack[top]
	addi	s5, s5, 1		# move = move_stack[top] + 1
	li		t5, 9
	blt		s5, t5, update_state_after_retreat
	addi	s5, s5, -9		# move = (move_stack[top] + 1) % 9
update_state_after_retreat:
	addi	t4, s4, -1
	slli	t4, t4, 3
	add		t4, s7, t4
	lw		s10, 0(t4)
	addi	t4, t4, 4
	lw		s11, 0(t4)		# state = path_stack[top - 1]
	jal		x0, move_loop_update
keep_same_branch:
	addi	a0, s5, 0		# range of move = 0 - 8
	jal		ra, divide_three
	addi	a0, a0, 1		# move = move / 3 + 1
	la		t0, modulo_three_table
	add		t0, t0, a0
	lbu		a0, 0(t0)		# move = (move / 3 + 1) % 3
	jal		ra, multiply_three
	addi	s5, a0, 0		# move = ((move / 3 + 1) % 3) * 3
move_loop_update:
	blt		x0, s4, move_loop
DFS_loop_update:
	li		a3, 1			# not solved
	add		s2, s3, x0		# threshold = next_threshold
	li		t0, GOD_NUMBER
	blt		t0, s2, finish_search
	jal		x0, DFS_loop
# ------ finish search ------ #
finish_search:
# release the stacks
	addi	sp, sp, 96		# release path_stack
	addi	sp, sp, 16		# release move_stack
	addi	sp, sp, 16		# release count_stack
# restore ra to return to main
	lw		ra, 12(sp)
	addi	sp, sp, 16
	ret

# ======= get_o_rank ======= #
# variable mapping:
# a0 -> full rank
# a1 -> the o state
# a2 -> computed o rank
get_o_rank:
	addi	sp, sp, -16		# save ra
	sw		ra, 12(sp)
	li		t0, 0xFFFF0000
	and		a0, a0, t0
	la		a4, o_base_values
	jal		ra, state_to_rank
	add		a0, a0, a2
	lw		ra, 12(sp)
	addi	sp, sp, 16		# restore ra
	ret

# ======= get_p_rank ======= #
# variable mapping:
# a0 -> full rank
# a1 -> the p state
# a2 -> computed p rank
get_p_rank:
	addi	sp, sp, -16		# save ra
	sw		ra, 12(sp)
# convert p state to Lehmer state
	jal		ra, p_to_lehmer
# compute rank from Lehmer state
	li		t0, 0x0000FFFF
	and		a0, a0, t0
	la		a4, p_base_values
	jal		ra, state_to_rank
	slli	a2, a2, 16
	add		a0, a0, a2
	lw		ra, 12(sp)
	addi	sp, sp, 16		# restore ra
	ret

# ===== state_to_rank ====== #
state_to_rank:
# variable mapping:
# a1 -> the state vector
# a2 -> returned rank (2 bytes)
# a4 -> base of base_values
	li		t2, 6
	li		a2, 0
keep_multiplying:
	add		t3, a1, x0
	li		t1, 0			# t1 = intermediate value
	lw		t0, 0(a4)		# t0 = the base value
# extract the digit
	addi	t5, t2, -1
	slli	t5, t5, 2
	srl		t3, t3, t5		# digit at the lowest 4 bits
	andi	t3, t3, 0xF		# digit masked
# if 4 is in the digit
	li		t5, 4
	blt		t3, t5, two_in_digit
	slli	t5, t0, 2
	add		t1, t1, t5		# t1 = t1 + 4 * base
# if 2 is in the digit
two_in_digit:
	andi	t3, t3, 0x3
	li		t5, 2
	blt		t3, t5, one_in_digit
	slli	t5, t0, 1
	add		t1, t1, t5		# t1 = t1 + 2 * base
# if 1 is in the digit
one_in_digit:
	andi	t3, t3, 0x1
	beqz	t3, to_next_digit
	add		t1, t1, t0		# t1 = t1 + 1 * base
to_next_digit:
	add		a2, a2, t1
	addi	t2, t2, -1
	addi	a4, a4, 4
	bnez	t2, keep_multiplying
	ret

# ======= apply_move ======= #
# variable mapping:
# a1 -> o state
# a2 -> p state
# a4 -> move
apply_move:
	addi	sp, sp, -16		# save ra
	sw		ra, 12(sp)
	add		a0, a4, x0
	jal		ra, divide_three
	add		a3, a0, x0		# a3 = move / 3 = face
	la		t4, modulo_three_table
	add		t4, t4, a4
	lbu		a4, 0(t4)		# a4 = move % 3 = turn
	addi	a4, a4, 1		# turn = turn + 1
turn_loop:
	jal		ra, quarter_turn
	addi	a4, a4, -1
	blt		x0, a4, turn_loop
	lw		ra, 12(sp)
	addi	sp, sp, 16		# restore ra
	ret
	
# ====== quarter_turn ====== #
# variable mapping:
# a1 -> o state
# a2 -> p state
# a3 -> face
quarter_turn:
	addi	sp, sp, -16		# save ra
	sw		ra, 12(sp)
	la		t6, move_o_table
	slli	t1, a3, 3
	add		t6, t6, t1		# t6 = base of move_o_table[face]
	la		t5, move_p_table
	add		t5, t5, t1		# t5 = base of move_p_table[face]
	li		t2, 6
	li		t4, 0
move_o_state:
	slli	t4, t4, 4
	add		t0, t5, t2
	lbu		t3, 0(t0)
	slli	t3, t3, 2
	srl		t3, a1, t3		# digit at the lowest 4 bits
	andi	t3, t3, 0xF		# digit masked	
	add		t0, t6, t2
	lbu		t0, 0(t0)		# t0 = twist
	add		t3, t3, t0		# o' = o + twist
	la		t0, modulo_three_table
	add		t0, t0, t3
	lbu		t3, 0(t0)		# o' = (o + twist) % 3
	add		t4, t4, t3
	addi	t2, t2, -1
	bgez	t2, move_o_state
	add		a1, t4, x0		# o state updated
	la		t6, move_p_table
	add		t6, t6, t1		# t6 = base of move_p_table[face]
	li		t2, 6
	li		t4, 0
move_p_state:
	slli	t4, t4, 4
	add		t0, t6, t2
	lbu		t5, 0(t0)		# t5 = source[face][t2]
	slli	t5, t5, 2
	srl		t3, a2, t5		# digit at the lowest 4 bits
	andi	t3, t3, 0xF		# digit masked	
	add		t4, t4, t3
	addi	t2, t2, -1
	bgez	t2, move_p_state
	add		a2, t4, x0		# p state updated
	lw		ra, 12(sp)
	addi	sp, sp, 16		# restore ra
	ret

# ==== fill_digit_stack ==== #
# variable mapping:
# a5 -> size of the stack
# a6 -> base of the stack
# a7 -> the state vector
fill_digit_stack:
	addi	a5, a5, -1
keep_filling_stack:
	slli	t5, a5, 2
	srl		t3, a7, t5		# digit at the lowest 4 bits
	andi	t3, t3, 0xF		# digit masked
	add		t6, a6, a5
	sb		t3, 0(t6)
	addi	a5, a5, -1
	bgez	a5, keep_filling_stack
	ret

# ====== divide_three ====== #
# variable mapping:
# a0 -> the dividend & returned quotient
# notice that a0 is in the range 0 - 8
divide_three:
	add		t1, a0, x0
	li		t2, 6
	blt		t1, t2, less_than_six
	li		a0, 2
	ret
less_than_six:
	li		t2, 3
	blt		t1, t2, less_than_three
	li		a0, 1
	ret
less_than_three:
	li		a0, 0
	ret

# ===== multiply_three ===== #
# variable mapping:
# a0 -> the multiplicand & returned product
multiply_three:
	add		t1, a0, x0
	slli	a0, a0, 1
	add		t1, t1, a0
	add		a0, t1, x0
	ret

# ===== get_table_value ==== #
# variable mapping:
# a0 -> rank
# a1 -> base of heuristic table
# a2 -> returned table value
get_table_value:
	add		a1, a1, a0
	lbu		a2, 0(a1)
	ret

# ======= p_to_lehmer ====== #
# variable mapping:
# a1 -> the input/output state
p_to_lehmer:
	addi	sp, sp, -16		# save ra
	sw		ra, 12(sp)
# create stack to store p state
	addi	sp, sp, -16
	add		t4, sp, x0		# t4 = base of p stack
	li		a5, 7
	add		a6, t4, x0
	add		a7, a1, x0
	jal		ra, fill_digit_stack
# create stack to store Lehmer state
	addi	sp, sp, -16
	add		t6, sp, x0		# t6 = base of Lehmer stack
# fill in the Lehmer stack
	li		t2, 0
	li		t5, 7
fill_lehmer_stack:
	li		t0, 0
	add		t3, t2, x0
	add		t1, t4, t2
	lbu		a5, 0(t1)		# can a5 be used?
count_smaller:
	addi	t3, t3, 1
	bge		t3, t5, count_done
	add		t1, t4, t3
	lbu		a6, 0(t1)		# can a6 be used?
	bge		a6, a5, count_smaller
	addi	t0, t0, 1
	jal		x0, count_smaller
count_done:
	add		t3, t6, t2
	sb		t0, 0(t3)
	addi	t2, t2, 1
	blt		t2, t5, fill_lehmer_stack
	li		a1, 0
	li		t2, 6
form_lehmer_state:
	slli	a1, a1, 4
	add		t3, t6, t2
	lbu		t0, 0(t3)
	add		a1, a1, t0
	addi	t2, t2, -1
	bge		t2, x0, form_lehmer_state
# release the stacks
	addi	sp, sp, 16
	addi	sp, sp, 16
	lw		ra, 12(sp)
	addi	sp, sp, 16		# restore ra
	ret

# ====== save_solution ===== #
# variable mapping:
# a0 -> base of move_stack
# a4 -> number of steps of the solution
save_solution:
	li		t2, 0
	la		t4, solution
	addi	t6, a0, 1
keep_saving_solution:
	lbu		t5, 0(t6)
	sb		t5, 0(t4)
	addi	t6, t6, 1
	addi	t4, t4, 1
	addi	t2, t2, 1
	bne		t2, a4, keep_saving_solution
	ret

# ======= load_vector ====== #
# variable mapping:
# a0 -> returned 4-byte vector
# a1 -> base of 8-byte vector
load_vector:
	li		a0, 0
	li		t2, 7
keep_loading:
	addi	t2, t2, -1
	add		t0, a1, t2
	lb		t4, 0(t0)
	addi	t4, t4, -1
	slli	a0, a0, 4
	add		a0, a0, t4
	bne		t2, x0, keep_loading
	ret

# ======= fill zeros ======= #
# variable mapping:
# a0 -> base of count_stack
fill_z_count_stack:
	li		t2, 0
	li		t6, 4
keep_filling_count_stack:
	sw		x0, 0(a0)
	addi	a0, a0, 4
	addi	t2, t2, 1
	bne		t2, t6, keep_filling_count_stack
	ret

# ===== print_solution ===== #
# variable mapping:
# a1 -> base of move_names
# a2 -> base of the solution data
# a0 is reserved for output buffer
print_solution:
	li		t2, 0
	li		t6, 9
	add		t0, a2, t2
	lbu		t3, 0(t0)
keep_printing_solution:
# print move name
	bge		t3, t6, finish_print
	slli	t3, t3, 2
	add		t0, a1, t3
	lw		a0, 0(t0)
	li		a7, 4
	ecall
# print separator
	li		t3, 36
	add		t0, a1, t3
	lw		a0, 0(t0)
	li		a7, 4
	ecall
	addi	t2, t2, 1
	add		t0, a2, t2
	lbu		t3, 0(t0)
	jal		x0, keep_printing_solution
finish_print:
	ret
