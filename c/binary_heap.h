#ifndef BINARY_HEAP_H
#define BINARY_HEAP_H

/* A set of $_ft values. 
 */

struct binary_heap_element_$
{
	$_ft n; /* value */  /* used as node ID */ 
	$_ft d; /* key */    /* used as distance */ 
};

struct binary_heap_$
{
	/* Length:  N.  NULL is N = 0.
	 */ 
	struct binary_heap_element_$ *elements; /* malloc'ed */ 

	/* N. 
	 */
	$_ft n;
};

/* Create an empty binary heap */ 
struct binary_heap_$ binary_heap_create_$();

/* Insert a value into a binary heap. 
 */
void binary_heap_insert_$(struct binary_heap_$ *b, $_ft n, $_ft d);

void binary_heap_remove_min_$(struct binary_heap_$ *b);

$_ft binary_heap_min_$(struct binary_heap_$ b);

void binary_heap_delete_$(struct binary_heap_$ *b);

int binary_heap_empty_$(struct binary_heap_$ *b);

struct binary_heap_$ binary_heap_create_$()
{
	struct binary_heap_$ b;
	b.n= 0;
	b.elements= NULL;
	return b;
}

$_ft binary_heap_min_$(struct binary_heap_$ b)
{
	return b.elements[0].n;
}

void binary_heap_delete_$(struct binary_heap_$ *b)
{
	free(b->elements);
#ifndef NDEBUG
	b->elements= NULL;
#endif
}

void binary_heap_insert_$(struct binary_heap_$ *b, $_ft n, $_ft d)
{
	++ b->n;

	b->elements= (struct binary_heap_element_$ *) realloc
		(b->elements, 
		 b->n
		 * sizeof(struct binary_heap_element_$));

	$_ft p= b->n - 1;

	while (p > 0 && b->elements[(p - 1) / 2].d > d) {
		b->elements[p].d= b->elements[(p - 1) / 2].d;
		b->elements[p].n= b->elements[(p - 1) / 2].n;
		p= (p - 1) / 2;
	}

	b->elements[p].d= d;
	b->elements[p].n= n;
}

void binary_heap_remove_min_$(struct binary_heap_$ *b)
{
	assert(! binary_heap_empty_$(b));

	if (b->n == 1)
	{
		b->n= 0;
		free(b->elements);
		b->elements = NULL;
	} else {
		struct binary_heap_element_$ e= b->elements
			[
			 b->n - 1
			 ];
		-- b->n;
		b->elements= (struct binary_heap_element_$ *) realloc
			(b->elements, 
			 b->n
			 * sizeof(struct binary_heap_element_$));

		if (! binary_heap_empty_$(b)) {
			$_ft p= 0;
			if (b->n > 1) {

				$_ft end= 0;
				$_ft pmin;

				assert(b->n >= 2); 
				while (p <= ($_ft)
					   (b->n - 2)
					   / 2 && end == 0){
					
					if (((2 * p) + 1) == 
						(b->n - 1)) {
						pmin= (2 * p) + 1; 
					} else if (b->elements[(2 * p) + 1].d < b->elements[(2 * p) + 2].d) {
						pmin= (2 * p) + 1;
					} else {
						pmin= (2 * p) + 2;
					}
                
					if (b->elements[pmin].d < e.d) {
						b->elements[p]= (*b).elements[pmin];
						p= pmin;
					} else {
						end= 1;
					}
				}
			}
			b->elements[p]= e;
		}
	}
}

int binary_heap_empty_$(struct binary_heap_$ *b)
{
	return b->n == 0; 
}

#endif /* ! BINARY_HEAP_H */
