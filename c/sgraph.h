#ifndef SGRAPH_H
#define SGRAPH_H

/*
 * Compact and simple data structure for representing graphs. 
 * 
 * This format is intended to be:
 *   - Compact, for loading even the largest KONECT networks into
 *     memory
 *   - Fast, i.e., can be accessed without complex algorithms or
 *     endianness conversion
 *
 * As a trade-off, this format is architecture-dependent, i.e., not
 * intended as an exchange format (although the header does declare
 * endianness and bit width). 
 */

/*
 * Not supported:
 *   - Complex compression schemes, e.g., special compression for
 *     degree-one nodes
 */ 

#include <stdint.h>

#define SGRAPH_MAGIC32 ((float)1.23456789)
#define SGRAPH_MAGIC64 0xCD1243FE45CAAB76ULL

#define SGRAPH_VERSION_ALL 0
/* Dataset consists of pairs in unspecified order.  Only whole
 * iterations are possible.  Weights and timestamps are optionally
 * appended.  This can usually be generated in O(1) memory, while NODE
 * takes O(n) memory to generate.  No edge is saved twice in SYM
 * networks.  
 * 
 * Content:
 *    - header
 *    - [m*U] from node ID
 *    - [m*V] to node ID
 *    - [m*W] (optional) edge weight
 *    - [m*T] (optional) timestamp
 */ 

#define SGRAPH_VERSION_EDGE 1
/* Random access is possible.  Size of file is O(m+n).  Content is the
 * same as NODE, but starts with N entries containing the adresses of
 * the start of each node's adjacency vector (measured from the file
 * beginning, in node_id units).  In undirected networks (SYM), each
 * edge is stored twice, and thus the V array is optional for SYM
 * networks.  Note that the order of to and from array is switched in
 * comparison to version 0:  this is because in this version it is
 * possible to load only the TO array, which makes it possible to
 * iterate only over forward edges, which is more useful than only
 * iterating over backward edges. 
 *
 * Content:
 * - header
 * - [1*M] (only SYM) number of loops (l)
 * - [n1*M] (adj to) address of beginning of adjacency vector for each node, inside
 *          each of the following vectors.  
 * - [n2*M] (adj from) Same for from
 * - [m*V] to node IDs (length is 2 * m - l for SYM) 
 * - [m*U] from node IDs (only for directed and bipartite networks) 
 * - [m*W] edge weights [to] (optional)
 * - [m*W] edge weights [from] (optional)
 * - [m*T] timestamps [to] (optional)
 * - [m*T] timestamps [from] (optional)
 *
 * For SYM networks, the "from" arrays are not present, and the "to"
 * arrays (expect adj) have the length m * 2 - l, where l is the number
 * of loops.  (This is *not* true for directed networks, in which each
 * loop is stored twice, and loops are not special.)
 */

/* When loading / creating / writing an Sgraph file, the number of columns
   can be speficied.  This is the total number of columns.  The columns
   are U/V/W/T. 
 */ 
#define COLS_ALL 4

struct header
{
	uint64_t magic64;    

	uint8_t  format;
	uint8_t  weights;
	uint8_t  version;
	int8_t   width_m;
	int8_t   width_u;
	int8_t   width_v;
	int8_t   width_w;  
	int8_t   width_t;  

	float    magic32;
	uint32_t flags; 
	
	uint64_t m;

	uint64_t n1;       

	uint64_t n2; 
	
} __attribute__((__packed__));

#endif /* ! SGRAPH_H */
