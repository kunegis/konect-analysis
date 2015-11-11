#ifndef SGRAPH_IO_H
#define SGRAPH_IO_H

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdio.h>
#include <unistd.h>
#include <sys/mman.h>
#include <assert.h>

#include "sgraph.h"
#include "consts.h"

/* Reader for Sgraph version 0.
 */

struct sgraph0_reader_$
{
	int cols;

	int _fd;

	void *out;

	/* Size of mapped region */ 
	size_t l_out;

	u$_at *u;
	v$_at *v;

#if TYPE_w$ != '-'
	w$_at *w;
#endif

#if TYPE_t$ != '-'
	t$_at *t;
#endif
};

/* Open an Sgraph file (version 0) for reading.
 * Fill R.
 * Cols is the number of columns to read:  
 *  2:  only U and V
 *  3:  also W 
 *  4:  also T
 * Return 0 on success, -1 on failure. 
 */
int sgraph0_open_read_$(const char *filename,
			struct sgraph0_reader_$ *r,
			int cols)
{
	assert(cols >= 2 && cols <= 4); 

	r->_fd= open(filename, O_RDONLY);
	if (r->_fd < 0) {
		perror(filename);
		goto error;
	}

	struct stat buf;
	if (0 > fstat(r->_fd, &buf)) {
		perror(filename);
		goto error_close;
	}

	struct header h;
	if (read(r->_fd, &h, sizeof(struct header)) < (ssize_t)sizeof(struct header)) {
		perror(filename);
		goto error_close;
	}

	if (h.magic32 != SGRAPH_MAGIC32 ||
	    h.magic64 != SGRAPH_MAGIC64) {
		fprintf(stderr, "*** Invalid magic numbers\n");
		goto error_close;
	}

	if (h.version != SGRAPH_VERSION_ALL) {
		fprintf(stderr, "*** Invalid Sgraph version\n"); 
		goto error_close;
	}
	    
	if (h.width_m != TYPE_m$) {
		fprintf(stderr, "*** Invalid M width '%c'\n", h.width_m);
		goto error_close;
	}
	if (h.width_u != TYPE_u$) {
		fprintf(stderr, "*** Invalid U width '%c'\n", h.width_u);
		goto error_close;
	}
	if (h.width_v != TYPE_v$) {
		fprintf(stderr, "*** Invalid V width '%c'\n", h.width_v);
		goto error_close;
	}
	if (h.width_w != TYPE_w$) {
		fprintf(stderr, "*** Invalid W width '%c'\n", h.width_w);
		goto error_close;
	}
	if (h.width_t != TYPE_t$) {
		fprintf(stderr, "*** Invalid T width '%c'\n", h.width_t);
		goto error_close;
	}

	if ( ! (h.format == FORMAT_BIP || h.n1 == h.n2)) {
		fprintf(stderr, "*** Invalid sizes\n");
		goto error_close;
	}

	r->cols= cols; 

	size_t p_u, p_v;
#if TYPE_w$ != '-'
	size_t p_w= -1;
#endif	
#if TYPE_t$ != '-'
	size_t p_t= -1;
#endif	

	const size_t l_h                     = sizeof(struct header);
	p_u     	                     = round_u$(l_h);
	const size_t l_hu                    = p_u + arraylen_u$(h.m);
	p_v                                  = round_v$(l_hu);
	const size_t l_huv                   = p_v + arraylen_v$(h.m);
#if TYPE_w$ == '-'
#   if TYPE_t$ == '-'
	r->l_out                             = l_huv; 
#   else
	if (cols >= 4) {
		p_t                          = round_t$(l_huv);
		const size_t l_huvt          = p_t + arraylen_t$(h.m);
		r->l_out                     = l_huvt; 
	} else {
		r->l_out                     = l_huv;
	}
#   endif
#else
	if (cols >= 3) {
		p_w                          = round_w$(l_huv);
		const size_t l_huvw          = p_w + arraylen_w$(h.m);
#   if TYPE_t$ == '-'
		r->l_out                     = l_huvw;
#   else
		if (cols >= 4) {
			p_t                  = round_t$(l_huvw);
			const size_t l_huvwt = p_t + arraylen_t$(h.m);
			r->l_out             = l_huvwt;
		} else {
			r->l_out             = l_huvw;
		}
#   endif
	} else {
		r->l_out                     = l_huv;
	}
#endif

	if ((cols == 4 && r->l_out != (size_t)buf.st_size) ||
	    (cols  < 4 && r->l_out  > (size_t)buf.st_size)) {
		fprintf(stderr, "*** '%s':  Invalid file size\n",
			filename);
		goto error_close;
	}

	r->out = mmap(NULL, r->l_out, PROT_READ, MAP_SHARED, r->_fd, 0); 
	if (r->out == MAP_FAILED) {
		perror(filename); 
		goto error_close; 
	}

	r->u= (u$_at *)((char *)r->out + p_u);
	r->v= (v$_at *)((char *)r->out + p_v);
#if TYPE_w$ != '-'
	if (cols >= 3) {
		r->w= (w$_at *)((char *)r->out + p_w);
	} else {
		r->w= NULL;
	}
#endif	
#if TYPE_t$ != '-'
	if (cols >= 4) {
		r->t= (t$_at *)((char *)r->out + p_t);
	} else {
		r->t= NULL;
	}
#endif	

	return 0;

 error_close:
	assert(r->_fd >= 0);
	close(r->_fd); 
#ifndef NDEBUG
	r->_fd= -1;
	r->out= NULL;
	r->u= NULL;
	r->v= NULL;
#   if TYPE_w$ != '-'
	r->w= NULL;
#   endif
#   if TYPE_t$ != '-'
	r->t= NULL;
#   endif
#endif

 error:
	return -1;
}

/* Return 0.
 * Return -1 on error, without output. 
 */
int sgraph0_advise_$(struct sgraph0_reader_$ *r, 
		     int advice)
{
	const long pagesize = sysconf(_SC_PAGESIZE); 

	struct header *h= (struct header *) r->out; 

	void *beg_u = (void *)((uintptr_t)r->u / pagesize * pagesize);
	void *beg_v = (void *)((uintptr_t)r->v / pagesize * pagesize);

	if (0 > posix_madvise(beg_u, 
			(uintptr_t)(r->u) + arraylen_u$(h->m) - (uintptr_t)beg_u, 
			advice)) {
		return -1;
	}

	if (0 > posix_madvise(beg_v, 
			(uintptr_t)(r->v) + arraylen_v$(h->m) - (uintptr_t)beg_v, 
			advice)) {
		return -1;
	}

#if TYPE_w$ != '-'
	if (r->w != NULL) {
		void *beg_w = (void *)((uintptr_t)r->w / pagesize * pagesize);
		if (0 > posix_madvise(beg_w, 
				(uintptr_t)(r->w) + arraylen_w$(h->m) - (uintptr_t)beg_w, 
				advice)) {
			return -1;
		}
	}
#endif

#if TYPE_t$ != '-'
	if (r->t != NULL) {
		void *beg_t = (void *)((uintptr_t)r->t / pagesize * pagesize);
		if (0 > posix_madvise(beg_t, 
				(uintptr_t)(r->t) + arraylen_t$(h->m) - (uintptr_t)beg_t, 
				advice)) {
			return -1;
		}
	}
#endif

	return 0; 
}

void sgraph0_close_$(struct sgraph0_reader_$ *r)
{
	munmap(r->out, r->l_out);
	close(r->_fd);

#ifndef NDEBUG
	r->out= NULL;
	r->_fd= -1;
#endif	
}

#endif /* ! SGRAPH_IO_H */
