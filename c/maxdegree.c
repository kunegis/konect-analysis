/*
 * Compute the maximum degree of a network. 
 *
 * INVOCATION 
 *    	$0 SG1-FILENAME
 *
 * INPUT
 *    	SG1-FILENAME
 *
 * OUTPUT
 *	stdout:  the maximum degree is printed on stdout
 */

#include <stddef.h>

#include "width.ma.h"
#include "width.ua.h"
#include "width.va.h"
#include "width.wa.h"
#include "width.ta.h"

#include "consts.h"
#include "sgraph1_io.a.h"

#define max(a, b) ((a) > (b) ? (a) : (b))

int main(int argc, char **argv)
{
	if (argc != 2) {
		fprintf(stderr, "*** Invalid number of arguments\n");
		exit(1);
	}

	const char *filename_sg1= argv[1];

	struct sgraph1_reader_a r;
	if (0 != sgraph1_open_read_a(filename_sg1, &r, 1))  
		exit(1);

	if (0 > sgraph1_advise_a(&r, MADV_SEQUENTIAL)) {
		perror(filename_sg1); 
		exit(1);
	}
	
	/* Max TO degree */ 
	ma_ft deg_max_to= 0;
	for (ua_ft u= 0;  u + 1 < (ua_ft) r.h->n1;  ++u) {
		const ma_ft deg_u= read_ma(r.adj_to, u + 1) - read_ma(r.adj_to, u);
		if (deg_u > deg_max_to)
			deg_max_to= deg_u;
	}
	const ma_ft deg_u_last= r.len_m - read_ma(r.adj_to, r.h->n1 - 1);
	if (deg_u_last > deg_max_to)
		deg_max_to= deg_u_last;

#if FORMAT_a == FORMAT_ASYM || FORMAT_a == FORMAT_BIP
	/* Max FROM degree */ 
	ma_ft deg_max_from= 0;
	for (va_ft v= 0;  v + 1 < (va_ft) r.h->n2;  ++v) {
		const ma_ft deg_v= read_ma(r.adj_from, v + 1) - read_ma(r.adj_from, v);
		if (deg_v > deg_max_from)
			deg_max_from= deg_v;
	}
	const ma_ft deg_v_last= r.len_m - read_ma(r.adj_from, r.h->n2 - 1);
	if (deg_v_last > deg_max_from)
		deg_max_from= deg_v_last;
#endif		

#if FORMAT_a == FORMAT_ASYM
	/* Max total degree */ 
	ma_ft deg_max_total= 0;
	for (ua_ft u= 0;  u + 1 < (ua_ft) r.h->n1;  ++u) {
		const ma_ft deg_u_to= read_ma(r.adj_to, u + 1) - read_ma(r.adj_to, u);
		const ma_ft deg_u_from= read_ma(r.adj_from, u + 1) - read_ma(r.adj_from, u);
		const ma_ft deg_u= deg_u_to + deg_u_from; 
		if (deg_u > deg_max_total)
			deg_max_total= deg_u;
	}
	const ma_ft deg_u_to_last= r.len_m - read_ma(r.adj_to, r.h->n1 - 1);
	const ma_ft deg_u_from_last= r.len_m - read_ma(r.adj_from, r.h->n1 - 1);
	const ma_ft deg_u_total_last= deg_u_to_last + deg_u_from_last;
	if (deg_u_total_last > deg_max_total)
		deg_max_total= deg_u_total_last;
#endif

#if FORMAT_a == FORMAT_SYM

	printf("%" PR_fma "\n", deg_max_to);

#elif FORMAT_a == FORMAT_ASYM

	printf("%" PR_fma "\n"
	       "%" PR_fma "\n"
	       "%" PR_fma "\n",
	       deg_max_total,
	       deg_max_to,
	       deg_max_from); 

#elif FORMAT_a == FORMAT_BIP

	printf("%" PR_fma "\n"
	       "%" PR_fma "\n"
	       "%" PR_fma "\n",
	       deg_max_to > deg_max_from ? deg_max_to : deg_max_from,
	       deg_max_to,
	       deg_max_from); 

#endif

	exit(0);
}
