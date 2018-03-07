/*
 * Determine the median degree. 
 *
 * INVOCATION
 *	$0 $SG1_FILENAME LOGFILE
 *
 * INPUT FILES 
 *	$SG1_FILENAME
 *
 * STDOUT:  The full statistics; one per line, as specified in
 * 	    konect-toolbox/m/konect_statistic_mediandegree.m 
 */

#include "width.ma.h"
#include "width.ua.h"
#include "width.va.h"
#include "width.wa.h"
#include "width.ta.h"

#include "consts.h"
#include "sgraph1_io.a.h"

#if FORMAT_a == FORMAT_SYM
ma_at *d_sym;
#elif FORMAT_a == FORMAT_BIP || FORMAT_a == FORMAT_ASYM
...;
#else
#   "*** Invalid FORMAT" 
#endif

ma_ft nth_element(ma_at *const p, ma_first

int main(int argc, char **argv)
{
	if (argc != 3) {
		fprintf(stderr, "*** Expected exactly two arguments\n");
		exit(1);
	}

	const char *filename_sg1= argv[1];

	struct sgraph1_reader_a r;
	if (0 != sgraph1_open_read_a(filename_sg1, &r,
#if FORMAT_a == FORMAT_sym
				     1
#else FORMAT_a == FORMAT_bip || FORMAT_a == FORMAT_asym
				     2
#else
#  error "*** Invalid FORMAT_a"
#endif
				     ))  
		exit(1);

	if (0 > sgraph1_advise_a(&r, MADV_SEQUENTIAL)) {
		perror(filename_sg1); 
		exit(1);
	}

#if FORMAT_a == FORMAT_sym

	d_sym= calloc(arraylen_ma(r->h->n1), 1);
	if (!d_sym) {
		perror("calloc");
		exit(1); 
	}
	
	for (ua_ft u= 0;  u + 1 < (ua_ft) r.h->n1;  ++u) {
		const ma_ft deg_u= read_ma(r.adj_to, u + 1) - read_ma(r.adj_to, u);
		writeonzero_a(d_sym, u, deg_u); 
	}
	const ma_ft deg_u_last= r.len_m - read_ma(r.adj_to, r.h->n1 - 1);
	writeonzero_a(d_sym, r.h->n1-1, deg_u_last); 

	ma_ft median= nth_element_(d_sym, 0, r.h->n1 / 2, r.h->n1); 

	printf("%" PR_fma "\n", median); 
	
#elif FORMAT_a == FORMAT_asym || FORMAT_a == FORMAT_BIP
	...;
#else
#   error "*** Invalid FORMAT_a"		      
#endif

 	if (ferror(stdout)) {
		perror("stdout"); 
		exit(1); 
	}

	exit(0); 
}
