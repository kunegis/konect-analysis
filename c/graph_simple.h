#ifndef GRAPH_SIMPLE_$1$1_H
#define GRAPH_SIMPLE_$1$2_H

/* Code for transforming a graph into a simple graph. 
 * $1 is the source graph.  $2 is the target graph. 
 */

/* Read an SG0 graph into a struct graph_$2. 
 * The given graph must be uninitialized. 
 * The resulting graph is simple (SYM-POSITIVE). 
 */ 
void graph_read_sg0_simple_$1_$2(struct graph_$2 *restrict g, 
				 struct sgraph0_reader_$1 *restrict r)
{
	struct header *s= (struct header *)r->out;

	g->format  = FORMAT_SYM; 
	g->weights = WEIGHTS_POSITIVE;

	g->cols    = 2; 
	g->m       = 0;

#if FORMAT_$1 == FORMAT_SYM || FORMAT_$1 == FORMAT_ASYM	
	assert(s->n1 == s->n2); 
	g->n1      = s->n1;
	g->n2      = s->n2;
#elif FORMAT_$1 == FORMAT_BIP
	g->n1 	   = s->n1 + s->n2;
	g->n2      = s->n1 + s->n2; 
#else
#   error
#endif

	g->loops   = 0;

	g->deg_to= calloc(arraylen_m$2(g->n1), 1);
	g->deg_from= NULL;

	g->to= malloc(g->n1 * sizeof(v$2_at *)); 
	g->from= NULL;

#if TYPE_w$2 != '-'
	g->weight_to= NULL;
	g->weight_from= NULL; 
#endif	

#if TYPE_t$2 != '-'
	g->timestamp_to= NULL;
	g->timestamp_from= NULL; 
#endif	

	for (m$2_ft i= 0;  i < s->m;  ++i) {

		const u$1_ft u= read_u$1(r->u, i);
		const v$1_ft v= read_v$1(r->v, i);

		if (u == v) 
			continue;

#if FORMAT_$1 == FORMAT_SYM || FORMAT_$1 == FORMAT_ASYM		

		const u$2_ft u2= u;
		const v$2_ft v2= v;

#elif FORMAT_$1 == FORMAT_BIP

		assert(s->n1 < v$2_max);
		
		const u$2_ft u2= u;
		const v$2_ft v2= s->n1 + v;

		assert(v2 >= s->n1); 

#else
#    error
#endif

		const m$2_ft degree_u= g->deg_to[u2];
		const m$2_ft degree_v= g->deg_to[v2]; 

		assert(degree_u < m$2_max); 
		assert(degree_v < m$2_max); 

		graph_append_v$2(g->to + u2, degree_u, v2);
		graph_append_v$2(g->to + v2, degree_v, u2); 

		++ g->deg_to[u2];
		++ g->deg_to[v2]; 

		++ g->m;
	}
}

#endif /* ! GRAPH_SIMPLE_$1$2_H */ 
