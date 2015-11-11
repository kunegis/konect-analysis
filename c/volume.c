
/*
 * Determine the volume of a network from its SG1 file.  This is
 * trivial, and can be determined without the SG1 file in most cases.
 * This implementation is only used in cases where the SG1 file is the
 * primary version of the dataset (at the moment, only simple~[NETWORK]
 * networks). 
 *
 * The volume is printed to stdout.
 *
 * The input file must not be a POSITIVE network with weight column. 
 *
 * INVOCATION 
 *	$0 INPUT-FILE
 */ 

#include "width__m__h"
#include "width__u__h"
#include "width__v__h"
#include "width__w__h"
#include "width__t__h"

#include "sgraph1_io.h"

#if FORMAT_a == FORMAT_POSITIVE && TYPE_wa != '-'
#   error "the combination of POSITIVE with a weight column is not supported"
#endif 

int main(int argc, char **argv)
{
	if (argc != 2) {
		fprintf(stderr, "*** Invalid number of parameters\n");
		exit(1);
	}

	const char *const filename_sg1= argv[1];

	struct sgraph1_reader r;

	if (0 > sgraph1_open_read(filename_sg1, &r, 0)) {
		exit(1); 
	}

	/* No need for file advisories since we're only reading the
	   header */ 

	const m_ft m= r.h->m;
	
	printf("%" PR_fm "\n", m);

	exit(0);
}
