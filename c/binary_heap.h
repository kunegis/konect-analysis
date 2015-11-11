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
//	/* N - 1 ($_max when N = 0).
//	 * The code relies on the behavior that 0 - 1 results in $_max,
//	 * and $_max + 1 results in zero.  In other words, LAST must be
//	 * of type $_t, and not $_ft.  
//	 */ 
	$_ft n;
//	$_t last;
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
//	b.last= $_max;
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
//	++ b->last;

//	assert(b->last < $_max); 
	b->elements= (struct binary_heap_element_$ *) realloc
		(b->elements, 
		 b->n
//		 (b->last + 1) 
		 * sizeof(struct binary_heap_element_$));

	$_ft p= b->n - 1;
//	$_ft p= b->last;

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
//	if (b->last == 0) 
	{
		b->n= 0;
//		b->last= $_max;
		free(b->elements);
		b->elements = NULL;
	} else {
		struct binary_heap_element_$ e= b->elements
			[
			 b->n - 1
//			 b->last
			 ];
		-- b->n;
//		-- b->last;
		b->elements= (struct binary_heap_element_$ *) realloc
			(b->elements, 
			 b->n
//			 (b->last + 1) 
			 * sizeof(struct binary_heap_element_$));

		if (! binary_heap_empty_$(b)) {
			$_ft p= 0;
			if (b->n > 1)
//			if (b->last > 0) 
				{

				$_ft end= 0;
				$_ft pmin;

				assert(b->n >= 2); 
//				assert(b->last >= 1); 
				while (p <= ($_ft)
					   (b->n - 2)
//					   (b->last - 1) 
					   / 2 && end == 0){
					
					if (((2 * p) + 1) == 
						(b->n - 1)
//						b->last
						) 
						{
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
//	return b->last == $_max;
}

#endif /* ! BINARY_HEAP_H */
