
/* Create an Sg1 file from an Sg0 file, transforming any network in a
 * simple SYM network.  
 */

/* The passes M/U/V/W/T are those of the original graph.  Additional
   parameters for the generated graph: 
   
   MX, UX, VX, WX, TX, 
 */

#include <stdio.h>
#include <stdlib.h>

#include "width.ma.h"
#include "width.ua.h"
#include "width.va.h"
#include "width.wa.h"
#include "width.ta.h"

#include "width.mb.h"
#include "width.ub.h"
#include "width.vb.h"
#include "width.wb.h"
#include "width.tb.h"

#include "graph_width.u.b.h"
#include "graph_width.v.b.h"

#include "sgraph0_io.a.h"
#include "graph.b.h"
#include "graph_simple.a.b.h"
#include "sgraph1_write.b.h"

/*
 * INVOCATION
 *
 *	$0 INPUT-FILE OUTPUT-FILE
 * 
 * The input file must be in sg0 format; the output file is in sg1 format. 
 */
int main(int argc, char **argv)
{
	if (argc != 3) {
		fprintf(stderr, "*** Invalid number of arguments\n");
		exit(1);
	}

	const char *const filename_in= argv[1];
	const char *const filename_out= argv[2]; 

	struct sgraph0_reader_a r;
	
	if (0 > sgraph0_open_read_a(filename_in, &r, COLS_ALL)) {
		exit(1); 
	}

	if (0 > sgraph0_advise_a(&r, MADV_SEQUENTIAL)) {
		perror(filename_in);
		goto error_close;
	}

	struct graph_b g;

	graph_read_sg0_simple_a_b(&g, &r);  

	sgraph0_close_a(&r);

	graph_sort_b(&g); 
	graph_unique_b(&g); 

	if (0 > sgraph1_write_b(&g, filename_out)) {
		exit(1); 
	}

	exit(0);

 error_close:
	sgraph0_close_a(&r); 
	exit(1); 
}
