// This program generates heuristic tables
// for both p (permutation) and o (orientation) states
//
// This program is adapted from solver.c

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

enum {
	CUBIES = 7,
	PERMUTATIONS = 5040,
	ORIENTATIONS = 729,
	STATES = PERMUTATIONS * ORIENTATIONS,
	MOVES = 9,
	GOD_NUMBER = 11
};

typedef struct {
    uint8_t p[CUBIES], o[CUBIES];
} state_t;

static const char *const move_names[MOVES] = {"R", "R2", "R'",
											  "B", "B2", "B'",
											  "D", "D2", "D'"};
static const uint8_t inverse_move[MOVES] = {2, 1, 0, 5, 4, 3, 8, 7, 6};

static const uint8_t source[3][CUBIES] = {
    {1, 4, 2, 0, 3, 5, 6},
    {0, 1, 2, 4, 5, 6, 3},
    {0, 2, 5, 3, 1, 4, 6},
};
static const uint8_t twist[3][CUBIES] = {
    {1, 2, 0, 2, 1, 0, 0},
    {0, 0, 0, 1, 2, 1, 2},
    {0, 0, 0, 0, 0, 0, 0},
};

static state_t quarter_turn(state_t state, uint8_t face)
{
    state_t result;
    for (uint8_t i = 0; i < CUBIES; ++i) {
        uint8_t from = source[face][i];
        result.p[i] = state.p[from];
        result.o[i] = (uint8_t) ((state.o[from] + twist[face][i]) % 3U);
    }
    return result;
}

static state_t apply_move(state_t state, uint8_t move)
{
    uint8_t turns = (uint8_t) (move % 3U + 1U);
    for (uint8_t i = 0; i < turns; ++i)
        state = quarter_turn(state, (uint8_t) (move / 3U));
    return state;
}

static uint32_t rank_state(const state_t *state, uint8_t flag)
{
	// flag == 0 -> rank o state
	// flag == 1 -> rank p state
	// flag == 2 -> rank the full state

    uint32_t p = 0, o = 0;
	if(flag == 1 || flag == 2) {
    	for (uint8_t i = 0; i < CUBIES; ++i) {
        	uint8_t smaller = 0;
        	for (uint8_t j = (uint8_t) (i + 1U); j < CUBIES; ++j)
            	if (state->p[j] < state->p[i])
                	++smaller;
        	p = p * (CUBIES - i) + smaller;
    	}
	}
	if(flag == 0 || flag == 2) {
    	for (uint8_t i = 0; i < 6; ++i)
        	o = o * 3U + state->o[i];
    }
	return p * ORIENTATIONS + o;
}

static void unrank_state(uint32_t rank, state_t *state, uint8_t flag)
{
	// flag == 0 -> unrank o state
	// flag == 1 -> unrank p state
	// flag == 2 -> unrank the full state

    uint8_t available[CUBIES] = {0, 1, 2, 3, 4, 5, 6};
    uint32_t p = rank / ORIENTATIONS, o = rank % ORIENTATIONS, f = 720;
    uint8_t sum = 0;
	if (flag == 1 || flag == 2) {
    	for (uint8_t i = 0; i < CUBIES; ++i) {
        	uint8_t q = (uint8_t) (p / f);
        	p %= f;
        	state->p[i] = available[q];
        	for (uint8_t j = q; j + 1U < (uint8_t) (CUBIES - i); ++j)
            	available[j] = available[j + 1U];
        	if (i < 5)
            	f /= 6U - i;
    	}
	}
	if (flag == 0 || flag == 2) {
    	for (uint8_t i = 6; i-- > 0;) {
        	state->o[i] = (uint8_t) (o % 3U);
        	sum = (uint8_t) (sum + state->o[i]);
        	o /= 3U;
    	}
    	state->o[6] = (uint8_t) ((3U - sum % 3U) % 3U);
	}
}

static int verify_solution(state_t *state, uint8_t *sol, uint8_t N)
{
	// verify if the solution is correct (optimal in theory)
	//
	// state 	-> the input state
	// sol		-> the solution
	// N		-> number of moves in the solution
	
	for(uint8_t i = 1; i <= N; i++) *state = apply_move(*state, sol[i]);
	uint32_t result = rank_state(state, 2);
	return result == 0;
}

static int valid(const state_t *state)
{
    uint8_t sum = 0;
    for (uint8_t i = 0; i < CUBIES; ++i) {
        if (state->p[i] >= CUBIES || state->o[i] >= 3)
            return 0;
        for (uint8_t j = 0; j < i; ++j)
            if (state->p[j] == state->p[i])
                return 0;
        sum = (uint8_t) (sum + state->o[i]);
    }
    return sum % 3U == 0;
}

static uint8_t *build_heuristic_table(uint8_t *max_steps, uint8_t flag)
{
	// flag == 0 -> build o heuristic table
	// flag == 1 -> build p heuristic table

	uint16_t num_states;
	if(flag == 0) num_states = ORIENTATIONS;
	else if(flag == 1) num_states = PERMUTATIONS;
	else return NULL;

	uint8_t *heuristics = malloc(num_states);
	uint16_t *queue = malloc((size_t) num_states * sizeof *queue);
	uint16_t transition_table[3][num_states];
	uint16_t head = 0, tail = 1, level_end = 1;
	uint16_t scale = (flag)? ORIENTATIONS: 1;
	state_t state;
	if(!heuristics || !queue)
	{
		free(heuristics);
		free(queue);
		return NULL;
	}
	for(uint16_t rank = 0; rank < num_states; rank++)
	{
		unrank_state((uint32_t) rank * scale, &state, flag);
		for(uint8_t face = 0; face < 3; face++)
		{
			state_t next = quarter_turn(state, face);
			transition_table[face][rank] =
				(uint16_t) (rank_state(&next, flag) / scale);
		}
	}

	memset(heuristics, 0, num_states);
	heuristics[0] = UINT8_MAX;
	queue[0] = 0;
	*max_steps = 0;
	while(head < tail)
	{
		if(head == level_end)
		{
			level_end = tail;
			++*max_steps;
		}
		uint16_t here = queue[head++];
		for(uint8_t face = 0; face < 3; face++)
		{
			uint16_t next_v = here;
			for(uint8_t turn = 0; turn < 3; turn++)
			{
				next_v = transition_table[face][next_v];
				if(heuristics[next_v] == 0)
				{
					heuristics[next_v] = *max_steps + 1U;
					queue[tail++] = next_v;
				}
			}
		}
	}
	heuristics[0] = 0;
	free(queue);
	if(tail != num_states)
	{
		free(heuristics);
		return NULL;
	}
	return heuristics;
}

static void output_heuristic_table(uint8_t *o_table, uint8_t *p_table)
{
	FILE *file = fopen("table.s", "w");
	if(!file)
	{
        fputs("could not open file\n", stderr);
		return;
	}

	fprintf(file, ".rodata\n.align 2\n\n");
    fprintf(file, ".globl h_o\nh_o:\n");
    for (uint16_t i = 0; i < ORIENTATIONS; i++) {
        if (i % 16U == 0) {
            fprintf(file, "\n    .byte %d", o_table[i]);
        } else {
            fprintf(file, ", %d", o_table[i]);
        }
    }
    fprintf(file, "\n\n");

    fprintf(file, ".globl h_p\nh_p:\n");
    for (uint16_t i = 0; i < PERMUTATIONS; i++) {
        if (i % 16U == 0) {
            fprintf(file, "\n    .byte %d", p_table[i]);
        } else {
            fprintf(file, ", %d", p_table[i]);
        }
    }
    fprintf(file, "\n");
    fclose(file);
}

static int parse_state(const char *input, state_t *state)
{
    for (int i = 0; i < 14; ++i) {
        int limit = i < 7 ? 7 : 3;
        if (input[i] < '1' || input[i] > '0' + limit)
            return 0;
        (i < 7 ? state->p : state->o)[i % 7] = (uint8_t) (input[i] - '1');
    }
    return input[14] == '\0' && valid(state);
}

static int output_failed(void)
{
    return fflush(stdout) != 0 || ferror(stdout);
}

static int self_test(void)
{
    const state_t solved = {{0, 1, 2, 3, 4, 5, 6}, {0}};
    state_t state;
    for (uint8_t move = 0; move < MOVES; ++move) {
        state = solved;
        state = apply_move(state, move);
        state = apply_move(state, inverse_move[move]);
        if (memcmp(&solved, &state, sizeof solved))
            return 0;
    }
    for (uint32_t rank = 0; rank < STATES; ++rank) {
        unrank_state(rank, &state, 2);
        if (!valid(&state) || rank_state(&state, 2) != rank)
            return 0;
    }
    return 1;
}

static void IDA_Star_search(state_t *root_state, uint8_t *o_table, uint8_t *p_table, uint8_t flag)
{
	// perform IDA* search
	// root_state	-> input state
	// o_table		-> heuristic table of orientations
	// p_table		-> heuristic table of permutations
	// max_step		-> maximum number of moves
	// flag			-> 0 to mute output solution, 1 to print output solution
	
	uint8_t move_stack [GOD_NUMBER + 1];
	uint8_t count_stack [GOD_NUMBER + 1] = {0};
	uint32_t path_stack [GOD_NUMBER + 1];
	state_t state;
	uint32_t rank;				// rank of a full state
	uint16_t o_rank;			// rank of o state
	uint16_t p_rank;			// rank of p state
	uint8_t top = 0;			// index of top of path stack
	uint8_t g = 0;				// cost from root to present node
	uint8_t h_o;				// heuristic value from o state
	uint8_t h_p;				// heuristic value from p state
	uint8_t f = 0;				// total cost at the present branch
	uint8_t threshold = 0;		// threshold of the present iteration

	// determine the initial threshold
	rank = rank_state(root_state, 2);	// rank of the root state
	if(rank == 0) return;				// already solved
	path_stack[0] = rank;
	move_stack[0] = 0;
	o_rank = (uint16_t) (rank % ORIENTATIONS);
	p_rank = (uint16_t) (rank / ORIENTATIONS);
	h_o = o_table[o_rank];				// heuristic value from o state, of root
	h_p = p_table[p_rank];				// heuristic value from p state, of root
	threshold = (h_o > h_p)? h_o: h_p;	// get heuristic value of the root

	while(threshold <= GOD_NUMBER)
	{
		uint8_t next_threshold = UINT8_MAX;
		uint8_t move = 0;
		state = *root_state;
		
		// clear the count stack
		for(uint8_t i = 0; i < GOD_NUMBER; i++) count_stack[i] = 0;
		
		top = 1;
		while(top > 0)
		{
			// move to next node
			state = apply_move(state, move);
			rank = rank_state(&state, 2);				// heavy
			path_stack[top] = rank;
			++count_stack[top];
			move_stack[top++] = move;
			++g;
			
			// compute f = g + h
			o_rank = (uint16_t) (rank % ORIENTATIONS);	// heavy
			p_rank = (uint16_t) (rank / ORIENTATIONS);	// heavy
			h_o = o_table[o_rank];
			h_p = p_table[p_rank];
			f = (h_o > h_p)? (g + h_o): (g + h_p);

			// check if reaching the solved state
			if(rank == 0)
			{
				if(!verify_solution(root_state, move_stack, g))
				{
					printf("stopped at incorrect solution\n");
					return;
				}
				const char *separator = "";
				if(!flag) return;
				for(uint8_t i = 1; i < top; i++)
				{
					printf("%s%s", separator, move_names[move_stack[i]]);
					separator = " ";
				}
				return;
			}
			// determine if cutting off the present branch
			else if(f > threshold)
			{
				if(f < next_threshold) next_threshold = f;
				do{
					count_stack[top] = 0;
					path_stack[--top] = 0;
					--g;
				}while(top > 1 && count_stack[top] >= 6);
				if(top == 1 && count_stack[top] >= 9)
				{
					top = 0;
				}
				else
				{
					move = (move_stack[top] + 1) % 9;
					rank = path_stack[top - 1];
					unrank_state(rank, &state, 2);		// heavy
				}
			}
			// keep searching the present branch
			else
			{
				move = ((move / 3 + 1) % 3) * 3;		// heavy
			}
		}
		threshold = next_threshold;
	}
	if(threshold > GOD_NUMBER)
	{
		puts("fail to find the optimal solution");
	}
}

int main(int argc, char **argv)
{
    state_t state;
    uint8_t max_steps_p;
	uint8_t max_steps_o;
	
	/* ====== testing and program I/O ====== */
    if (argc == 2 && !strcmp(argv[1], "--self-test")) {
        if (!self_test()) {
            fputs("self-test failed\n", stderr);
            return 1;
        }
        uint8_t *o_table = build_heuristic_table(&max_steps_o, 0);
        if (!o_table) {
            fputs("could not build heuristic table for orientations\n", stderr);
            return 1;
        }
        uint8_t *p_table = build_heuristic_table(&max_steps_p, 1);
        if (!p_table) {
            fputs("could not build heuristic table for permutations\n", stderr);
            return 1;
        }
        free(o_table);
		free(p_table);
        if (max_steps_p > GOD_NUMBER) {
            fputs("max_steps_p check failed\n", stderr);
            return 1;
        }
        if (max_steps_o > GOD_NUMBER) {
            fputs("max_steps_o check failed\n", stderr);
            return 1;
        }
        puts("max_steps_o <= 11\nmax_steps_p <= 11");
        return output_failed();
    }
	if(argc != 2 || !strcmp(argv[1], "--test-all-states"))
	{
		uint8_t *o_table = build_heuristic_table(&max_steps_o, 0);
		uint8_t *p_table = build_heuristic_table(&max_steps_p, 1);

		state_t state;
		for(uint32_t rank = 0; rank < ORIENTATIONS * PERMUTATIONS; rank++)
		{
			unrank_state(rank, &state, 2);
			IDA_Star_search(&state, o_table, p_table, 0);
			
			if(rank % 50000 == 0)
			{
				printf("%d / 3674160 states solved\n", rank);
			}
		}
		puts("all states are solved. test complete");
		return output_failed();
	}
    if (argc != 2 || !parse_state(argv[1], &state)) {
        /* C99 5.1.2.2.1 lets argv[0] be null when argc is 0. */
        fprintf(stderr, "usage: %s PPPPPPPOOOOOOO\n",
                argc > 0 && argv[0] ? argv[0] : "solver");
        return 2;
    }

	/* ===== IDA_Star heuristic search ===== */
    uint8_t *o_heuristics = build_heuristic_table(&max_steps_o, 0);
    uint8_t *p_heuristics = build_heuristic_table(&max_steps_p, 1);
    if (!o_heuristics || !p_heuristics) {
        fputs("could not build heuristic tables\n", stderr);
        return 1;
    }
	output_heuristic_table(o_heuristics, p_heuristics);
	IDA_Star_search(&state, o_heuristics, p_heuristics, 1);

	/* ========== end of program =========== */
    putchar('\n');
    free(o_heuristics);
    free(p_heuristics);
    return output_failed();
}
