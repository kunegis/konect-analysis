#if TYPE_$1$2 != '-'

#include <string.h>

/* Append the value X to the array whose owning pointer is pointed to by
 * P, and whose current degree is D. 
 */
void graph_append_$1$2($1$2_at **p, m$2_ft d, $1$2_ft x)
{
	/* Maximum number of array elements that fit into the pointer */ 
	const m$2_ft maxd= arrayn_$1$2(sizeof($1$2_at *)); 
	assert(maxd > 0); 

	if (d > maxd) {
		/* realloc */ 
		*p= realloc(*p, arraylen_$1$2(d + 1));
		write_$1$2(*p, d, x);
		
	} else if (d < maxd) {
		/* write into pointer */ 
		write_$1$2(($1$2_at *)p, d, x); 
	} else { /* d == maxd */ 
		/* move to alloc */ 
		assert(d == maxd); 
		$1$2_at *p_copy= *p;
		*p = malloc(arraylen_$1$2(d + 1));
		*($1$2_at **)*p= p_copy;
		write_$1$2(*p, d, x); 
	}
}

int compar_$1$2(const void *x, const void *y) 
{
	$1$2_at *xx= ($1$2_at *) x;
	$1$2_at *yy= ($1$2_at *) y;

	if (*xx < *yy)  return -1;
	if (*xx > *yy)  return +1;
	return 0; 
}

#endif /* TYPE_$1$2 != '-' */
