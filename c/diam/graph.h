UNUSED

#ifndef GRAPH_H
#define GRAPH_H

/* 
 * Graph data structures and algorithms. 
 * 
 * CONFIGURATION 
 *     VARIANT_A:  Node IDs are 16 bit
 *     VARIANT_B:  Node IDs are 32 bit 
 */

#include <stdint.h>
#include <limits.h>
#include <inttypes.h>

#define BITMASK(b) (1 << ((b) % CHAR_BIT))
#define BITSLOT(b) ((b) / CHAR_BIT)
#define BITSET(a, b) ((a)[BITSLOT(b)] |= BITMASK(b))
#define BITCLEAR(a, b) ((a)[BITSLOT(b)] &= ~BITMASK(b))
#define BITTEST(a, b) ((a)[BITSLOT(b)] & BITMASK(b))
#define BITNSLOTS(nb) ((nb + CHAR_BIT - 1) / CHAR_BIT)

/* 
 * The following types are defined:
 * 
 * node_id:	Holds one node ID
 * node2_id:	Holds up to the square of a node ID
 * node_fid:	Fast variant of node_id (may take more memory)
 * node2_fid:	Fast variant of node2_id (may take more memory) 
 */

#ifdef VARIANT_A
 
typedef uint16_t node_id;
typedef uint32_t node2_id;
typedef uint_fast16_t node_fid; 
typedef uint_fast32_t node2_fid; 

#define node_id_max UINT16_MAX
#define node2_id_max UINT32_MAX

#define FORMAT_NODEID "%" PRIu16
#define FORMAT_NODEID2 "%" PRIu32
#define FORMAT_NODEFID "%" PRIuFAST16
#define FORMAT_NODEFID2 "%" PRIuFAST32

#else /* VARIANT_B */

typedef uint32_t node_id;
typedef uint64_t node2_id;
typedef uint_fast32_t node_fid; 
typedef uint_fast64_t node2_fid; 

#define node_id_max UINT32_MAX
#define node2_id_max UINT64_MAX

#define FORMAT_NODEID "%" PRIu32
#define FORMAT_NODEID2 "%" PRIu64
#define FORMAT_NODEFID "%" PRIuFAST32
#define FORMAT_NODEFID2 "%" PRIuFAST64

#endif

/* 
 * An adjacency vector
 */
typedef struct {
    node_id *neighbors;
    node_id num_neighbors;
} Neighbors; 

/*
 * A graph that is stored such that the neighbors of a given node can be
 * extracted efficiently. 
 */ 
typedef struct {
    Neighbors *vertices;
    node_id num_nodes;
} Graph_n;

/* 
 * Create empty graph with N nodes.
 *
 * PARAMETERS
 * 	n	Number of nodes 
 */
Graph_n graph_n_new(node_fid n);

void insertEdgeIntoGraph(Graph_n graph, node_id origin, node_id destination);

void insertEdgeIntoGraph_sub(Graph_n g, node_id origin, node_id destination);

void insertVerticeIntoGraph(Graph_n *g);

/* 
 * Load a graph from a file.
 * 
 * PARAMETERS
 * 	filename	File to read from
 *	n		Number of nodes 
 */
Graph_n getGraphFromFile(const char *filename, node_fid n);

node_id nodeIdNoVisited(node_id* v[], node_id size);

/* node_id llcGraph(char file_name[]); */

node_id countElement(node_id* v[], node_id size);

void deleteGraph(Graph_n g);

node_id existEdge(Graph_n g, node_id origin, node_id destination);

void deleteVerticeFromGraph(Graph_n *g, node_id v);

void deleteEdgeFromGraph(Graph_n *g, node_id origin, node_id destination);

void deleteEdgeFromGraph_sub(Graph_n *g, node_id origin, node_id destination);

node_id max(node_id x, node_id y);

#endif /* ! GRAPH_H */
