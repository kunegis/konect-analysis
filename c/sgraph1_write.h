#ifndef SGRAPH1_WRITE_H
#define SGRAPH1_WRITE_H

/* This code does not depend on FORMAT_$ or WEIGHTS_$. 
 */

/* Write the graph G to the file FILENAME_OUT in Sgraph 1 format. 
 *
 * Return 0. 
 * On error, print an error message and return -1. 
 */
int sgraph1_write_$(struct graph_$ *g, const char *filename_out)
{
	assert((g->format == FORMAT_SYM) == (g->from == NULL));

	const long pagesize = sysconf(_SC_PAGESIZE); 

	/* O_RDWR is needed because otherwise the file cannot be mapped, even as read-only */   
	const int fd_out= open(filename_out, O_CREAT | O_RDWR | O_TRUNC, 0666);
	if (0 > fd_out) {
		perror(filename_out); 
		goto error;
	}

	const size_t len_m= g->from ? g->m : 2 * g->m - g->loops;

	size_t l= sizeof(struct header);

	size_t p_loops= 0;
	if (g->format == FORMAT_SYM) {
		p_loops= round_m$(l);
		l= p_loops + arraylen_m$(1); 
	}

	const size_t p_adj_to= round_m$(l);
	l= p_adj_to + arraylen_m$(g->n1);
	size_t p_adj_from= 0;
	if (g->from) {
		p_adj_from= round_m$(l);
		l= p_adj_from + arraylen_m$(g->n2); 
	}

	const size_t p_to= round_v$(l);
	l= p_to + arraylen_v$(len_m);
	size_t p_from= 0;
	if (g->from) {
		p_from= round_u$(l);
		l= p_from + arraylen_u$(len_m);
	}

#if TYPE_w$ != '-'	
	size_t p_weight_to= -1;
	size_t p_weight_from= -1;
	if (g->weight_to) {
		p_weight_to= round_w$(l);
		l= p_weight_to + arraylen_w$(len_m);
		p_weight_from= 0;
		if (g->from) {
			p_weight_from= round_w$(l);
			l= p_weight_from + arraylen_w$(len_m);
		}
	}
#endif 
	
#if TYPE_t$ != '-'	
	size_t p_timestamp_to= -1;
	size_t p_timestamp_from= -1;
	if (g->timestamp_to) {
		p_timestamp_to= round_t$(l);
		l= p_timestamp_to + arraylen_t$(len_m);
		p_timestamp_from= 0;
		if (g->from) {
			p_timestamp_from= round_t$(l);
			l= p_timestamp_from + arraylen_t$(len_m);
		}
	}
#endif 

	const size_t l_out= l; 

	if (0 > ftruncate(fd_out, l_out)) {
		perror(filename_out);
		goto error_fd;
	}

	void *const out= mmap(NULL, l_out, PROT_WRITE, MAP_SHARED,
			fd_out, 0); 
	if (out == MAP_FAILED) {
		perror(filename_out); 
		goto error_fd; 
	}

	if (0 > close(fd_out)) {
		perror(filename_out); 
		goto error_map; 
	}

	struct header *const h= (struct header *) out; 

	m$_at *const outa_loops= p_loops ? (m$_at *)((char *)out + p_loops) : NULL; 

	m$_at *const outa_adj_to= (m$_at *) ((char *)out + p_adj_to);
	void *const beg_adj_to= (void *)
		((uintptr_t)outa_adj_to / pagesize * pagesize);
	if (0 > posix_madvise(beg_adj_to, 
			(uintptr_t)(outa_adj_to) + arraylen_m$(g->n1)
			- (uintptr_t) beg_adj_to,
			MADV_SEQUENTIAL)) {
		perror(filename_out);
		goto error_map;
	}
	
	m$_at *const outa_adj_from= g->from 
		? (m$_at *) ((char *)out + p_adj_from) : NULL;
	if (g->from) {
		void *const beg_adj_from= (void *)
			((uintptr_t)outa_adj_from / pagesize * pagesize);
		if (0 > posix_madvise(beg_adj_from,
				      (uintptr_t)(outa_adj_from) + arraylen_m$(g->n2)
				      - (uintptr_t) beg_adj_from,
				      MADV_SEQUENTIAL)) {
			perror(filename_out);
			goto error_map;
		}
	}

	v$_at *const outa_to= (v$_at *) ((char *)out + p_to);
	void *const beg_to= (void *)
		((uintptr_t)outa_to / pagesize * pagesize);
	if (0 > posix_madvise(beg_to, 
			(uintptr_t)(outa_to) + arraylen_v$(len_m)
			- (uintptr_t) beg_to,
			MADV_SEQUENTIAL)) {
		perror(filename_out);
		goto error_map;
	}

	u$_at *const outa_from= g->from ? (u$_at *) ((char *)out + p_from) : NULL;
	if (g->from) {
		void *const beg_from= (void *)
			((uintptr_t)outa_from / pagesize * pagesize);
		if (0 > posix_madvise(beg_from,
				(uintptr_t)(outa_from) + arraylen_u$(len_m)
				- (uintptr_t) beg_from,
				MADV_SEQUENTIAL)) {
			perror(filename_out);
			goto error_map;
		}
	}

#if TYPE_w$ != '-'
	w$_at *outa_weight_to= NULL;
	w$_at *outa_weight_from= NULL;
	if (g->weight_to) {
		outa_weight_to= (w$_at *) ((char *)out + p_weight_to);
		void *const beg_weight_to= (void *)
			((uintptr_t)outa_weight_to / pagesize * pagesize);
		if (0 > posix_madvise(beg_weight_to, 
				(uintptr_t)(outa_weight_to) + arraylen_w$(len_m)
				- (uintptr_t) beg_weight_to,
				MADV_SEQUENTIAL)) {
			perror(filename_out);
			goto error_map;
		}

		outa_weight_from= g->from 
			? (w$_at *) ((char *)out + p_weight_from) : NULL;
		if (g->from) {
			void *const beg_weight_from= (void *)
				((uintptr_t)outa_weight_from / pagesize * pagesize);
			if (0 > posix_madvise(beg_weight_from,
					(uintptr_t)(outa_weight_from) + arraylen_w$(len_m)
					- (uintptr_t) beg_weight_from,
					MADV_SEQUENTIAL)) {
				perror(filename_out);
				goto error_map;
			}
		}
	}
#endif 

#if TYPE_t$ != '-'
	t$_at *outa_timestamp_to= NULL;
	t$_at *outa_timestamp_from= NULL;
	if (g->timestamp_to) {
		outa_timestamp_to= (t$_at *) ((char *)out + p_timestamp_to);
		void *const beg_timestamp_to= (void *)
			((uintptr_t)outa_timestamp_to / pagesize * pagesize);
		if (0 > posix_madvise(beg_timestamp_to, 
				(uintptr_t)(outa_timestamp_to) + arraylen_t$(len_m)
				- (uintptr_t) beg_timestamp_to,
				MADV_SEQUENTIAL)) {
			perror(filename_out);
			goto error_map;
		}

		outa_timestamp_from= g->from 
			? (t$_at *) ((char *)out + p_timestamp_from) : NULL;
		if (g->from) {
			void *const beg_timestamp_from= (void *)
				((uintptr_t)outa_timestamp_from / pagesize * pagesize);
			if (0 > posix_madvise(beg_timestamp_from,
					(uintptr_t)(outa_timestamp_from) + arraylen_t$(len_m)
					- (uintptr_t) beg_timestamp_from,
					MADV_SEQUENTIAL)) {
				perror(filename_out);
				goto error_map;
			}
		}
	}
#endif 

	/*
	 * Output header 
	 */

	h->magic64= SGRAPH_MAGIC64;
	h->version= SGRAPH_VERSION_EDGE;
	h->format = g->format;
	h->weights= g->weights;
	h->width_m= TYPE_m$;
	h->width_u= TYPE_u$;
	h->width_v= TYPE_v$;
#if TYPE_w$ == '-'
	h->width_w= TYPE_w$;
#else
	h->width_w= g->weight_to ? TYPE_w$ : '-';
#endif
#if TYPE_t$ == '-'
	h->width_t= TYPE_t$;
#else
	h->width_t= g->timestamp_to ? TYPE_t$ : '-';
#endif
	h->magic32= SGRAPH_MAGIC32;
	h->flags  = 0;
	h->m      = g->m;
	h->n1     = g->n1;
	h->n2     = g->n2; 

	if (outa_loops) {
		write_m$(outa_loops, 0, g->loops); 
	}

	/*
	 * Write data 
	 */ 

	const size_t dmax_u= arrayn_u$(sizeof(u$_at *)); 
	const size_t dmax_v= arrayn_v$(sizeof(v$_at *)); 
#if TYPE_w$ != '-'
	const size_t dmax_w= arrayn_w$(sizeof(w$_at *)); 
#endif
#if TYPE_t$ != '-'
	const size_t dmax_t= arrayn_t$(sizeof(t$_at *)); 
#endif

	{
		m$_ft j= 0;
		for (u$_ft i= 0;  i < g->n1;  ++i) {
			write_m$(outa_adj_to, i, j); 
			m$_ft d= read_m$(g->deg_to, i); 

			if (d > dmax_v)   copyonzero_v$(outa_to, j, g->to[i],             0, d);
			else              copyonzero_v$(outa_to, j, (v$_at *) (g->to + i), 0, d);
#if TYPE_w$ != '-'
			if (g->weight_to) {
			if (d > dmax_w)   copyonzero_w$(outa_weight_to, j, g->weight_to[i],             0, d);
			else              copyonzero_w$(outa_weight_to, j, (w$_at *) (g->weight_to + i), 0, d);
			}
#endif
#if TYPE_t$ != '-'
			if (g->timestamp_to) {
			if (d > dmax_t)   copyonzero_t$(outa_timestamp_to, j, g->timestamp_to[i],             0, d);
			else              copyonzero_t$(outa_timestamp_to, j, (t$_at *) (g->timestamp_to + i), 0, d);
			}
#endif

			assert(j + d < m$_max); 
			j += d;
		}
		assert(j == len_m); 
	}
	if (g->from) {
		m$_ft j= 0;
		for (v$_ft i= 0;  i < g->n2;  ++i) {
			write_m$(outa_adj_from, i, j); 
			m$_ft d= read_m$(g->deg_from, i); 

			if (d > dmax_u)   copyonzero_u$(outa_from, j, g->from[i],             0, d);
			else              copyonzero_u$(outa_from, j, (u$_at *) (g->from + i), 0, d);
#if TYPE_w$ != '-'
			if (g->weight_from) {
			if (d > dmax_w)   copyonzero_w$(outa_weight_from, j, g->weight_from[i],             0, d);
			else              copyonzero_w$(outa_weight_from, j, (w$_at *) (g->weight_from + i), 0, d);
			}
#endif
#if TYPE_t$ != '-'
			if (g->timestamp_from) {
			if (d > dmax_t)   copyonzero_t$(outa_timestamp_from, j, g->timestamp_from[i],             0, d);
			else              copyonzero_t$(outa_timestamp_from, j, (t$_at *) (g->timestamp_from + i), 0, d);
			}
#endif

			assert(j + d < m$_max); 
			j += d;
		}
		assert(j == len_m); 
	}

	/* 
	 * Close
	 */
	if (0 > msync(out, l_out, MS_ASYNC)) {
		perror(filename_out);
		goto error_map;
	}

	if (0 > munmap(out, l_out)) {
		perror(filename_out);
		goto error_unlink;
	}

	return 0;

 error_map:
	if (0 > munmap(out, l_out)) {
		perror(filename_out);
	}
	goto error_unlink;

 error_fd:
	if (0 > close(fd_out)) {
		perror(filename_out); 
	}

 error_unlink:
	if (0 > unlink(filename_out)) {
		perror(filename_out); 
	}

 error:
	return -1;
}

#endif /* SGRAPH_WRITE_H */ 
