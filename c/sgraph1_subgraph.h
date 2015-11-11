#ifndef SGRAPH1_SUBGRAPH_H
#define SGRAPH1_SUBGRAPH_H

#include "consts.h"
#include "bits.h"

#if TYPE_w$ != '-' || TYPE_t$ != '-' || FORMAT_a != FORMAT_SYM || WEIGHTS_$ != WEIGHTS_UNWEIGHTED
#   error
#endif

int sgraph1_subgraph_$(struct sgraph1_reader_$ *restrict r, 
		       const unsigned char *restrict nodes,
		       const char *restrict filename_out)
{
	assert(r->loops == 0);

	const u$_ft n_old= r->h->n1;
	const u$_ft n_new= BITSCOUNT(nodes, n_old); 

	/* O_RDWR is needed because otherwise the file cannot be mapped, even as read-only */   
	const int fd= open(filename_out, O_CREAT | O_RDWR | O_TRUNC, 0666);
	if (0 > fd) {
		goto error;
	}

	const size_t p_loops= round_m$(sizeof(struct header));
	const size_t p_adj_to= round_m$(p_loops + arraylen_m$(1));
	const size_t p_to= round_u$(p_adj_to + arraylen_m$(n_new));

	size_t l_current= p_to;

	if (0 > ftruncate(fd, l_current)) {
		goto error_fd;
	}

	void *restrict out= mmap(NULL, l_current, PROT_WRITE, MAP_SHARED, fd, 0);
	if (out == MAP_FAILED) {
		goto error_fd;
	}

	/* We would close FD here normally, but we need to keep it
	   around because we are going to truncate the file */ 

	/* Header */ 
	struct header *h= (struct header *) out;
	h->magic64= SGRAPH_MAGIC64;
	h->format= 	r->h->format;
	h->weights= r->h->weights;
	h->version= SGRAPH_VERSION_EDGE;
	h->width_m= r->h->width_m;
	h->width_u= r->h->width_u;
	h->width_v= r->h->width_v;
	h->width_w= r->h->width_w;
	h->width_t= r->h->width_t;
	h->magic32= SGRAPH_MAGIC32;
	h->flags=   0;
	h->n1=      n_new;
	h->n2=      n_new;

	/* Loops */ 
	writeonzero_m$((m$_at *)((uintptr_t)out + p_loops), 0, 0);

	/* New indexes */ 
	u$_at *us= malloc(arraylen_u$(n_old)); 
	u$_ft ua= 0;
	for (u$_ft u= 0;  u < n_old;  ++u) {
		if (BITTEST(nodes, u)) {
			write_u$(us, u, ua); 
			++ ua;
		}
	}

	u$_ft u_new= 0;
	m$_ft i= 0;

	for (u$_ft u_old= 0;  u_old < n_old;  ++u_old) {

		if (! BITTEST(nodes, u_old)) {
			continue;
		}
		
		writeonzero_m$((m$_at *)((uintptr_t)out + p_adj_to), u_new, i); 
		
		const m$_ft beg= read_m$(r->adj_to, u_old);
		const m$_ft end= u_old == n_old - 1 ? r->len_m : read_m$(r->adj_to, u_old + 1);
		const m$_ft d= end - beg; 

		/* Make sure there is place for at least all edges of U */ 
		size_t l_new= p_to + arraylen_u$(i + d);
		if (l_new > l_current) {
			l_new += l_new >> 3;
			if (0 > ftruncate(fd, l_new)) {
				goto error_map;
			}
			out= mremap(out, l_current, l_new, MREMAP_MAYMOVE);
			if (out == MAP_FAILED) {
				goto error_map;
			}
			l_current= l_new;
		}

		/* Write edges */ 
		for (m$_ft j= beg;  j < end;  ++j) {
			const u$_ft v_old= read_u$(r->to, j);
			assert(u_old != v_old); 
			if (BITTEST(nodes, v_old)) {
				const u$_ft v_new= read_u$(us, v_old);
				writeonzero_u$((u$_at *)((uintptr_t)out + p_to), i, v_new);
				++i;
			}
		}
		assert(p_to + arraylen_u$(i) <= l_current); 

		++ u_new; 
	}
	assert(u_new == n_new); 
	assert(i % 2 == 0);
	assert(i <= r->len_m); 

	free(us);

	const size_t l_new= p_to + arraylen_u$(i);
	assert(l_new <= l_current); 
	if (0 > ftruncate(fd, l_new)) {
		goto error_map;
	}
	out= mremap(out, l_current, l_new, MREMAP_MAYMOVE);
	if (out == MAP_FAILED) {
		goto error_map;
	}
	l_current= l_new; 

	h= (struct header *) out;
	h->m= i / 2;

	if (0 > msync(out, l_current, MS_ASYNC)) {
		goto error_map;
	}

	if (0 > munmap(out, l_current)) {
		goto error_fd; 
	}

	if (0 > close(fd))
		goto error_unlink;

	return 0; 

 error_map:
	munmap(out, l_current);

 error_fd:
	close(fd);

 error_unlink:
	unlink(filename_out);

 error:
	return -1;
}

#endif /* ! SGRAPH1_SUBGRAPH */ 
