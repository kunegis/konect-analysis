#ifndef GRAPH_H
#define GRAPH_H

#include "sgraph.h"

/* In-memory data structure for graphs.  Note:  If a graph does not
 * change, it is better to put it in an Sgraph file and to mmap it.
 * This data structure is intended for algorithms that modify a graph. 
 */

/*
 * The deg_to/deg_from members are arrays of length n1 and n2 of the degree
 * of each node.   
 * Each pointer member points to an array of length n1/n2 of pointers to
 * malloc-allocated arrays of values.  Each of these arrays has as
 * length the needed length to hold an amount of elements equal to the
 * degree of the node.  When the size of an array would be not larger
 * that the pointer size, the values are stored in the array value. 
 * 
 * The neighbors of each node may or may not be sorted by node ID --
 * individual functions document how they treat sorting. 
 */

/* We do not check the return value of malloc -- if it returns NULL,
 * then the program fails on access. 
 */

/* This code does not depend on FORMAT_$ or WEIGHTS_$. 
 */

struct graph_$
{
	m$_at*  deg_to;
	m$_at*  deg_from;

	v$_at** to;
	u$_at** from;

#if TYPE_w$ != '-'	
	w$_at** weight_to;
	w$_at** weight_from;
#endif

#if TYPE_t$ != '-'
	t$_at** timestamp_to;
	t$_at** timestamp_from;
#endif

	int format;
	int weights;
	int cols; 

	m$_ft m;
	m$_ft n1;
	m$_ft n2;

	/* For SYM networks:  the number of loops.
	 * Otherwise, zero. */ 
	m$_ft loops;
};

void graph_insert_sym_$(struct graph_$ *restrict g, 
		      u$_ft u, v$_ft v
#if TYPE_w$ != '-'
		      , w$_ft w
#endif 
#if TYPE_t$ != '-'
		      , t$_ft t
#endif 
		      );

void graph_insert_bip_asym_$(struct graph_$ *restrict g, 
			   u$_ft u, v$_ft v
#if TYPE_w$ != '-'
			   , w$_ft w
#endif 
#if TYPE_t$ != '-'
			   , t$_ft t
#endif 
			   );

void graph_insert_sym_$(struct graph_$ *restrict g, 
		      u$_ft u, v$_ft v
#if TYPE_w$ != '-'
			     , w$_ft w
#endif 
#if TYPE_t$ != '-'
			     , t$_ft t
#endif 
		      )
{
	if(u != v) {

		m$_ft degree_u= read_m$(g->deg_to, u);
		m$_ft degree_v= read_m$(g->deg_to, v); 

		assert(degree_u < m$_max); 
		assert(degree_v < m$_max); 

		graph_append_v$(g->to + u, degree_u, v);
		graph_append_v$(g->to + v, degree_v, u); 

#if TYPE_w$ != '-'
		graph_append_w$(g->weight_to + u, degree_u, w);
		graph_append_w$(g->weight_to + v, degree_v, w); 
#endif

#if TYPE_t$ != '-'
		graph_append_t$(g->timestamp_to + u, degree_u, t);
		graph_append_t$(g->timestamp_to + v, degree_v, t); 
#endif

		write_m$(g->deg_to, u, 1 + degree_u); 
		write_m$(g->deg_to, v, 1 + degree_v); 
	} else {

		m$_ft degree= read_m$(g->deg_to, u);

		assert(degree < m$_max); 

		graph_append_v$(g->to + u, degree, v);
#if TYPE_w$ != '-'
		graph_append_w$(g->weight_to + u, degree, w);
#endif
#if TYPE_t$ != '-'
		graph_append_t$(g->timestamp_to + u, degree, t);
#endif

		write_m$(g->deg_to, u, 1 + degree); 
	}
}

void graph_insert_bip_asym_$(struct graph_$ *restrict g, 
			   u$_ft u, v$_ft v
#if TYPE_w$ != '-'
			     , w$_ft w
#endif 
#if TYPE_t$ != '-'
			     , t$_ft t
#endif 
		      )
{

	m$_ft degree_u= read_m$(g->deg_to, u);
	m$_ft degree_v= read_m$(g->deg_from, v); 

	assert(degree_u < m$_max); 
	assert(degree_v < m$_max); 

	graph_append_v$(g->to   + u, degree_u, v);
	graph_append_u$(g->from + v, degree_v, u);

#if TYPE_w$ != '-'
	graph_append_w$(g->weight_to   + u, degree_u, w);
	graph_append_w$(g->weight_from + v, degree_v, w); 
#endif

#if TYPE_t$ != '-'
	graph_append_t$(g->timestamp_to   + u, degree_u, t);
	graph_append_t$(g->timestamp_from + v, degree_v, t); 
#endif

	write_m$(g->deg_to,   u, 1 + degree_u);
	write_m$(g->deg_from, v, 1 + degree_v); 
}

static v$_at *compar_idx_p_v$;
static u$_at *compar_idx_p_u$;

#ifndef NDEBUG
static v$_at compar_idx_p_size_v$;
static u$_at compar_idx_p_size_u$;
#endif /* ! NDEBUG */ 

int compar_idx_v$(const void *x, const void *y) 
{
	m$_lt x_id= *(const m$_lt *)x;
	m$_lt y_id= *(const m$_lt *)y;
	assert(x_id < compar_idx_p_size_v$);
	assert(y_id < compar_idx_p_size_v$);

	v$_ft xx= read_v$(compar_idx_p_v$, x_id); 
	v$_ft yy= read_v$(compar_idx_p_v$, y_id); 

	if (xx < yy)  return -1;
	if (xx > yy)  return +1;
	return 0; 
}

int compar_idx_u$(const void *x, const void *y) 
{
	m$_lt x_id= *(const m$_lt *)x;
	m$_lt y_id= *(const m$_lt *)y;
	assert(x_id < compar_idx_p_size_u$);
	assert(y_id < compar_idx_p_size_u$);

	u$_ft xx= read_u$(compar_idx_p_u$, x_id); 
	u$_ft yy= read_u$(compar_idx_p_u$, y_id); 

	if (xx < yy)  return -1;
	if (xx > yy)  return +1;
	return 0; 
}

/* Sort the adjacency lists in the graph to make sure they are sorted by
 * ID.  
 */
void graph_sort_$(struct graph_$ *restrict g)
{
	const size_t dmax_u= arrayn_u$(sizeof(u$_at *)); 
	const size_t dmax_v= arrayn_v$(sizeof(v$_at *)); 
#if TYPE_w$ != '-'
	const size_t dmax_w= arrayn_w$(sizeof(w$_at *)); 
#endif
#if TYPE_t$ != '-'
	const size_t dmax_t= arrayn_t$(sizeof(t$_at *)); 
#endif

	if (TYPE_w$ == '-' && TYPE_t$ == '-' && BITS_v$ >= CHAR_BIT) {
		for (u$_ft i= 0;  i < g->n1;  ++i) {
			const m$_at d= read_m$(g->deg_to, i);
			if (d <= dmax_v) {
				qsort(g->to + i, d, sizeof(v$_at), compar_v$); 
			} else {
				qsort(g->to[i], d, sizeof(v$_at), compar_v$);
			}
		} 
	} else {
		m$_lt *idx= NULL;
		m$_ft size= 0;

		for (u$_ft i= 0;  i < g->n1;  ++i) {
			
			const m$_ft d= read_m$(g->deg_to, i); 

			if (d == 0)  
				continue;

			if (d > size) {
				size= d;
				free(idx);
				idx= malloc(sizeof(m$_lt) * size); 
			}

			for (m$_ft j= 0;  j < d;  ++j) {
				idx[j]= j;
			}

   			compar_idx_p_v$= d > dmax_v ? g->to[i] : (v$_at *) (g->to + i);
#ifndef NDEBUG
			compar_idx_p_size_v$= d;
#endif
			qsort(idx, d, sizeof(m$_lt), compar_idx_v$);

			v$_at *to_i_old= g->to[i];
			v$_at *to_i_old_pointer= d > dmax_v ? to_i_old : (v$_at *) &to_i_old;
			if (d > dmax_v)  g->to[i]= malloc(arraylen_v$(d));
			v$_at *to_i_new_pointer= d > dmax_v ? g->to[i] : (v$_at *) (g->to + i);
#if TYPE_w$ != '-'
			w$_at *weight_to_i_old= NULL;
			w$_at *weight_to_i_old_pointer= NULL;
			w$_at *weight_to_i_new_pointer= NULL;
			if (g->weight_to) {
				weight_to_i_old= g->weight_to[i];
				weight_to_i_old_pointer= d > dmax_w ? weight_to_i_old : (w$_at *) &weight_to_i_old;
				if (d > dmax_w)  g->weight_to[i]= malloc(arraylen_w$(d));
				weight_to_i_new_pointer= d > dmax_w ? g->weight_to[i] : (w$_at *) (g->weight_to + i);
			}
#endif
#if TYPE_t$ != '-'
			t$_at *timestamp_to_i_old= NULL;
			t$_at *timestamp_to_i_old_pointer= NULL;
			t$_at *timestamp_to_i_new_pointer= NULL;
			if (g->timestamp_to) {
				timestamp_to_i_old= g->timestamp_to[i];
				timestamp_to_i_old_pointer= d > dmax_t ? timestamp_to_i_old : (t$_at *) &timestamp_to_i_old;
				if (d > dmax_t)  g->timestamp_to[i]= malloc(arraylen_t$(d));
				timestamp_to_i_new_pointer= d > dmax_t ? g->timestamp_to[i] : (t$_at *) (g->timestamp_to + i);
			}
#endif

			for (m$_ft j= 0;  j < d;  ++j) {
				write_v$(to_i_new_pointer,           j, read_v$(          to_i_old_pointer, idx[j]));
#if TYPE_w$ != '-'
				if (g->weight_to) 
					write_w$(weight_to_i_new_pointer,    j, read_w$(   weight_to_i_old_pointer, idx[j]));
#endif				
#if TYPE_t$ != '-'
				if (g->timestamp_to)
					write_t$(timestamp_to_i_new_pointer, j, read_t$(timestamp_to_i_old_pointer, idx[j]));
#endif				
			}

			if (d > dmax_v)  free(to_i_old); 
#if TYPE_w$ != '-'
			if (g->weight_to)
				if (d > dmax_w)  free(weight_to_i_old);
#endif
#if TYPE_t$ != '-'
			if (g->timestamp_to)
				if (d > dmax_t)  free(timestamp_to_i_old);
#endif
		}		
	}

	/* Same for FROM.
	   Replace TO by FROM, V <-> U and N1 with N2. */
	if (g->from) {
	if (TYPE_w$ == '-' && TYPE_t$ == '-' && BITS_u$ >= CHAR_BIT) {
		for (v$_ft i= 0;  i < g->n2;  ++i) {
			const m$_at d= read_m$(g->deg_from, i);
			if (d <= dmax_u) {
				qsort(g->from + i, d, sizeof(u$_at), compar_u$); 
			} else {
				qsort(g->from[i], d, sizeof(u$_at), compar_u$);
			}
		} 
	} else {
		m$_lt *idx= NULL;
		m$_ft size= 0;

		for (v$_ft i= 0;  i < g->n2;  ++i) {
			
			const m$_ft d= read_m$(g->deg_from, i); 

			if (d == 0)  
				continue;

			if (d > size) {
				size= d;
				free(idx);
				idx= malloc(sizeof(m$_lt) * size); 
			}

			for (m$_ft j= 0;  j < d;  ++j) {
				idx[j]= j;
			}

   			compar_idx_p_u$= d > dmax_u ? g->from[i] : (u$_at *) (g->from + i);
#ifndef NDEBUG
			compar_idx_p_size_u$= d;
#endif
			qsort(idx, d, sizeof(m$_lt), compar_idx_u$);

			u$_at *from_i_old= g->from[i];
			u$_at *from_i_old_pointer= d > dmax_u ? from_i_old : (u$_at *) &from_i_old;
			if (d > dmax_u)  g->from[i]= malloc(arraylen_u$(d));
			u$_at *from_i_new_pointer= d > dmax_u ? g->from[i] : (u$_at *) (g->from + i);
#if TYPE_w$ != '-'
			w$_at *weight_from_i_old= NULL;
			w$_at *weight_from_i_old_pointer= NULL;
			w$_at *weight_from_i_new_pointer= NULL;
			if (g->weight_from) {
				weight_from_i_old= g->weight_from[i];
				weight_from_i_old_pointer= d > dmax_w ? weight_from_i_old : (w$_at *) &weight_from_i_old;
				if (d > dmax_w)  g->weight_from[i]= malloc(arraylen_w$(d));
				weight_from_i_new_pointer= d > dmax_w ? g->weight_from[i] : (w$_at *) (g->weight_from + i);
			}
#endif
#if TYPE_t$ != '-'
			t$_at *timestamp_from_i_old= NULL;
			t$_at *timestamp_from_i_old_pointer= NULL;
			t$_at *timestamp_from_i_new_pointer= NULL;
			if (g->timestamp_from) {
				timestamp_from_i_old= g->timestamp_from[i];
				timestamp_from_i_old_pointer= d > dmax_t ? timestamp_from_i_old : (t$_at *) &timestamp_from_i_old;
				if (d > dmax_t)  g->timestamp_from[i]= malloc(arraylen_t$(d));
				timestamp_from_i_new_pointer= d > dmax_t ? g->timestamp_from[i] : (t$_at *) (g->timestamp_from + i);
			}
#endif

			for (m$_ft j= 0;  j < d;  ++j) {
				write_u$(from_i_new_pointer,           j, read_u$(          from_i_old_pointer, idx[j]));
#if TYPE_w$ != '-'
				if (g->weight_from)
					write_w$(weight_from_i_new_pointer,    j, read_w$(   weight_from_i_old_pointer, idx[j]));
#endif				
#if TYPE_t$ != '-'
				if (g->timestamp_from)
					write_t$(timestamp_from_i_new_pointer, j, read_t$(timestamp_from_i_old_pointer, idx[j]));
#endif				
			}

			if (d > dmax_u)  free(from_i_old); 
#if TYPE_w$ != '-'
			if (g->weight_from)
				if (d > dmax_w)  free(weight_from_i_old);
#endif
#if TYPE_t$ != '-'
			if (g->timestamp_from)
				if (d > dmax_t)  free(timestamp_from_i_old);
#endif
		}		
	}
	}
}

/* Remove duplicate edges.
 * Assume there are no loops. 
 * The graph must by WEIGHTS_POSITIVE and is transformed into
 * WEIGHTS_UNWEIGHTED. 
 */ 
void graph_unique_$(struct graph_$ *restrict g)
{
	assert(g->format == FORMAT_SYM);
	assert(g->loops == 0); 
	assert(g->weights == WEIGHTS_POSITIVE);

	m$_ft m_new= 0; 

	unsigned dmax_v= arrayn_v$(sizeof(v$_at *));
	
	for (u$_ft u= 0;  u < g->n1;  ++u) {
		
		m$_at d= read_m$(g->deg_to, u);

		v$_at *a= d > dmax_v ? g->to[u] : (v$_at *)(g->to + u);

		m$_ft j= 0;
		for (m$_ft i= 0;  i < d;  ++i, ++j) {

			assert(read_v$(a, i) != u); 

			while (i + 1 < d && read_v$(a, i) == read_v$(a, i + 1))
				++i;

			if (i != j)
				write_v$(a, j, read_v$(a, i));
		}

		/* j is now the new degree */ 
		assert(j <= d); 

		if (d > dmax_v) {
			if (j > dmax_v) {
				g->to[u]= realloc(g->to[u], arraylen_v$(j)); 
			} else {
				memcpy(g->to + u, a, sizeof(m$_at *));
				free(a); 
#ifndef NDEBUG
				a= NULL; 
#endif				
			}
		}
		
		write_m$(g->deg_to, u, j); 
		m_new += j;

#ifndef NDEBUG
		a= j > dmax_v ? g->to[u] : (v$_at *)(g->to + u);
		for (m$_ft i= 0;  i + 1 < j;  ++i) {
			assert(read_v$(a, i) != read_v$(a, i + 1)); 
		}
#endif		
	}

	assert(m_new % 2 == 0);
	m_new /= 2;
	assert(m_new <= g->m);
	g->m= m_new;
	g->weights= WEIGHTS_UNWEIGHTED;
}

#endif /* ! GRAPH_H */

