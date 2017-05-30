/*
 * Count the triangles in a network.  The input file must be an SG1 file
 * representing a simple graph (SYM, UNWEIGHTED, no loops).
 *
 * The result is written in stdout. 
 *
 * INVOCATION 
 *	$0 INPUT-FILE LOGILE
 *
 * The LOGFILE is ignored.  
 */

#include "width.ma.h"
#include "width.ua.h"
#include "width.va.h"
#include "width.wa.h"
#include "width.ta.h"

#include "graph_width.u.a.h"
#include "graph_width.v.a.h"

#include "sgraph1_io.a.h"

#if FORMAT_a != FORMAT_SYM
#   error "FORMAT_a must be SYM"
#endif

#if WEIGHTS_a != WEIGHTS_UNWEIGHTED
#   error "must be UNWEIGHTED"
#endif

#if TYPE_ua != TYPE_va
#   error "TYPE_ua and TYPE_va must be identical"
#endif

/* There are two algorithms that can be chosen in the next lines. 
 */

/* #define VARIANT 0 */
#define VARIANT 1

#if VARIANT == 1

const ua_at *r_to= NULL;

/*  (1) is much shorter than (2). 
 */
ma_ft common_elements_1(const ma_ft beg1, const ma_ft end1, 
			const ma_ft beg2, const ma_ft end2)
{
	assert(beg1 <= end1);
	assert(beg2 <= end2); 
	assert(beg1 >= end2 || beg2 >= end1); 

	if (beg1 == end1)
		return 0;

	const ma_ft mid1= (beg1 + end1) >> 1;

	const ua_ft x_mid1= read_ua(r_to, mid1);

	ma_ft b2= beg2;
	ma_ft e2= end2;
	
	size_t ret= 0;

	while (b2 < e2) {
		const ma_ft m2= (b2 + e2) >> 1;
		const ua_ft x_m2= read_ua(r_to, m2);

		if (x_m2 < x_mid1) {
			if (b2 == m2) {
				b2= m2 + 1;
				assert(b2 <= e2);
			} else
				b2= m2;
		}
		else if (x_m2 > x_mid1) {
			e2= m2;
		}
		else if (x_m2 == x_mid1) {
			++ ret;
			b2= m2;
			e2= m2 + 1; 
			break;
		}
	}

	assert(b2 >= beg2);
	assert(e2 <= end2);
	assert(b2 <= e2);
	assert(b2 + 1 >= e2); 

	return  ret + common_elements_1(beg1, mid1, beg2, b2) +
		common_elements_1(mid1 + 1, end1, e2, end2) ;
}

/* Return the number of common elements in two sorted lists. 
 */
ma_ft common_elements(ma_ft beg1, ma_ft end1, 
		     ma_ft beg2, ma_ft end2)
{
	assert(beg1 <= end1);
	assert(beg2 <= end2); 
	assert(beg1 >= end2 || beg2 >= end1); 

#define THRESHOLD 18

	if ((end1 - beg1) * THRESHOLD < (end2 - beg2))
		return common_elements_1(beg1, end1, beg2, end2);
	if ((end2 - beg2) * THRESHOLD < (end1 - beg1))
		return common_elements_1(beg2, end2, beg1, end1); 

	size_t ret= 0;

	while (beg1 < end1 && beg2 < end2) {

		const ua_ft x1= read_ua(r_to, beg1);
		const ua_ft x2= read_ua(r_to, beg2);

		assert(SIZE_MAX - 1 >= ret); 
		ret += (x1 == x2);

		if (x1 <= x2)  ++beg1;
		if (x2 <= x1)  ++beg2; 
	}

	return ret; 
}

#endif /* VARIANT == 1 */ 

int main(int argc, char **argv)
{
	if (argc != 3) {
		fprintf(stderr, "*** Expected 2 parameters\n");
		exit(1);
	}

	const char *const filename_sg1= argv[1];

	struct sgraph1_reader_a r;

	if (0 > sgraph1_open_read_a(filename_sg1, &r, 2)) {
		exit(1); 
	}

	if (0 > sgraph1_advise_a(&r, MADV_WILLNEED)) {
		perror(filename_sg1); 
		exit(1);
	}

	uintmax_t t= 0;

	const ma_ft len_m= 2 * r.h->m - r.loops;
	assert(len_m == r.len_m); 
	const ua_ft n= (ua_ft)r.h->n1;
	r_to= r.to;

	for (ua_ft u= 0;  u < n;  ++u) {

		const ma_ft beg1_u= read_ma(r.adj_to, u);
		const ma_ft end1= (u + 1 == n ? len_m : read_ma(r.adj_to, u+1));

		for (ma_ft i= beg1_u;  i < end1;  ++i) {

			const va_ft v= read_va(r.to, i);

			if (v >= u)
				break;

			ma_ft beg1= beg1_u;
			ma_ft beg2= read_ma(r.adj_to, v);
			const ma_ft end2= (v + 1 == n) ? len_m : read_ma(r.adj_to, v+1);
			
			assert(beg1 <= end1);
			assert(beg2 <= end2); 
			assert(beg1 >= end2 || beg2 >= end1); 

#if VARIANT == 0
			while (beg1 < end1 && beg2 < end2) {

				/* This network is without multiple edges */ 
				assert(beg1 + 1 == end1 || read_u(r.to, beg1) < read_u(r.to, beg1 + 1));
				assert(beg2 + 1 == end2 || read_u(r.to, beg2) < read_u(r.to, beg2 + 1));
					    
				const ua_ft x1= read_u(r.to, beg1);
				const ua_ft x2= read_u(r.to, beg2);

				assert(SIZE_MAX - 1 >= t); 
				t += (x1 == x2);

				if (x1 <= x2)  ++beg1;
				if (x2 <= x1)  ++beg2; 
			}
#elif VARIANT == 1

			ma_ft t_uv= common_elements(beg1, end1, beg2, end2); 

			assert(SIZE_MAX - t_uv >= t); 
			t += t_uv;
#endif
		}
	}

	assert(t % 3 == 0); 
	t /= 3;

	if (0 > printf("%" PRIuMAX "\n", t)) {
		perror("printf");
		exit(1); 
	}

	exit(0);
}

