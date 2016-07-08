/* 
 * Create an SG0 file from an out.* file. 
 *
 * PARAMETERS 
 *	$1	Input filename (out.*, rel.*)
 *      $2	Output filename (sg[0..].*)
 *      $3	n1
 *      $4	n2
 *  	$5	m
 */

#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <ctype.h>
#include <string.h>
#include <assert.h>
#include <unistd.h>
#include <sys/stat.h>
#include <sys/mman.h>

#include "width.ma.h"
#include "width.ua.h"
#include "width.va.h"
#include "width.wa.h"
#include "width.ta.h"

#include "sgraph.h"
#include "consts.h"

int main(int argc, char **argv)
{
	/* This is not specified by C99, but assumed by width.h */ 
	assert(sizeof(float) == 4); 
	assert(sizeof(double) == 8); 

	if (argc != 6) {
		fprintf(stderr, "*** Invalid number of arguments\n"); 
		exit(1); 
	}

	const char *filename_in  = argv[1];
	const char *filename_out = argv[2];
	const char *text_n1      = argv[3];
	const char *text_n2      = argv[4]; 
	const char *text_m 	 = argv[5]; 

	uint64_t n1, n2, m; 

	if (1 != sscanf(text_n1, "%" PRIu64, &n1)) {
		perror(text_n1);
		exit(1); 
	}
	if (1 != sscanf(text_n2, "%" PRIu64, &n2)) {
		perror(text_n2);
		exit(1); 
	}
	if (1 != sscanf(text_m, "%" PRIu64, &m)) {
		perror(text_m);
		exit(1); 
	}
	
	if (n1 > ua_max || n2 > va_max) {
		fprintf(stderr, "*** Sizes are too large for node bit width\n");
		exit(1); 
	}

	/* There is no limit on the number of edges */ 

	const long pagesize= sysconf(_SC_PAGESIZE); 

	/* 
	 * Input
	 */
	const int fd_in= open(filename_in, O_RDONLY); 
	if (fd_in < 0) {
		perror(filename_in);
		exit(1); 
	}

	struct stat stat_in; 
	if (0 > fstat(fd_in, &stat_in)) {
		perror(filename_in);
		exit(1); 
	}

	/* Length in byte of input text file */ 
	const size_t l= stat_in.st_size; 

	const char *in= mmap(NULL, l, PROT_READ, MAP_SHARED, fd_in, 0);
	if (in == MAP_FAILED) {
		perror(filename_in);
		exit(1); 
	}

	if (0 > posix_madvise((void *)in, l, MADV_SEQUENTIAL)) {
		perror("posix_madvise");
		exit(1); 
	}

	/*
	 * Output
	 */ 
	const int fd_out = open(filename_out, O_CREAT | O_RDWR | O_TRUNC, 0666); 
	if (fd_out < 0) {
		perror(filename_out);
		exit(1); 
	}

	const size_t l_h     = sizeof(struct header);
	const size_t p_u     = round_ua(l_h);
	const size_t l_hu    = p_u + arraylen_ua(m);
	const size_t p_v     = round_va(l_hu);
	const size_t l_huv   = p_v + arraylen_va(m);
#if TYPE_wa == '-'
#   if TYPE_ta == '-'
	const size_t l_out   = l_huv; 
#   else
	const size_t p_t     = round_ta(l_huv);
	const size_t l_huvt  = p_t + arraylen_ta(m);
	const size_t l_out   = l_huvt; 
#   endif
#else
	const size_t p_w     = round_wa(l_huv);
	const size_t l_huvw  = p_w + arraylen_wa(m);
#   if TYPE_ta == '-'
	const size_t l_out   = l_huvw;
#   else
	const size_t p_t     = round_ta(l_huvw);
	const size_t l_huvwt = p_t + arraylen_ta(m);
	const size_t l_out   = l_huvwt;
#   endif
#endif

	if (0 > ftruncate(fd_out, l_out)) {
		perror(filename_out);
		goto error_unlink;
	}

	void *out = mmap(NULL, l_out, PROT_WRITE, MAP_SHARED,
			 fd_out, 0); 
	if (out == MAP_FAILED) {
		perror(filename_out); 
		goto error_unlink; 
	}

	if (0 > close(fd_out)) {
		perror(filename_out); 
		goto error_unlink; 
	}

	ua_at *outa_u = (ua_at *)((char *)out + p_u); 
	va_at *outa_v = (va_at *)((char *)out + p_v);
	ua_at *enda_u = (ua_at *)((char *)out + l_hu);
	va_at *enda_v = (va_at *)((char *)out + l_huv);
	void  *beg_u = (void *)((uintptr_t)outa_u / pagesize * pagesize);
	void  *beg_v = (void *)((uintptr_t)outa_v / pagesize * pagesize);
	
	if (0 > posix_madvise(beg_u, (uintptr_t)enda_u - (uintptr_t)beg_u, 
			MADV_SEQUENTIAL)) {
		perror(filename_out); 
		goto error_unlink; 
	}

	if (0 > posix_madvise(beg_v, (uintptr_t)enda_v - (uintptr_t)beg_v, 
			MADV_SEQUENTIAL)) {
		perror(filename_out); 
		goto error_unlink; 
	}

#if TYPE_wa != '-'
	wa_at *outa_w= (wa_at *)((char *)out + p_w);
	wa_at *enda_w= (wa_at *)((char *)out + l_huvw);
	void  *beg_w = (void *)((uintptr_t)outa_w / pagesize * pagesize); 
	if (0 > posix_madvise(beg_w, (uintptr_t)enda_w - (uintptr_t)beg_w, 
			MADV_SEQUENTIAL)) {
		perror(filename_out); 
		goto error_unlink; 
	}
#endif /* W */

#if TYPE_ta != '-'
	ta_at *outa_t = (ta_at *)((char *)out + p_t);
#if TYPE_wa != '-'
	ta_at *enda_t = (ta_at *)((char *)out + l_huvwt);
#else
	ta_at *enda_t = (ta_at *)((char *)out + l_huvt);
#endif
	void *beg_t = (void *)((uintptr_t)outa_t / pagesize * pagesize); 
	if (0 > posix_madvise(beg_t, (uintptr_t)enda_t - (uintptr_t)beg_t, 
			MADV_SEQUENTIAL)) {
		perror(filename_out); 
		goto error_unlink; 
	}
#endif

	const char *p_end = in + l;

	int format = 0;
	int weights = 0; 

	/* Current line */
	const char *p = in; 

	/* First line */
	while (p < p_end && isspace(*p))  ++p;
	if (p == p_end || *p != '%') {
		fprintf(stderr, "*** Invalid header\n");
		goto error_unlink; 
	}
	++p;
	while (p < p_end && isspace(*p))  ++p;
	const char *r = p;
	while (r < p_end && *r >= 'a' && *r <= 'z') ++r;
	if (r == p) {
		fprintf(stderr, "*** Invalid first line\n");
		goto error_unlink; 
	}
		
	if (!strncmp(p, "sym",  r-p))  format = FORMAT_SYM;
	if (!strncmp(p, "asym", r-p))  format = FORMAT_ASYM;
	if (!strncmp(p, "bip",  r-p))  format = FORMAT_BIP; 

	if (!format) {
		fprintf(stderr, "*** Invalid format\n");
		goto error_unlink;
	}

	p = r;
	while (p < p_end && isspace(*p))  ++p;
	r = p; 
	while (r < p_end && *r >= 'a' && *r <= 'z') ++r;
	if (r == p) {
		fprintf(stderr, "*** Invalid header\n");
		goto error_unlink; 
	}
	
	if (!strncmp(p, "unweighted",    r-p))  weights = WEIGHTS_UNWEIGHTED;
	if (!strncmp(p, "positive",      r-p))  weights = WEIGHTS_POSITIVE;
	if (!strncmp(p, "posweighted",   r-p))  weights = WEIGHTS_POSWEIGHTED; 
	if (!strncmp(p, "signed",        r-p))  weights = WEIGHTS_SIGNED; 
	if (!strncmp(p, "multisigned",   r-p))  weights = WEIGHTS_MULTISIGNED; 
	if (!strncmp(p, "weighted",      r-p))  weights = WEIGHTS_WEIGHTED; 
	if (!strncmp(p, "multiweighted", r-p))  weights = WEIGHTS_MULTIWEIGHTED; 
	if (!strncmp(p, "dynamic", 	 r-p))  weights = WEIGHTS_DYNAMIC; 
	
	if (!weights) {
		fprintf(stderr, "*** Invalid weights\n");
		goto error_unlink;
	}

	p = r;
	
	/* Other header lines */
	for (;;) {
		while (p < p_end && isspace(*p))  ++p;
		if (p < p_end && *p == '%') {
			while (p < p_end && *p != '\n')  ++p;
			if (p < p_end) {
				assert(*p == '\n');
				++p;
			}
		} else  
			break; 
	}

	/*
	 * Output header 
	 */

	/* Header consists of 6 times a 64 bit value */ 
	assert(sizeof(struct header) == 6 * 8);

	struct header *h = out; 

	h->magic64 = SGRAPH_MAGIC64;
	h->version = SGRAPH_VERSION_ALL; 
	h->format  = format;
	h->weights = weights; 
	h->width_m = TYPE_ma;
	h->width_u = TYPE_ua;
	h->width_v = TYPE_va;
	h->width_w = TYPE_wa; 
	h->width_t = TYPE_ta;

	h->magic32 = SGRAPH_MAGIC32;
	h->flags   = 0;
	h->m       = m;
	h->n1      = n1;
	h->n2      = n2;

	/* 
	 * Convert
	 */

	size_t i= 0;

	while (p != p_end) {
		assert(i < m);
		assert(p < p_end); 

		/* U */ 
		ua_ft u; 
		p = parse_ua(p, p_end, &u); 
		assert(u != 0);
		u -= 1; 
		assert(u <= ua_max);
		while (p < p_end && isspace(*p))  ++p;

		/* V */ 
		va_ft v; 
		p = parse_va(p, p_end, &v); 
		assert(v != 0); 
		v -= 1; 
		assert(v <= va_max); 
		while (p < p_end && isspace(*p))  ++p;

#if TYPE_wa != '-' 
		/* W */ 
		wa_ft w;
		p = parse_wa(p, p_end, &w);
		while (p < p_end && isspace(*p))  ++p;
#endif /* W */

#if TYPE_ta != '-'
#   if TYPE_wa == '-'
		/* Skip an unused third column (usually only "1") */
		while (p < p_end && !isspace(*p))  ++p;
		while (p < p_end && isspace(*p))  ++p;
#   endif		

		/* T */ 
		ta_ft t;
		p = parse_ta(p, p_end, &t);
		while (p < p_end && isspace(*p))  ++p;
#endif /* T */
		/* Write */ 
		writeonzero_ua(outa_u, i, u);
		writeonzero_va(outa_v, i, v);
#if TYPE_wa != '-'
		writeonzero_wa(outa_w, i, w);
#endif 
#if TYPE_ta != '-'
		writeonzero_ta(outa_t, i, t);
#endif 

		++i;
	}
	
	assert(i == m);

	/*
	 * Close
	 */
	if (0 > msync(out, l_out, MS_ASYNC)) {
		perror(filename_out);
		goto error_unlink; 
	}

	if (0 > munmap(out, l_out)) {
		perror(filename_out); 
		goto error_unlink; 
	}

	exit(0); 

error_unlink:
	if (0 > unlink(filename_out)) {
		perror(filename_out); 
	}

	exit(1); 
}
