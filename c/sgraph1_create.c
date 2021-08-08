/*
 * Create an SG1 file from an SG0 file.
 */

#include <stdio.h>
#include <stdlib.h>

#ifndef NDEBUG
#   include <mcheck.h>
#endif

#include "width.ma.h"
#include "width.ua.h"
#include "width.va.h"
#include "width.wa.h"
#include "width.ta.h"

#include "graph_width.u.a.h"
#include "graph_width.v.a.h"
#include "graph_width.w.a.h"
#include "graph_width.t.a.h"

#include "sgraph0_io.a.h"
#include "graph.a.h"
#include "sgraph1_write.a.h"
#include "graph_read_sgraph0.a.h"

/*
 * INVOCATION
 *
 *	$0 INPUT-FILENAME OUTPUT-FILENAME LOGFILE
 * 
 * The input file must be in SG0 format; the output file is in SG1 format. 
 */
int main(int argc, char **argv)
{
#ifndef NDEBUG
	if (mcheck(NULL))  exit(1); 
#endif

	if (argc != 4) {
		fprintf(stderr, "*** Invalid number of arguments\n");
		exit(1);
	}

	const char *filename_in= argv[1];
	const char *filename_out= argv[2];

	struct sgraph0_reader_a r;
	
	if (0 > sgraph0_open_read_a(filename_in, &r, COLS_ALL)) {
		exit(1); 
	}

	if (0 > sgraph0_advise_a(&r, MADV_SEQUENTIAL)) {
		perror(filename_in);
		goto error_close;
	}

	struct graph_a g;

	graph_read_sgraph0_a(&g, &r); 

	sgraph0_close_a(&r);

	graph_sort_a(&g); 

	if (0 > sgraph1_write_a(&g, filename_out)) {
		exit(1); 
	}

	exit(0);

 error_close:
	sgraph0_close_a(&r); 
	exit(1); 
}
