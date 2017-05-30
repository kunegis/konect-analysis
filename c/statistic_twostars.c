/* 
 * Compute the number of wedges. 
 *
 * INVOCATION 
 *
 *      $0 FT-DEGREE-FILE LOGFILE
 *
 * The statistics are written to stdout.
 */ 

#include <stdio.h>

#include "width.ma.h"
#include "width.ua.h"
#include "width.va.h"
#include "width.fa.h"

#include "feature.a.h"

#include "consts.h"

int main(int argc, char **argv)
{
	if (argc != 3) {
		fprintf(stderr, "*** Invalid number of arguments\n");
		exit(1);
	}

	const char *const filename= argv[1];

	struct feature_a f;

	if (0 > feature_open_read_a(filename, &f)) {
		perror(filename);
		exit(1);
	}

	if (0 > feature_advise_a(&f, MADV_SEQUENTIAL)) {
		perror(filename); 
		exit(1)
	}
	
	/* 
	 * Total
	 */

	uintmax_t s= 0;

#if FORMAT_a == FORMAT_SYM

	for (ua_ft u= 0;  u < f.h->n1;  ++u) {
		const fa_ft d= read_fa(f.f1, u);
		s += (d * (d - 1) / 2); 
	}

#elif FORMAT_a == FORMAT_ASYM 

	for (ua_ft u= 0;  u < f.h->n1;  ++u) {
		const fa_ft d_out= read_fa(f.f1, u);
		const fa_ft d_in=  read_fa(f.f2, u);
		const fa_ft d= d_out + d_in;
		s += (d * (d - 1) / 2);
	}

#elif FORMAT_a == FORMAT_BIP

	for (ua_ft u= 0;  u < f.h->n1;  ++u) {
		const fa_ft d= read_fa(f.f1, u);
		s += (d * (d - 1) / 2); 
	}
	
	for (va_ft v= 0;  v < f.h->n2;  ++v) {
		const fa_ft d= read_fa(f.f2, v);
		s += (d * (d - 1) / 2); 
	}

#else
#   error "*** Invalid format"
#endif	

	printf("%" PRIuMAX "\n", s); 

	/*
	 * Left and right
	 */

#if FORMAT_a == FORMAT_BIP || FORMAT_a == FORMAT_ASYM

	uintmax_t s1= 0;
	for (ua_ft u= 0;  u < f.h->n1;  ++u) {
		const fa_ft d= read_fa(f.f1, u);
		s1 += (d * (d - 1) / 2); 
	}

	printf("%" PRIuMAX "\n", s1);
	
	uintmax_t s2= 0;
	for (va_ft v= 0;  v < f.h->n2;  ++v) {
		const fa_ft d= read_fa(f.f2, v);
		s2 += (d * (d - 1) / 2); 
	}

	printf("%" PRIuMAX "\n", s2);

#endif

	exit(0);
}
