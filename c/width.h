/*
 * Declares symbols and functions related to one variable-width data
 * type (decided at compile time).
 *
 * In this file, '$' is replaced by the name character. 
 *
 * MACRO PARAMETERS (defined by the file including this file)
 *
 *    TYPE_$ The character constant representing this type
 * 
 * List of types:
 *
 *     		  b     C 	TYPE	NOTE
 *
 *         NO *			'-'	
 *
 *   UNSIGNED *	  1	0	'a'    	{0, +1}; only when explicit 0 is needed
 *   UNSIGNED *	  2	0	'b'	{0, ..., 3}
 *   UNSIGNED *   4	0	'c'	{0, ..., 15} enough for 5-star ratings
 *   UNSIGNED *	  8	0	'd'	{0, ..., 255}
 *   UNSIGNED *	 16	0	'e'	{0, ..., 65535}
 *   UNSIGNED *	 32	0	'f'	enough for almost all known networks as node ID
 *   UNSIGNED *  64	0	'g'	there're a few networks with this
 *
 *     SIGNED *   1	1 	'A'	{-1, +1} with -1 mapping to 1 (sign bit) (special mapping)
 *     SIGNED *	  2	1	'B'	{-2, -1, 0, +1}; enough for {-1,0,+1} weights
 *     SIGNED *   4	1	'C'	{-8, ..., +7}
 *     SIGNED *	  8	1	'D'	{-128, ..., +127}
 *     SIGNED *  16	1	'E'	    
 *     SIGNED *	 32	1	'F'	
 *     SIGNED	 64	1	'G'	
 *
 *      FLOAT    16	2	'4'	half-precision
 *      FLOAT *  32	2	'5'	standard float
 *	FLOAT *	 64	2	'6'	double precision 
 *      FLOAT   128	2	'7'	quad precision
 *
 *      (*) implemented
 *       b  bits
 *       C  class
 */

#if TYPE_$ != '-'

#include <stdint.h>
#include <limits.h>
#include <inttypes.h>
#include <stdlib.h>
#include <assert.h>
#include <ctype.h>
#include <string.h>

#include "widthhelper.h"

/* 
 * Bits widths and types 
 */ 

static const char type_$ = TYPE_$; 

#if   TYPE_$ >= 'a' && TYPE_$ <= 'z'
#   define CLASS_$ CLASS_UNSIGNED
#elif TYPE_$ >= 'A' && TYPE_$ <= 'Z'
#   define CLASS_$ CLASS_SIGNED
#elif TYPE_$ >= '0' && TYPE_$ <= '9'
#   define CLASS_$ CLASS_FLOAT
#else 
#   error "Invalid bit width"
#endif

#if   TYPE_$ == 'a'
#   define BITS_$ 1
#elif TYPE_$ == 'b'
#   define BITS_$ 2
#elif TYPE_$ == 'c'
#   define BITS_$ 4
#elif TYPE_$ == 'd'
#   define BITS_$ 8
#elif TYPE_$ == 'e'
#   define BITS_$ 16
#elif TYPE_$ == 'f'
#   define BITS_$ 32
#elif TYPE_$ == 'g'
#   define BITS_$ 64
#elif TYPE_$ == 'A'
#   define BITS_$ 1
#elif TYPE_$ == 'B'
#   define BITS_$ 2
#elif TYPE_$ == 'C'
#   define BITS_$ 4
#elif TYPE_$ == 'D'
#   define BITS_$ 8
#elif TYPE_$ == 'E'
#   define BITS_$ 16
#elif TYPE_$ == 'F'
#   define BITS_$ 32
#elif TYPE_$ == '5'
#   define BITS_$ 32
#else 
#   error "Invalid bit width"
#endif

/*
 * Type definitions
 */

#if CLASS_$ == CLASS_UNSIGNED

/* The type itself */
#   if BITS_$ >= CHAR_BIT
typedef CONCAT3(uint, BITS_$, _t) $_t;
#   endif

/* The fast variant */
#   if BITS_$ < CHAR_BIT
typedef unsigned $_ft;
#      define PR_f$ "u"
#   else
typedef CONCAT3(uint_fast, BITS_$, _t) $_ft;
#      define PR_f$ CONCAT2(PRIuFAST, BITS_$)
#   endif

/* Small type that can represent the type and be adressed */ 
#   if BITS_$ < CHAR_BIT
typedef unsigned char $_lt;
#   else
typedef $_t $_lt;
#   endif

/* The array type */ 
#   if BITS_$ < CHAR_BIT
typedef unsigned $_at;
#   else
typedef $_t $_at; 
#   endif

#elif CLASS_$ == CLASS_SIGNED

/* The type itself */
#   if BITS_$ >= CHAR_BIT
typedef CONCAT3(int, BITS_$, _t) $_t;
#   endif

/* The fast variant */
#   if BITS_$ < CHAR_BIT
typedef signed $_ft;
#      define PR_f$ "d"
#   else
typedef CONCAT3(int_fast, BITS_$, _t) $_ft;
#      define PR_f$ CONCAT2(PRIdFAST, BITS_$)
#   endif

/* Small type that can represent the type and  be adressed */ 
#   if BITS_$ < CHAR_BIT
typedef signed char $_lt;
#   else
typedef $_t $_lt;
#   endif

/* The array type */ 
#   if BITS_$ < CHAR_BIT
typedef unsigned $_at;
#   else
typedef $_t $_at; 
#   endif

#elif CLASS_$ == CLASS_FLOAT

#   if BITS_$ == 32
typedef float  $_t; 
typedef double $_ft; 
#   elif BITS_$ == 64
typedef double $_t; 
typedef double $_ft; 
#   else
#      error "Invalid float type"
#   endif

typedef $_t $_lt;
typedef $_t $_at; 

#endif /* floating point type */ 

				  
/*
 * Constants
 */

#if CLASS_$ == CLASS_UNSIGNED

/* Maximal representable value */
#   if BITS_$ < CHAR_BIT
static const $_ft $_max = (1 << BITS_$) - 1;
#   else
static const $_ft $_max = CONCAT3(UINT, BITS_$, _MAX);
#   endif

/* A value with all bits set to one as a mask */ 
#   if BITS_$ < CHAR_BIT
static const $_at $_full = UINT_MAX;
#   endif

#elif CLASS_$ == CLASS_SIGNED

/* Maximal representable value */
#   if BITS_$ < CHAR_BIT
static const $_ft $_max = (1 << (BITS_$ - 1)) - 1;
static const $_ft $_min = - (1 << (BITS_$ - 1));
#   else
static const $_ft  $_max = CONCAT3(INT, BITS_$, _MAX);
#   endif

#   if BITS_$ < CHAR_BIT
static const $_at $_full = UINT_MAX;
#   endif

#elif CLASS_$ == CLASS_FLOAT

/* *_max is not defined */ 

/* *_full is not defined */ 

#endif


/*
 * Parsing
 */

/* Parse the string beginning at P, ending at P_END.  Return the value
 * in X, and the new P as a return value. 
 */
const char *parse_$(const char *p,
		    const char *p_end,
		    $_ft *x);

/* The parse_* function returns the new value of P.  If the value cannot
 * be parsed, P is returned.  
 */

#if TYPE_$ == 'A' /* sign bit */ 

const char *parse_$(const char *p, const char *p_end, $_ft *x)
{
	*x = +1;
	assert(p < p_end);
	if (*p == '-') {
		*x= -1;
		++p;
	} else if (*p == '+') {
		++p;
	}
	
	if (p < p_end && *p == '1') {
		++p;
	}

	return p;
}

#elif CLASS_$ == CLASS_UNSIGNED

const char *parse_$(const char *p, const char *p_end, $_ft *x)
{
	*x = 0;
	while (p < p_end && *p >= '0' && *p <= '9') {
		*x *= 10;
		*x += (*p - '0');
		++p; 
	}
	return p; 
}

#elif CLASS_$ == CLASS_SIGNED

const char *parse_$(const char *p, const char *p_end, $_ft *x)
{
	*x = 0;

	int sign = +1; 

	if (p < p_end && *p == '-') {
		sign = -1; 
		++p;
	} else if (p < p_end && *p == '+') {
		sign = +1;
		++p;
	}

	while (p < p_end && *p >= '0' && *p <= '9') {
		*x *= 10;
		*x += (*p - '0');
		++p; 
	}

	*x *= sign; 

	return p; 
}

#elif CLASS_$ == CLASS_FLOAT

const char *parse_$(const char *p, const char *p_end, $_ft *x)
{
	const char *q = p;
	while (q < p_end && ! isspace(*q))  ++q;
	if (q == p)  return p;
	if (q == p_end) return p;
	const char *q_end;
	*x = strtod(p, (char **)&q_end);
	assert(q_end == q);
	return q;
}

#endif

/*
 * Write a value in an array 
 */

/* Read from an array */ 
$_ft read_$(const $_at *p, size_t i);

/* Write the value X into the array P at position I */ 
void write_$($_at *p, size_t i, $_ft x);

/* Write a value X in the array P at position I, which is already
 * initialized to zero */ 
void writeonzero_$($_at *p, size_t i, $_ft x);

/* Copy N elements from SRC starting at SRC_OFF to DST starting at
 * DST_OFF.  The destination and source arrays must not overlap.  The
 * destination array must be initialized with zero. 
 */
void copyonzero_$($_at *dst, size_t dst_off, $_at *src, size_t src_off, size_t n);

/* Increment one entry in array */ 
void inc_$($_at *p, size_t i);

#if TYPE_$ == 'A' /* sign bit */ 

$_ft read_$(const $_at *p, size_t i)
{
	return 1 - 
		((
	(p[i / (sizeof($_at) * CHAR_BIT / BITS_$)]
	 >> (BITS_$ * (i % (sizeof($_at) * CHAR_BIT / BITS_$))))
	&
	((1 << BITS_$) - 1)
		  )  << 1)
		;
}

void write_$($_at *p, size_t i, $_ft x)
{
	int w= (x < 0);

	p[i / (sizeof($_at) * CHAR_BIT / BITS_$)]
		&= ~(1 << (BITS_$ * (i % (sizeof($_at) * CHAR_BIT / BITS_$))));

	p[i / (sizeof($_at) * CHAR_BIT / BITS_$)]
		|= 
		($_at)(($_at)w << (BITS_$ * (i % (sizeof($_at) * CHAR_BIT / BITS_$))));
}

void writeonzero_$($_at *p, size_t i, $_ft x)
{
	int w= (x < 0);

	p[i / (sizeof($_at) * CHAR_BIT / BITS_$)]
		|= 
		($_at)(($_at)w << (BITS_$ * (i % (sizeof($_at) * CHAR_BIT / BITS_$))));
}

#elif BITS_$ >= CHAR_BIT

$_ft read_$(const $_at *p, size_t i)
{
	return p[i];
}

void write_$($_at *p, size_t i, $_ft x)
{
	p[i]= x;
}

void writeonzero_$($_at *p, size_t i, $_ft x)
{
	p[i]= x;
}

void inc_$($_at *p, size_t i)
{
	++p[i];
}

#else /* BITS_$ < CHAR_BIT */ 

$_ft read_$(const $_at *p, size_t i)
{
	$_ft ret = 
	(p[i / (sizeof($_at) * CHAR_BIT / BITS_$)]
	 >> (BITS_$ * (i % (sizeof($_at) * CHAR_BIT / BITS_$))))
		&
		((1 << BITS_$) - 1);

#if CLASS_$ == CLASS_SIGNED
	/* Sign-extend the integer */ 
	struct {signed b: BITS_$; } b;
	b.b = ret;
	ret= b.b;

	assert(ret >= $_min);
#endif
	assert(ret <= $_max); 

	return ret;
}

void write_$($_at *p, size_t i, $_ft x)
{
	assert(x <= $_max); 

#if CLASS_$ == CLASS_SIGNED
	assert(x >= $_min); 

	if (x < 0) {
		x = x & ((1 << BITS_$) - 1); 
	}
	assert(x >= 0);
	assert(x < (1 << BITS_$)); 
#endif

	p[i / (sizeof($_at) * CHAR_BIT / BITS_$)]
		&=
		~(((1 << BITS_$) - 1) << (BITS_$ * (i % (sizeof($_at) * CHAR_BIT / BITS_$))));
	p[i / (sizeof($_at) * CHAR_BIT / BITS_$)]
		|= 
		($_at)(($_at)x << (BITS_$ * (i % (sizeof($_at) * CHAR_BIT / BITS_$))));
}

void writeonzero_$($_at *p, size_t i, $_ft x)
{
	assert(x <= $_max); 

#if CLASS_$ == CLASS_SIGNED
	assert(x >= $_min); 

	if (x < 0) {
		x = x & ((1 << BITS_$) - 1); 
	}
	assert(x >= 0);
#endif

	p[i / (sizeof($_at) * CHAR_BIT / BITS_$)]
	 |= 
		($_at)(($_at)x << (BITS_$ * (i % (sizeof($_at) * CHAR_BIT / BITS_$))));
}

void inc_$($_at *p, size_t i)
{
	/* Note:  on overflow, this will spill onto the next array
	 * element. 
	 */
	assert(read_$(p, i) < $_max); 

	p[i / (sizeof($_at) * CHAR_BIT / BITS_$)]
		+= 
		(1 << (BITS_$ * (i % (sizeof($_at) * CHAR_BIT / BITS_$))));
}

#endif

#if BITS_$ < CHAR_BIT

void copyonzero_$($_at *dst, size_t dst_off, $_at *src, size_t src_off, size_t n)
{
	for (size_t i= 0;  i < n;  ++i) {
		const $_ft x= read_$(src, src_off + i);
		writeonzero_$(dst, dst_off + i, x); 
	}
}

#else

void copyonzero_$($_at *dst, size_t dst_off, $_at *src, size_t src_off, size_t n)
{
	memcpy(dst + dst_off, src + src_off, n * sizeof($_at));
}

#endif


/* 
 * Size computation functions. 
 */

/* Round an offset up to be aligned with the array type */ 
size_t round_$(size_t l); 

/* Size of the array needed to hold N elements.  
 * The size is in bytes, not array elements. */ 
size_t arraylen_$(size_t n);

/* The number of elements that fit into an array of N bytes */  
size_t arrayn_$(size_t n);

/* Implementations */ 

size_t round_$(size_t l)
{
	return (l + (sizeof($_at) - 1)) & ~(sizeof($_at) - 1);
}

#if BITS_$ >= CHAR_BIT

size_t arraylen_$(size_t n)
{
	return sizeof($_t) * n;
}

#else 

size_t arraylen_$(size_t n)
{
	return ((n * BITS_$ + CHAR_BIT * sizeof($_at) - 1) & ~(CHAR_BIT * sizeof($_at) - 1)) / CHAR_BIT; 
}

#endif

size_t arrayn_$(size_t n)
{
	/* Note:  an array can only have a length that is a multiple of $_at. 
	 */

	return (n & ~(sizeof($_at) - 1)) * CHAR_BIT / BITS_$; 
}

#endif /* TYPE_$ != '-' */ 


