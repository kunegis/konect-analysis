UNUSED

#ifndef IFUB_OPERATIONS
#define IFUB_OPERATIONS

#include "graph.h"

/* 
 * The iFub algorithm.
 * 
 * PARAMETERS 
 *	k	The precision 
 *
 * RESULT 
 * 	The diameter 
 */
node_fid ifub(Graph_n g, node_id u, node_id l, node_id k);

node_id max_ecc(Graph_n g, node_id *b[], node_id b_size);

node_id fourSweep(Graph_n g, node_id *l);

#endif /* ! IFUB_OPERATIONS */
