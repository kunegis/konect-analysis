#ifndef GRAPH_READ_SGRAPH0_$_H
#define GRAPH_READ_SGRAPH0_$_H

/* Read a SG0 graph into a struct graph_$. 
 * The given graph must be uninitialized. 
 */ 
void graph_read_sgraph0_$(struct graph_$ *restrict g, 
			  struct sgraph0_reader_$ *restrict r)
{
	struct header *s= (struct header *)r->out;

	g->format  = s->format;
	g->weights = s->weights;
	g->cols    = r->cols; 
	g->m       = s->m;
	g->n1      = s->n1;
	g->n2      = s->n2;
	g->loops   = 0;

	g->deg_to= calloc(arraylen_m$(g->n1), 1);
	if (g->format == FORMAT_SYM) {
		g->deg_from= NULL;
	} else {
		g->deg_from= calloc(arraylen_m$(g->n2), 1); 
	}

	g->to= malloc(g->n1 * sizeof(v$_at *)); 
	if (g->format == FORMAT_SYM) {
		g->from= NULL;
	} else {
		g->from= malloc(g->n2 * sizeof(u$_at *)); 
	}

#if TYPE_w$ != '-'
	if (r->cols >= 3) {
		g->weight_to= malloc(g->n1 * sizeof(w$_at *)); 
		if (g->format == FORMAT_SYM) {
			g->weight_from= NULL; 
		} else {
			g->weight_from= malloc(g->n2 * sizeof(w$_at *)); 
		}
	} else {
		g->weight_to= NULL;
		g->weight_from= NULL; 
	}
#endif	

#if TYPE_t$ != '-'
	if (r->cols >= 3) {
		g->timestamp_to= malloc(g->n1 * sizeof(t$_at *)); 
		if (g->format == FORMAT_SYM) {
			g->timestamp_from= NULL; 
		} else {
			g->timestamp_from= malloc(g->n2 * sizeof(t$_at *)); 
		}
	} else {
		g->timestamp_to= NULL;
		g->timestamp_from= NULL; 
	}
#endif	

	if (g->format == FORMAT_SYM) {
		for (m$_ft i= 0;  i < g->m;  ++i) {

			u$_ft u= read_u$(r->u, i);
			v$_ft v= read_v$(r->v, i);
#if TYPE_w$ != '-'
			w$_ft w= read_w$(r->w, i);
#endif		
#if TYPE_t$ != '-'
			t$_ft t= read_t$(r->t, i);
#endif		

			graph_insert_sym_$(g, u, v
#if TYPE_w$ != '-'
					 , w
#endif 
#if TYPE_t$ != '-'
					 , t
#endif 
					 );
			g->loops += (u == v);
		}
	} else if (g->format == FORMAT_BIP) {
		for (m$_ft i= 0;  i < g->m;  ++i) {

			u$_ft u= read_u$(r->u, i);
			v$_ft v= read_v$(r->v, i);
#if TYPE_w$ != '-'
			w$_ft w= read_w$(r->w, i);
#endif		
#if TYPE_t$ != '-'
			t$_ft t= read_t$(r->t, i);
#endif		

			graph_insert_bip_asym_$(g, u, v
#if TYPE_w$ != '-'
					      , w
#endif 
#if TYPE_t$ != '-'
					      , t
#endif 
					      );
		}
	} else if (g->format == FORMAT_ASYM) {
		for (m$_ft i= 0;  i < g->m;  ++i) {

			u$_ft u= read_u$(r->u, i);
			v$_ft v= read_v$(r->v, i);
#if TYPE_w$ != '-'
			w$_ft w= read_w$(r->w, i);
#endif		
#if TYPE_t$ != '-'
			t$_ft t= read_t$(r->t, i);
#endif		

			graph_insert_bip_asym_$(g, u, v
#if TYPE_w$ != '-'
					      , w
#endif 
#if TYPE_t$ != '-'
					      , t
#endif 
					      );
		}
	} else {
		assert(0); 
	}
}

#endif /* ! GRAPH_READ_SGRAPH0_$_H */ 
