/*
 * Generate the degree vector of a network.
 *
 * INVOCATION
 *     $0 SG1-FILE DEGREE-FILE LOGFILE
 */

#include "width.ma.h"
#include "width.ua.h"
#include "width.va.h"
#include "width.wa.h"
#include "width.ta.h"
#include "width.fa.h"

#include "sgraph1_io.a.h"
#include "feature.a.h"

#if WEIGHTS_a == WEIGHTS_POSITIVE && TYPE_wa != '-'
/* In that case, need to sum up the weights */ 
#   error "*** Not implemented"
#endif

int main(int argc, char **argv)
{
	if (argc != 4) {
		fprintf(stderr, "*** Invalid number of parameters\n");
		exit(1);
	}

	const char *const filename_sg1= argv[1];
	const char *const filename_ft= argv[2];
	/* The LOGFILE is ignore */
	
	struct sgraph1_reader_a r;

	if (0 > sgraph1_open_read_a(filename_sg1, &r, 2)) {
		exit(1); 
	}

	if (0 > sgraph1_advise_a(&r, MADV_SEQUENTIAL)) {
		perror(filename_sg1); 
		exit(1);
	}

	struct feature_a f;

	if (0 > feature_open_write_a(filename_ft, &f, r.h->n1
#if FEATURE_N2
			      , r.h->n2
#endif
			      )) {
		exit(1);
	}

	if (0 > feature_advise_a(&f, MADV_SEQUENTIAL)) {
		perror(filename_ft);
		exit(1);
	}

	for (ua_ft u= 0;  u < r.h->n1;  ++u) {
		const ma_ft beg= read_ma(r.adj_to, u);
		const ma_ft end= u == r.h->n1 - 1 ? r.len_m : read_ma(r.adj_to, u + 1);
		assert(beg <= end); 
		assert((ma_ft)(end - beg) < fa_max); 
		writeonzero_fa(f.f1, u, end - beg); 
	}

#if FEATURE_N2
	for (va_ft v= 0;  v < r.h->n2;  ++v) {
		const ma_ft beg= read_ma(r.adj_from, v);
		const ma_ft end= v == r.h->n2 - 1 ? r.len_m : read_ma(r.adj_from, v + 1);
		assert((ma_ft) (end - beg) < fa_max); 
		writeonzero_fa(f.f2, v, end - beg); 
	}
#endif

	if (0 > feature_close_write_a(&f)) {
		perror(filename_ft);
		if (0 > unlink(filename_ft)) {
			perror(filename_ft); 
		}
		exit(1); 
	}

	exit(0); 
}


