/* 
 * Computer the diameter of a graph using the iFub algorithm [1].  The
 * algorithm has a parameter K which determines whether the computation
 * is exact (when k == 0) or an approximation (when k > 0). 
 * 
 * ABOUT 
 * 	Written by Jesús Cabello González.  Adapted by Jérôme Kunegis. 
 *
 * REFERENCES
 *  [1] Pierluigi Crescenzi, Roberto grossi, Claudio Imbrenda, Leonardo
 * 	Lanzi, Andrea Marino, Finding the diameter in real-world graphs:
 * 	experimentally turning a lower bound into an upper bound. In
 * 	Proc. Annual European Symposium on Algorithms, pages 302--313,
 * 	2010.  
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <time.h>

#include "width.ma.h"
#include "width.ua.h"
#include "width.va.h"
#include "width.wa.h"
#include "width.ta.h"

#include "binary_heap.ua.h"
#include "sgraph1_io.a.h"
#include "dijkstra.a.h"

#include "consts.h"

#if FORMAT_a != FORMAT_SYM
#   error
#endif
#if WEIGHTS_a != WEIGHTS_UNWEIGHTED
#   error
#endif

#define max(X, Y) ((X) > (Y) ? (X) : (Y))

/* 
 * The iFub algorithm proper. L and U are the values returned by
 * four_sweep().  
 * 
 * PARAMETERS 
 *	l	Lower bound on the diameter
 * 	u 	A central node
 *	k	The maximum error, (k >= 0), 0 for exact diameter 
 *
 * RESULT 
 * 	The diameter 
 */
ua_ft ifub(struct sgraph1_reader_a *r, ua_ft u, ua_ft l, unsigned k);

/* Compute the maximum eccentricity of the nodes given. 
 */
ua_ft max_ecc(struct sgraph1_reader_a *r, ua_ft *b, ua_ft b_size);

/* Find a node "in the middle" between the nodes nodeID and fin. 
 */
ua_ft middle_node(struct sgraph1_reader_a *r, ua_ft nodeId, ua_ft fin, ua_ft *d);

/* The "four-sweep" algorithm as described in the paper. 
 * L is a lower bound for the diameter; U is a node with low
 * eccentricity.  (Note:  U is *not* an upper bound; it is a node ID.) 
 */
void four_sweep(struct sgraph1_reader_a *r, ua_ft *l, ua_ft *u);

FILE *log_; 

/*
 * Estimate the diameter of a graph using the iFub algorithm. 
 * 
 * INVOCATION
 * 	$1	Input filename in SG1 format; network must be connected
 *      $2      (unsigned integer) k, parameter of the iFub algorithm;
 * 		precision; zero means compute the exact diameter, larger
 * 		values means approximate the diameter with at most that
 * 		error. 
 * 	$3 	Log filename
 */
int main(int argc, char **argv)
{
	if (argc != 4) {
		fprintf(stderr, "*** Invalid number of arguments\n"); 
		exit(1); 
	}
	
	const char *const filename_sg1= argv[1];
	const char *const filename_log= argv[3]; 

	const char *text_k= argv[2]; 
	unsigned k= 0;
	while (*text_k && isspace(*text_k)) 
		++text_k;
	while (*text_k >= '0' && *text_k <= '9') {
		k *= 10;
		k += *text_k++ - '0';
	}
	while (*text_k && isspace(*text_k)) 
		++text_k;
	if (*text_k) {
		fprintf(stderr, "*** %s:  Invalid parameter K:  %s\n", argv[0], argv[2]);
		exit(1); 
	}

	struct sgraph1_reader_a r;

	if (0 > sgraph1_open_read_a(filename_sg1, &r, 2)) {
		exit(1); 
	}

	if (0 > sgraph1_advise_a(&r, MADV_RANDOM)) {
		perror(filename_sg1);
		exit(1); 
	}

	log_= fopen(filename_log, "w"); 
	if (log_ == NULL) {
		perror(filename_log); 
		exit(1); 
	}

	ua_ft l, u;
	four_sweep(&r, &l, &u);
	ua_ft delta= ifub(&r, u, l, k);

	printf("%" PR_fua "\n", delta);
    
	exit(0);
}

ua_ft ifub(struct sgraph1_reader_a *r, ua_ft u, ua_ft l, unsigned k)
{
	/* Current lower and upper bounds */ 
	ua_ft lb, ub;

	const ua_ft n= r->h->n1;
	ua_ft *const d= (ua_ft *) malloc(sizeof(ua_ft) * n);
    
	dijkstra_a(r, u, d, NULL);
	ua_ft i= d[0];
    
	for (ua_ft j = 1; j < n; j++) {
		if (i < d[j]) {
			i= d[j];
		}
	}

	lb= max(i, l);
	ub= 2 * i;

	assert(lb <= ub); 

	while (lb + k < ub) {

		ua_ft b_size= 0;
		ua_ft *b= (ua_ft *) malloc(b_size * sizeof(ua_ft));

		for (ua_ft j= 0; j < n; ++j) {
			if (d[j] == i) {
				++ b_size;
				b= (ua_ft *) realloc(b, b_size * sizeof(ua_ft));
				b[b_size - 1]= j;
			}
		}

		fprintf(log_, "[%" PR_fua " , %" PR_fua "]  %" PR_fua " nodes of distance %" PR_fua "\n", lb, ub, b_size, i); 
		fflush(log_); 

		const ua_ft x= max_ecc(r, b, b_size);
		free(b);
		b= NULL;
		if (max(lb, x) > 2*(i-1)) {
			free(d);
			return max(lb, x);
		} else {
			lb= max(lb,  x);
			ub= 2 * (i - 1);
		}
		i= i - 1;
		assert(lb <= ub); 
	}

	free(d);

	fprintf(log_, "done\n");
	fflush(log_); 

	assert(lb == ub); 
	return lb;
}

ua_ft max_ecc(struct sgraph1_reader_a *r, ua_ft *b, ua_ft b_size) 
{
	const ua_ft n= r->h->n1; 

	ua_ft sol=0;

	ua_ft *e= (ua_ft *) malloc(sizeof(ua_ft) * n);

	for (ua_ft k= 0; k < b_size; ++k) {
		dijkstra_a(r, b[k], e, NULL);
		ua_ft i= e[0];
		for (ua_ft j= 1; j< n; ++j) {
			if (i < e[j]) {
				i= e[j];
			}
		}
		if (i > sol) {
			sol= i;
		}
	}
	free(e);

	return sol;
}

ua_ft middle_node(struct sgraph1_reader_a *r, ua_ft nodeId, ua_ft fin, ua_ft *d)
{
	const ua_ft n= r->h->n1;

	if (nodeId == fin) {
		return 0;
	}
	
	ua_ft *previo= malloc(sizeof(ua_ft) * n); 
	memset(previo, (1 << CHAR_BIT) - 1, sizeof(ua_ft) * n); 

	unsigned char *s= calloc(BITNSLOTS(n), 1); 

	struct binary_heap_ua b= binary_heap_create_ua();
		
	memset(d, (1 << CHAR_BIT) - 1, sizeof(ua_ft) * n);
        
	binary_heap_insert_ua(&b, nodeId, 0);
	d[nodeId]= 0;

	while (! binary_heap_empty_ua(&b)) {

		const ua_ft i= binary_heap_min_ua(b);
		binary_heap_remove_min_ua(&b);
		if (! BITTEST(s, i)){
			BITSET(s, i);
			const ma_ft end= i == n-1 ? r->len_m : read_ma(r->adj_to, i + 1);
			for (ma_ft j= read_ma(r->adj_to, i); j < end; ++j) {
				const ua_ft v= read_ua(r->to, j); 
				assert(v < n); 
				if (! BITTEST(s, v)){
					
					if (d[v] > d[i] + 1){
						d[v]= d[i] + 1;
						previo[v]= i;
						binary_heap_insert_ua(&b, v, d[i] + 1);
					}
				}
			}
		}
	}

	for (ua_ft i= 0;  i <= d[fin] / 2;  ++i) {
		fin= previo[fin];
	}

	binary_heap_delete_ua(&b);
	free(s); 
	free(previo); 

	return fin;
}

void four_sweep(struct sgraph1_reader_a *r, ua_ft *l, ua_ft *u)
{
	const ua_ft n= r->h->n1;
    
	ua_ft *const d= (ua_ft *) malloc(sizeof(ua_ft) * n);

	/* r1:  a node with highest degree */
	ua_ft r1= 0;
	ua_ft degree_r1= 0; 
	for (ua_ft j= 0; j < n; ++j) {
		const ua_ft degree_j= sgraph1_degree_to_a(r, j);
		if (degree_j > degree_r1) {
			r1= j;
			degree_r1= degree_j;
		}
	}
    
	/* a1: one of the farthest nodes from r1 */ 
	dijkstra_a(r, r1, d, NULL);

 	ua_ft ecc_r1= 0;
	ua_ft a1= 0;

	for (ua_ft j= 0; j < n; ++j) {
		if (d[j] > ecc_r1) {
			ecc_r1= d[j];
			a1= j;
		}
	}
    
	/* b1: one of the farthest nodes from a1 */ 
	dijkstra_a(r, a1, d, NULL);
	ua_ft b1= 0;
	ua_ft ecc_a1= 0; 
	for (ua_ft j= 0; j < n; ++j) {
		if (d[j] > ecc_a1) {
			ecc_a1= d[j];
			b1= j;
		}
	}

	const ua_ft r2= middle_node(r, a1, b1, d);

	/* a2:  one of the furthest nodes from r1 */ 
	dijkstra_a(r, r2, d, NULL);
	ua_ft ecc_r2= 0;
	ua_ft a2= 0;
	for (ua_ft j= 0; j < n; ++j) {
		if (d[j] > ecc_r2) {
			ecc_r2= d[j];
			a2= j;
		}
	}
    
	/* b2:  furthest point from a2 */ 
	dijkstra_a(r, a2, d, NULL);
	ua_ft ecc_a2= 0;
	ua_ft b2= 0;
	for (ua_ft j= 0; j < n; ++j) {
		if(d[j] > ecc_a2) {
			ecc_a2= d[j];
			b2= j;
		}
	}
    
	*u= middle_node(r, a2, b2, d);
    
	*l= max(ecc_a1, ecc_a2);

	free(d);
}


