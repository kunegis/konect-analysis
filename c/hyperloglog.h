#ifndef HYPERLOGLOG_H
#define HYPERLOGLOG_H

/* 
 * Implementation of the HyperLogLog counter [1], as used in the
 * HyperANF algorithm.    
 *
 * REFERENCES 
 *  [1] Marianne Durand and Philippe Flajolet, LogLog counting of large
 *      cardinalities In Annual European Symposium on Algorithms, pages
 *      605-617, 2003.
 */

#include <math.h>

/* 
 * Constants
 */

// TODO:  choose B in a more sensible way 
#define HYPERLOGLOG_B_$ 6

#define HYPERLOGLOG_M_$ (1 << HYPERLOGLOG_B_$)

#if HYPERLOGLOG_M_$ == 16
#   define HYPERLOGLOG_ALPHA_$_ 0.673
#elif HYPERLOGLOG_M_$ == 32
#   define HYPERLOGLOG_ALPHA_$_ 0.697
#elif HYPERLOGLOG_M_$ == 64
#   define HYPERLOGLOG_ALPHA_$_ 0.709
#else
#   define HYPERLOGLOG_ALPHA_$_ (0.7213 / (1.0 + 1.079 / HYPERLOGLOG_M_$))
#endif

#define HYPERLOGLOG_ALPHA_$ (HYPERLOGLOG_ALPHA_$_ * HYPERLOGLOG_M_$ * HYPERLOGLOG_M_$)

/* An unsigned type that is twice as wide as u_t. 
 */
#if BITS_$ <= 4
typedef uint8_t $_2t; 
#   define PR_2$ PRIu16
#elif BITS_$ == 8
typedef uint16_t $_2t; 
#   define PR_2$ PRIu16
#elif BITS_$ == 16
typedef uint32_t $_2t;
#   define PR_2$ PRIu32
#elif BITS_$ == 32
typedef uint64_t $_2t;
#   define PR_2$ PRIu64
#else
#   error "Unsupported bit width"
#endif

/*
 * An unsigned type that can hold at least at least sizeof(u_t) *
 * CHAR_BIT bits 
 */ 

typedef uint8_t $_bt;
#   define $_BT_MAX UINT8_MAX

/* A hash function
 */
#if BITS_$ <= 32

typedef uint32_t $_hash_t; 

/* From http://burtleburtle.net/bob/hash/integer.html
 */
$_hash_t hyperloglog_hash_$($_hash_t x)
{
	x = (x ^ 61) ^ (x >> 16);
	x = x + (x << 3);
	x = x ^ (x >> 4);
	x = x * 0x27d4eb2d;
	x = x ^ (x >> 15);
	return x;
}

#else
#   error "Unsupported bit width"
#endif

#define HYPERLOGLOG_N_$ (HYPERLOGLOG_M_$ * sizeof($_bt) / sizeof(unsigned))

struct hyperloglog_$
{
	union {
		$_bt M[HYPERLOGLOG_M_$]; 
		unsigned N[HYPERLOGLOG_N_$];
	} x;
};

/* Initialize a HyperLogLog counter.  This just zeroes the structure,
   which means that instead of this it is also possible to use memset or
   calloc for initialization. 
 */
void hyperloglog_create_$(struct hyperloglog_$ *hll);

void hyperloglog_add_$(struct hyperloglog_$ *hll, $_ft x);

/* The function \rho^+, i.e., the number of leading zeroes plus one. 
 */ 
unsigned hyperloglog_num_zeroes_$($_hash_t x);

long double hyperloglog_value_$(const struct hyperloglog_$ *hll);

void hyperloglog_create_$(struct hyperloglog_$ *hll) 
{
	memset(hll, '\0', sizeof(*hll)); 
}

/* 
 * Add an item to a HyperLogLog counter.
 * 
 * str:  string to add to the counter
 * size:  length of the string
 */
void hyperloglog_add_$(struct hyperloglog_$ *hll, $_ft x)
{
	const $_hash_t hash= hyperloglog_hash_$(x); 
	const unsigned index= hash & (HYPERLOGLOG_M_$ - 1); 
	assert(index < HYPERLOGLOG_M_$); 
	const unsigned rho= hyperloglog_num_zeroes_$(hash >> HYPERLOGLOG_B_$);
	assert(rho <= $_BT_MAX); 
	if (rho > hll->x.M[index]) {
		hll->x.M[index]= rho;
	}
}

unsigned hyperloglog_num_zeroes_$($_hash_t x)
{
	if (sizeof($_hash_t) == sizeof(unsigned int)) {
		return ffs(x); 
	} else {
		/* If needed, use ffsl / ffsll */ 
		assert(0); 
	}
}

long double hyperloglog_value_$(const struct hyperloglog_$ *hll)
{
	long double num= 0.0;

	for ($_ft i= 0;  i < HYPERLOGLOG_M_$;  ++i) {
		num += pow(2.0, - (double) hll->x.M[i]);
	}

	long double value= HYPERLOGLOG_ALPHA_$ / num;

	if (value <= 2.5 * HYPERLOGLOG_M_$) {
		$_ft cont= 0;
		for ($_ft i = 0;  i < HYPERLOGLOG_M_$;  ++i) {
			if (hll->x.M[i] == 0) {
				++cont;
			}
		}
		if (cont != 0) {
			value = HYPERLOGLOG_M_$ * log((long double) HYPERLOGLOG_M_$ / cont);
		}
	} else if (value > (1.0/30.0) * (long double) 4294967296.0) {
		value = -4294967296.0 * log(1.0 - value / 4294967296.0);
	}

	return value;
}

#endif /* ! HYPERLOGLOG_H */

