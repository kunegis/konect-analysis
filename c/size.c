/*
 * Determine the size of a network from its SG1 file.  This is
 * trivial, and can be determined without the SG1 file in most cases.
 * This implementation is only used in cases where the SG1 file is the
 * primary version of the dataset (at the moment, only simple~[NETWORK]
 * networks). 
 *
 * The size is printed to stdout.
 *
 * INVOCATION 
 *
 *	$0 INPUT-FILE LOGFILE
 */ 

#include "width.ma.h"
#include "width.ua.h"
#include "width.va.h"
#include "width.wa.h"
#include "width.ta.h"

#include "sgraph1_io.a.h"

int main(int argc, char **argv)
{
	if (argc != 3) {
		fprintf(stderr, "*** Invalid number of parameters\n");
		exit(1);
	}

	const char *const filename_sg1= argv[1];

	struct sgraph1_reader_a r;

	if (0 > sgraph1_open_read_a(filename_sg1, &r, 0)) {
		exit(1); 
	}

	/* No need for file advisories since we're only reading the
	 * header.  */ 

	if (r.h->format == FORMAT_SYM || r.h->format == FORMAT_ASYM) {
		assert(r.h->n1 == r.h->n2); 
		const ua_ft n= r.h->n1;
		printf("%" PR_fua "\n", n);
	} else if (r.h->format == FORMAT_BIP) {
		const ua_ft n1= r.h->n1;
		const va_ft n2= r.h->n2;
		const uintmax_t n= n1 + n2;
		printf("%" PRIuMAX "\n"
		       "%" PR_fua "\n"
		       "%" PR_fva "\n",
		       n, n1, n2);
	} else
		assert(0);

	exit(0);
}
