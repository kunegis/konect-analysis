
/* Extract the largest connected component of a graph. Input and output
 * files are both SG1 files.  
 */

#include "width.ma.h"
#include "width.ua.h"
#include "width.va.h"
#include "width.wa.h"
#include "width.ta.h"

#include "sgraph1_io.a.h"
#include "sgraph1_subgraph.a.h"
#include "binary_heap.ua.h"
#include "dijkstra.a.h"
#include "lcc.a.h"

#include "consts.h"

#if FORMAT_a != FORMAT_SYM || WEIGHTS_a != WEIGHTS_UNWEIGHTED || LOOPS_a != 0
#   error "*** Only implemented for simple networks"
#endif

/* Invocation:
 *  $0 INPUT-FILE OUTPUTFILE
 */
int main(int argc, char **argv)
{
	assert(argc == 3);
	(void) argc;
	const char *const filename_in= argv[1];
	const char *const filename_out= argv[2];

	struct sgraph1_reader_a r;

	if (0 > sgraph1_open_read_a(filename_in, &r, 2)) {
		exit(1); 
	}

	if (0 > sgraph1_advise_a(&r, MADV_RANDOM)) {
		perror(filename_in);
		exit(1); 
	}

	unsigned char *lcc= lcc_find(&r);

	if (0 > sgraph1_subgraph_a(&r, lcc, filename_out)) {
		exit(1); 
	}

	exit(0); 
}
