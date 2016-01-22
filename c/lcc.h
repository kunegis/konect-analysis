#ifndef LCC_H
#define LCC_H

#include "bits.h"
#include "consts.h"
#include "dijkstra.$.h"

#if FORMAT_a != FORMAT_SYM
#   error "*** Network must be undirected"
#endif

/* Find the largest connected component (LCC) in R.  Return a malloc'ed
   bit array with 1's for nodes included in the largest connected
   component. 
 */
unsigned char *lcc_find(struct sgraph1_reader_$ *r);

unsigned char *lcc_find(struct sgraph1_reader_$ *r)
{
	const u$_ft n= r->h->n1;
	assert(n > 0); 

	/* Size of bit arrays */ 
	const size_t k= BITNSLOTS(n); 

	/* Bit array of visited nodes */ 
	unsigned char *const visited= calloc(k, 1);

	unsigned char *ret= NULL;
	u$_ft size_ret= 0; 

	u$_ft *d= malloc(n * sizeof(u$_ft)); 

	for (u$_ft u= 0;  u < n;  ++u) {

		while (u < n && BITTEST(visited, u)) {
			++u;
		}

		if (u == n) {
			break;
		}

		unsigned char *ret_new;
		dijkstra_$(r, u, d, &ret_new); 
 		u$_ft size_ret_new= BITSCOUNT(ret_new, n); 

		assert(ret_new != NULL); 

		/* The found component contains at least U itself */ 
		assert(size_ret_new > 0); 
		assert(BITSET(ret_new, u));

		BITSSET(visited, ret_new, n); 

		if (size_ret_new > size_ret) {
			size_ret= size_ret_new;
			free(ret);
			ret= ret_new;

			/* If the connected component contains more than
			   half of all nodes, there cannot be a larger one */
			if (size_ret > n / 2)
				break;
		} else {
			free(ret_new); 
		}
	}

	free(d); 
	
	assert(ret != NULL);
	assert(size_ret > 0);
	assert(size_ret <= n); 

	return ret; 
}

#endif /* ! LCC_H */
