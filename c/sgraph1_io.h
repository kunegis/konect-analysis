#ifndef SGRAPH1_IO_H
#define SGRAPH1_IO_H

/* 
 * Reader for Sgraph version 1. 
 */

#include <sys/types.h>
#include <sys/stat.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <stdio.h>
#include <unistd.h>

#include "sgraph.h"
#include "consts.h"

struct sgraph1_reader_$
{
	/* This is the address of the mapping */ 
	const struct header *h;  
	
	const m$_at *adj_to;
	const m$_at *adj_from;
	const v$_at *to;
	const u$_at *from;
#if TYPE_w$ != '-'
	const w$_at *weight_to;
	const w$_at *weight_from;
#endif
#if TYPE_t$ != '-'
	const t$_at *timestamp_to;
	const t$_at *timestamp_from;
#endif

	/* Length of the map */ 
	size_t l_out_cols; 

	/* Number of columns loaded */ 
	int cols;

	/* Number of loops l (only for SYM) */ 
	m$_ft loops;

	/* Number of total edges in adjacency vectors (2 * m - l) */ 
	m$_ft len_m; 
};

/* Open an Sgraph file (version 1) for reading.
 * Fill R.
 * Cols is the number of columns to read. 
 * Return 0.
 * On error, return -1 and output a message. 
 * COLS == 1 means to load the header and the adj_* columns (given
 * access only to the degree distribution).    
 */
int sgraph1_open_read_$(const char *filename,
			struct sgraph1_reader_$ *r,
			int cols)
{
#ifndef NDEBUG
	r->h= NULL;
	r->adj_to= NULL;
	r->adj_from= NULL;
	r->to= NULL;
	r->from= NULL;
#if TYPE_w$ != '-'
	r->weight_to= NULL;
	r->weight_from= NULL;
#endif
#if TYPE_t$ != '-'
	r->timestamp_to= NULL;
	r->timestamp_from= NULL;
#endif
#endif /* ! NDEBUG */ 

	assert(cols == 0 || cols == 1 || cols == 2 || cols == 3 || cols == 4);

	int fd= open(filename, O_RDONLY);
	if (fd < 0) {
		perror(filename);
		goto error; 
	}

	struct stat buf;
	if (0 > fstat(fd, &buf)) {
		perror(filename);
		goto error_fd;
	}

	struct header h;
	if (read(fd, &h, sizeof(struct header)) < (ssize_t)sizeof(struct header)) {
		perror(filename);
		goto error_fd; 
	}

	if (h.magic32 != SGRAPH_MAGIC32 ||
	    h.magic64 != SGRAPH_MAGIC64) {
		fprintf(stderr, "*** Invalid magic numbers\n");
		goto error_fd;
	}

	if (h.version != SGRAPH_VERSION_EDGE) {
		fprintf(stderr, "*** Invalid Sgraph version\n"); 
		goto error_fd;
	}
	    
	if (h.width_m != TYPE_m$) {
		fprintf(stderr, "*** Invalid M width '%c'\n", h.width_m);
		goto error_fd;
	}
	if (h.width_u != TYPE_u$) {
		fprintf(stderr, "*** Invalid U width '%c'\n", h.width_u);
		goto error_fd;
	}
	if (h.width_v != TYPE_v$) {
		fprintf(stderr, "*** Invalid V width '%c'\n", h.width_v);
		goto error_fd;
	}
	if (h.width_w != TYPE_w$) {
		fprintf(stderr, "*** Invalid W width '%c'\n", h.width_w);
		goto error_fd;
	}
	if (h.width_t != TYPE_t$) {
		fprintf(stderr, "*** Invalid T width '%c'\n", h.width_t);
		goto error_fd;
	}

	if (h.format != FORMAT_$) {
		fprintf(stderr, "*** Invalid format\n");
		goto error_fd;
	}

	if (h.weights != WEIGHTS_$) {
		fprintf(stderr, "*** Invalid weights\n");
		goto error_fd;
	}

	if ( !(h.format == FORMAT_BIP || h.n1 == h.n2)) {
		fprintf(stderr, "*** Invalid sizes\n");
		goto error_fd;
	}

	r->cols= cols; 

	size_t l= sizeof(struct header);

	const size_t l_out_0= l;

	size_t p_loops= 0;
	if (h.format == FORMAT_SYM) {
		p_loops= round_m$(l);
		l= p_loops + arraylen_m$(1); 
	}

	if (h.format == FORMAT_SYM) {
		size_t len_loops= arraylen_m$(1); 
		m$_at loops_a;
		if (read(fd, & loops_a, len_loops) < (ssize_t)len_loops) {
			perror(filename);
			goto error_fd; 
		}
		r->loops= read_m$(& loops_a, 0); 
		r->len_m= 2 * h.m - r->loops; 
	} else {
		r->loops= 0;
		r->len_m= h.m;
	}

	const size_t p_adj_to= round_m$(l);
	l= p_adj_to + arraylen_m$(h.n1);
	size_t p_adj_from= 0;
	if (h.format != FORMAT_SYM) {
		p_adj_from= round_m$(l);
		l= p_adj_from + arraylen_m$(h.n2); 
	}

	const size_t l_out_1= l; 

	const size_t p_to= round_v$(l);
	l= p_to + arraylen_v$(r->len_m);
	size_t p_from= 0;
	if (h.format != FORMAT_SYM) {
		p_from= round_u$(l);
		l= p_from + arraylen_u$(r->len_m);
	}
	const size_t l_out_2= l;

#if TYPE_w$ != '-'	
	const size_t p_weight_to= round_w$(l);
	l= p_weight_to + arraylen_w$(r->len_m);
	size_t p_weight_from= 0;
	if (h.format != FORMAT_SYM) {
		p_weight_from= round_w$(l);
		l= p_weight_from + arraylen_w$(r->len_m);
	}
	const size_t l_out_3= l;
#endif 
	
#if TYPE_t$ != '-'	
	const size_t p_timestamp_to= round_t$(l);
	l= p_timestamp_to + arraylen_t$(r->len_m);
	size_t p_timestamp_from= 0;
	if (h.format != FORMAT_SYM) {
		p_timestamp_from= round_t$(l);
		l= p_timestamp_from + arraylen_t$(r->len_m);
	}
	const size_t l_out_4= l;
#endif 

	const size_t l_out= l; 

	if (l_out != (size_t) buf.st_size) {
		fprintf(stderr, "*** File has wrong size\n");
		goto error_fd; 
	}
	
	if      (cols == 0)       r->l_out_cols= l_out_0;
	else if (cols == 1)	r->l_out_cols= l_out_1;
	else if (cols == 2)       r->l_out_cols= l_out_2;
#if TYPE_w$ != '-'
	else if (cols == 3)  r->l_out_cols= l_out_3;
#endif
#if TYPE_t$ != '-'
	else if (cols == 4)  r->l_out_cols= l_out_4;
#endif
	else assert(0); 
	
	const void *const out= mmap(NULL, r->l_out_cols, PROT_READ, MAP_SHARED, fd, 0);
	if (out == MAP_FAILED) {
		perror(filename);
		goto error_fd; 
	}

	if (0 > close(fd)) {
		perror(filename);
		goto error_map;
	}

	r->h= out;

	if (cols >= 1) {
		r->adj_to        = (m$_at *)((char *)out + p_adj_to);
		r->adj_from      = p_adj_from ? (m$_at *)((char *)out + p_adj_from) : NULL;
	} else {
		r->adj_to        = NULL;
		r->adj_from      = NULL;
	}

	if (cols >= 2) {
		r->to            = (v$_at *)((char *)out + p_to);
		r->from          = p_from ? (u$_at *)((char *)out + p_from) : NULL;
	} else {
		r->to            = NULL;
		r->from          = NULL; 
	}

#if TYPE_w$ != '-'
	if (cols >= 3) {
		r->weight_to     = (w$_at *)((char *)out + p_weight_to);
		r->weight_from   = p_weight_from ? (w$_at *)((char *)out + p_weight_from) : NULL;
	} else {
		r->weight_to     = NULL;
		r->weight_from   = NULL; 
	}
#endif	

#if TYPE_t$ != '-'
	if (cols >= 4) {
		r->timestamp_to  = (t$_at *)((char *)out + p_timestamp_to);
		r->timestamp_from= p_timestamp_from ? (t$_at *)((char *)out + p_timestamp_from) : NULL;
	} else {
		r->timestamp_to  = NULL;
		r->timestamp_from= NULL; 
	}
#endif	

	return 0;

 error_map:

	if (0 > munmap((void *)out, r->l_out_cols)) {
		perror(filename); 
	}
	goto error;

 error_fd:
	if (0 > close(fd)) {
		perror(filename); 
	}

 error:
	return -1;
}

int sgraph1_advise_$(struct sgraph1_reader_$ *r, int advice)
{
	const long pagesize = sysconf(_SC_PAGESIZE); 

	void *beg_adj_to= (void *)((uintptr_t)r->adj_to / pagesize * pagesize);
	if (0 > posix_madvise(beg_adj_to,
			(uintptr_t)(r->adj_to) + arraylen_m$(r->h->n1) 
			- (uintptr_t) beg_adj_to,
			advice)) {
		return -1;
	}

	if (r->adj_from) {
		void *beg_adj_from= (void *)((uintptr_t)r->adj_from
					     / pagesize * pagesize);
		if (0 > posix_madvise(beg_adj_from,
				(uintptr_t)(r->adj_from) + arraylen_m$(r->h->n2) 
				- (uintptr_t) beg_adj_from,
				advice)) {
			return -1;
		}
	}

	void *beg_to= (void *)((uintptr_t)r->to / pagesize * pagesize);
	if (0 > posix_madvise(beg_to,
			(uintptr_t)(r->to) + arraylen_v$(r->len_m) 
			- (uintptr_t) beg_to,
			advice)) {
		return -1;
	}

	if (r->from) {
		void *beg_from= (void *)((uintptr_t)r->from / pagesize * pagesize);
		if (0 > posix_madvise(beg_from,
				(uintptr_t)(r->from) + arraylen_u$(r->len_m) 
				- (uintptr_t) beg_from,
				advice)) {
			return -1;
		}
	}

#if TYPE_w$ != '-'
	if (r->weight_to) {
		void *beg_weight_to= (void *)((uintptr_t)r->weight_to 
					      / pagesize * pagesize);
		if (0 > posix_madvise(beg_weight_to,
				      (uintptr_t)(r->weight_to) + arraylen_w$(r->len_m) 
				      - (uintptr_t) beg_weight_to,
				      advice)) {
			return -1;
		}
	}

	if (r->weight_from) {
		void *beg_weight_from= (void *)((uintptr_t)r->weight_from 
						/ pagesize * pagesize);
		if (0 > posix_madvise(beg_weight_from,
				      (uintptr_t)(r->weight_from) + arraylen_w$(r->len_m) 
				      - (uintptr_t) beg_weight_from,
				      advice)) {
			return -1;
		}
	}
#endif

#if TYPE_t$ != '-'
	if (r->timestamp_to) {
		void *beg_timestamp_to= (void *)((uintptr_t)r->timestamp_to 
						 / pagesize * pagesize);
		if (0 > posix_madvise(beg_timestamp_to,
				      (uintptr_t)(r->timestamp_to) + arraylen_t$(r->len_m) 
				      - (uintptr_t) beg_timestamp_to,
				      advice)) {
			return -1;
		}
	}

	if (r->timestamp_from) {
		void *beg_timestamp_from= (void *)((uintptr_t)r->timestamp_from 
						   / pagesize * pagesize);
		if (0 > posix_madvise(beg_timestamp_from,
				(uintptr_t)(r->timestamp_from) 
				+ arraylen_t$(r->len_m) 
				- (uintptr_t) beg_timestamp_from,
				advice)) {
			return -1;
		}
	}
#endif

	return 0; 
}

m$_ft sgraph1_degree_to_$(struct sgraph1_reader_$ *r, u$_ft u) 
{
	if (u == r->h->n1 - 1) {
		return r->len_m - read_m$(r->adj_to, u); 
	} else {
		return read_m$(r->adj_to, u + 1) - read_m$(r->adj_to, u); 
	}
}

#endif /* ! SGRAPH1_IO_H */

