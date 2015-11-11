#ifndef FEATURE_H
#define FEATURE_H

#include <fcntl.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/mman.h>

#include "consts.h"

#define FEATURE_N2 (FORMAT_$ == FORMAT_ASYM || FORMAT_$ == FORMAT_BIP)

struct header_feature_$ 
{
	m$_ft n1;
#if FEATURE_N2
	m$_ft n2;
#endif
};

struct feature_$
{
	struct header_feature_$ *h; /* beginning of map */ 
	fa_at *f1; 
#if FEATURE_N2
	fa_at *f2; 
#endif
	size_t l; /* length of map */ 
};

/* Open a feature file for writing.  Return 0.  Return -1 on error and output message. 
 */
int feature_open_write_$(const char *filename, 
			 struct feature_$ *f, 
			 const u$_ft n1
#if FEATURE_N2
		       , const u$_ft n2
#endif
		       )
{
#ifndef NDEBUG
	f->h= NULL; 
	f->f1= NULL;
#if FEATURE_N2
	f->f2= NULL;
#endif
	f->l= -1; 
#endif

	const int fd= open(filename, O_CREAT | O_RDWR | O_TRUNC, 0666);
	if (0 > fd) {
		perror(filename);
		return -1;
	}

	const size_t p1= sizeof(struct header_feature_$);
	const size_t l1= p1 + arraylen_f$(n1);
#if FEATURE_N2
	const size_t p2= round_f(l1);
	const size_t l2= arraylen_f(n2);
	const size_t l=  p2 + l2;
#else 
	const size_t l= l1;
#endif	
	
	if (0 > ftruncate(fd, l)) {
		perror(filename);
		goto error_fd;
	}

	void *const out= mmap(NULL, l, PROT_WRITE, MAP_SHARED, fd, 0);
	if (out == MAP_FAILED) {
		perror(filename);
		goto error_fd;
	}

	if (0 > close(fd)) {
		perror(filename); 
		goto error_map; 
	}

	f->h= out;
	f->f1= (fa_at *)((uintptr_t)out + p1);
#if FEATURE_N2
	f->f2= (fa_at *)((uintptr_t)out + p2);
#endif 
	f->l  = l;

	f->h->n1= n1;
#if FEATURE_N2
	f->h->n2= n2;
#endif

	return 0;
	
 error_map:
	if (0 > munmap(out, l)) {
		perror(filename);
	}
	goto error_unlink; 

 error_fd:
	if (0 > close(fd)) {
		perror(filename);
	}

 error_unlink:
	if (0 > unlink(filename)) {
		perror(filename); 
	}

	return -1; 
}

int feature_advise_$(struct feature_$ *f, int advice)
{
	if (0 > posix_madvise(f->h, f->l, advice)) {
		return -1;
	}

	return 0;
}

int feature_close_write_$(struct feature_$ *f)
{
	int ret= 0;

	if (0 > msync(f->h, f->l, MS_ASYNC)) {
		ret= -1;
	}

	if (0 > munmap(f->h, f->l)) {
		ret= -1;
	}

	return ret; 
}

int feature_open_read_$(const char *filename, struct feature_$ *f)
{
#ifndef NDEBUG
	f->h= NULL; 
	f->f1= NULL;
#if FEATURE_N2
	f->f2= NULL;
#endif
	f->l= -1; 
#endif

	const int fd= open(filename, O_RDONLY);
	if (0 > fd) {
		perror(filename);
		return -1;
	}

	struct header_feature_$ h;
	
	if (read(fd, &h, sizeof(struct header_feature_$)) != sizeof(struct header_feature_$)) {
		perror(filename); 
		goto error_fd; 
	}

	const size_t p1= sizeof(struct header_feature_$);
	const size_t l1= p1 + arraylen_f$(h.n1);
#if FEATURE_N2
	const size_t p2= round_f$(l1);
	const size_t l2= arraylen_f$(h.n2);
	const size_t l=  p2 + l2;
#else 
	const size_t l= l1;
#endif	
	
	void *const out= mmap(NULL, l, PROT_READ, MAP_SHARED, fd, 0);
	if (out == MAP_FAILED) {
		perror(filename);
		goto error_fd;
	}

	if (0 > close(fd)) {
		perror(filename); 
		goto error_map; 
	}

	f->h= out;
	f->f1= (fa_at *)((uintptr_t)out + p1);
#if FEATURE_N2
	f->f2= (fa_at *)((uintptr_t)out + p2);
#endif 
	f->l  = l;

	return 0;
	
 error_map:
	if (0 > munmap(out, l)) {
		perror(filename);
	}
	return -1;

 error_fd:
	if (0 > close(fd)) {
		perror(filename);
	}

	return -1; 
}

#endif /* ! FEATURE_H */
