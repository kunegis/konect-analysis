/*
 * The HyperANF algorithm [1].  Given a simple, connected network,
 * estimate the distance distribution, a.k.a. the hop distribution.   
 *
 * INVOCATION
 * 	$1	SG1 input file; must be simple and connected
 *	$2	Logfile name (nothing is logged at the moment)
 *
 * STDOUT
 *	The cumulated distance distribution as one
 *	integer per line.  The first number is the number of node pairs
 *	in distance a most 0 (i.e., the number of nodes).  The second
 *	number is the number of node
 *	pairs in distance at most 1 (i.e., twice the number of edges),
 *	etc.  The Nth number (counting from 
 *	0) is the number of node pairs at distance at most N.  The
 *	number of output lines equals the (approximated) diameter plus
 *	one.  The last number is thus the square of the number of nodes.
 *	Note that the values are approximations and thus they do not
 *	equal the number of nodes, edges etc. and the diameter exactly.  
 *
 * ABOUT
 * 	Written by Jesús Cabello González during the course of his
 * 	bachelor thesis; adapted by Jérôme Kunegis. 
 *
 * REFERENCES
 *  [1] Paolo Boldi, Marcos Rosa, and Sebastiano Vigna, HyperANF:
 *  	Approximating the neighbourhood function of very large graphs on
 *  	a budget.  In Proc. Int. Conf. on World Wide Web, pp. 625-634,
 *  	2011.  
 */

#include "width.ma.h"
#include "width.ua.h"
#include "width.va.h"

#include "sgraph1_io.a.h"
#include "hyperloglog.ua.h"

#include "consts.h"

#if FORMAT_a != FORMAT_SYM || WEIGHTS_a != WEIGHTS_UNWEIGHTED
#   error "This implementation works only with unweighted undirected graphs"
#endif

/* 
 * The HyperANF algorithm.  Use the graph from R, and output the
 * cumulated distance distribution on stdout. 
 */
void hyperanf(struct sgraph1_reader_a *r);

#define max(X, Y) ((X) > (Y) ? (X) : (Y))

int main(int argc, char **argv)
{
	if (argc != 3) {
		fprintf(stderr, "*** Invalid number of arguments\n");
		exit(1); 
	}
	const char *const filename_sg1= argv[1]; 
	/* The logfile is not used in the current version */ 

	struct sgraph1_reader_a r;
	if (0 > sgraph1_open_read_a(filename_sg1, &r, 2)) {
		exit(1); 
	}
	if (0 > sgraph1_advise_a(&r, MADV_RANDOM)) {
		perror(filename_sg1);
		exit(1); 
	}

	hyperanf(&r); 

	exit(0);
}

void hyperanf(struct sgraph1_reader_a *r) 
{
	assert(r->h->n1 == r->h->n2); 
	
	const ua_ft n= r->h->n1; 

	struct hyperloglog_ua *c= calloc(n, sizeof(*c)); 
	for (ua_ft i= 0;  i < n;  i++) {
		hyperloglog_add_ua(c + i, i);
	}

	struct hyperloglog_ua *m= malloc(n * sizeof(*m)); 
	memcpy(m, c, n * sizeof(*c)); 

	printf("%" PR_fua "\n", n); 

#ifndef NDEBUG
	ua_2t last= n;  
#endif

	/*  
	 * Loop invariant:  M and C are identical. 
	 */
	for (;;) {

		assert(memcmp(m, c, n * sizeof(*m)) == 0);

		int aux= 0;

		for (ua_ft u= 0;  u < n;  ++u) {
			
			const ma_ft end= u == n-1 ? r->len_m : read_ma(r->adj_to, u + 1);
			for (ma_ft k= read_ma(r->adj_to, u); k < end; ++k) {

				const ua_ft v= read_ua(r->to, k);
				assert(v < n); 
				for (unsigned j= 0;  j < HYPERLOGLOG_M_ua;  ++j) {
					m[u].x.M[j]= max(m[u].x.M[j], c[v].x.M[j]);
				}
			}
		}

		for (ua_ft u= 0;  u < n;  ++u) {
			for(unsigned j= 0;  j < HYPERLOGLOG_N_ua;  ++j) {
				if (c[u].x.N[j] != m[u].x.N[j]) {
					c[u].x.N[j]= m[u].x.N[j];
					aux= 1;
				}
			}
		}

		if (aux == 0) 
			break;

		long double x= 0;
		for (ua_ft i= 0;  i < n;  ++i) {
			const long double v= hyperloglog_value_ua(m + i);
			x += v;
		}

		assert(x >= last);

		const uintmax_t x_rounded= x;

		printf("%" PRIuMAX "\n", x_rounded);
		if (0 != fflush(stdout)) {
			perror("stdout");
			exit(1); 
		}

#ifndef NDEBUG
		last= x;
#endif
	}

	free(c);
	free(m);
}
