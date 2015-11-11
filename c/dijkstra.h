#ifndef DIJKSTRA_H
#define DIJKSTRA_H

/* 
 * Dijkstra's algorithm on an SG1 graph.
 */

#include "bits.h"

#if TYPE_u$ != TYPE_v$
#   error Dataset must have equal types for U and V
#endif

/* Compute the distances from U to all nodes.  Write the result into D,
 * which must have length N (number of nodes).   
 * Write the bit array of visited nodes into *VISITED if VISITED is not
 * NULL.  If the array is written, it is a malloc'ed array. 
 */
void dijkstra_$(const struct sgraph1_reader_$ *r, 
				u$_ft u, 
				u$_ft *d,
				unsigned char **visited)
{
	const u$_ft n= r->h->n1; 
	assert(u < n); 

	unsigned char *s= calloc(BITNSLOTS(n), 1); 
	struct binary_heap_u$ b= binary_heap_create_u$();

	memset(d, (1 << CHAR_BIT) - 1, sizeof(u$_ft) * n);

	binary_heap_insert_u$(&b, u, 0);

	d[u]= 0;

	while (! binary_heap_empty_u$(&b)) {
		const u$_ft i= binary_heap_min_u$(b);
		assert(i < n); 
		binary_heap_remove_min_u$(&b);
		if (! BITTEST(s, i)) {
			BITSET(s, i);
			const m$_ft end= i == n - 1 ? r->len_m : read_m$(r->adj_to, i + 1);
			for (m$_ft k= read_m$(r->adj_to, i); k < end; ++k) {
				const u$_ft j= read_u$(r->to, k);    
				assert(j < n); 
				assert(i != j);
				if (! BITTEST(s, j)) {
					if(d[j] > d[i] + 1) {
						d[j]= d[i] + 1;
						binary_heap_insert_u$(&b, j, d[i] + 1);
					}
				}
			}
		}
	}

	binary_heap_delete_u$(&b);

	if (visited) {
		*visited= s;
	} else {
		free(s);
	}
}

#endif /* ! DIJKSTRA_H */
