UNUSED

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <fcntl.h> /* for posix_fadvise() */
#include <assert.h>

#include "graph.h"
#include "distance_distribution.h"

Graph_n graph_n_new(node_fid n)
{
    Graph_n g;
    g.num_nodes = n;
    g.vertices = (Neighbors *) malloc(n * sizeof(Neighbors));

    for (node_fid i = 0; i < n; ++i)
	    g.vertices[i].num_neighbors=0;
    
    return g;
}

void insertVerticeIntoGraph(Graph_n *g){
    (*g).vertices=(Neighbors*)realloc((*g).vertices,(((*g).num_nodes)+1) * sizeof(Neighbors));
    (*g).vertices[(*g).num_nodes].num_neighbors=0;
    (*g).num_nodes=(*g).num_nodes+1;
}

void insertEdgeIntoGraph(Graph_n g, node_id origin, node_id destination)
{
	if (origin < g.num_nodes && destination < g.num_nodes) {
		insertEdgeIntoGraph_sub(g,origin,destination);
		insertEdgeIntoGraph_sub(g,destination,origin);
	} else {
		fprintf(stderr, "*** Error: Edge(" FORMAT_NODEID " " FORMAT_NODEID ") not valid\n",origin+1,destination+1);
		exit(1); 
	}
}

void insertEdgeIntoGraph_sub(Graph_n g, node_id origin, node_id destination){
    if(g.vertices[origin].num_neighbors==0){
        g.vertices[origin].neighbors=(node_id*)malloc(sizeof(node_id));
        g.vertices[origin].num_neighbors=1;
        g.vertices[origin].neighbors[0]=destination;
    }
    else{
      g.vertices[origin].neighbors=(node_id*)realloc
	(g.vertices[origin].neighbors,
	 ((g.vertices[origin].num_neighbors) +1) * sizeof(node_id));
      g.vertices[origin].num_neighbors++;
      g.vertices[origin].neighbors[g.vertices[origin].num_neighbors-1]=destination;
    }
}

void deleteVerticeFromGraph(Graph_n *g, node_id v) {
	node_id i,j;
	for(i=0;i<(*g).num_nodes;i++){
		for(j=0;j<(*g).vertices[i].num_neighbors;j++){
            if((*g).vertices[i].neighbors[j] == v){
                deleteEdgeFromGraph_sub(g,i,j);
            }
            else if((*g).vertices[i].neighbors[j] > v){
                (*g).vertices[i].neighbors[j]--;
            }
        }
    }
    for(i=v;i<(*g).num_nodes;i++){
        (*g).vertices[i]=(*g).vertices[i+1];
    }
    (*g).vertices=(Neighbors*)realloc((*g).vertices,(((*g).num_nodes)+1) * sizeof(Neighbors));
    (*g).num_nodes--;
}

void deleteEdgeFromGraph(Graph_n *g, node_id origin, node_id destination){
    deleteEdgeFromGraph_sub(g,origin,destination);
    deleteEdgeFromGraph_sub(g,destination,origin);
}

void deleteEdgeFromGraph_sub(Graph_n *g, node_id origin, node_id destination){
    node_id i,j;
    
    for(j=destination;j<(*g).vertices[origin].num_neighbors-1;j++){
        (*g).vertices[origin].neighbors[j]=(*g).vertices[origin].neighbors[j+1];
    }
    
    (*g).vertices[origin].neighbors=(node_id*)realloc((*g).vertices[origin].neighbors,(((*g).vertices[origin].num_neighbors)-1) * sizeof(node_id));
    (*g).vertices[origin].num_neighbors--;
}


Graph_n getGraphFromFile(const char *filename, node_fid n)
{
	FILE *file = fopen(filename,"r");
	if(! file) {
		perror(filename);
		exit(1); 
	}

	posix_fadvise(fileno(file), 0, 0, POSIX_FADV_SEQUENTIAL); 
           
	Graph_n g = graph_n_new(n);
	const int LEN = 256; 
	char string[LEN];
	node_fid u, v;
	while (fgets(string, LEN, file) != NULL) {
		/* If sscanf() does not return 2, this is not a content line. 
		 */
		if (2 == sscanf(string, FORMAT_NODEFID " " FORMAT_NODEFID, &u, &v)) {
			assert(u >= 1 && u <= n);
			assert(v >= 1 && v <= n); 
			insertEdgeIntoGraph(g, u-1, v-1);
		}
	}

	if (fclose(file)) {
		perror(filename);
		exit(1); 
	}
	
	return g;
}

void deleteGraph(Graph_n g){
    node_id i;
    for(i=0;i<g.num_nodes;i++){
        free(g.vertices[i].neighbors);
        g.vertices[i].neighbors=NULL;
    }
    free(g.vertices);
    g.vertices=NULL;
}

node_id nodeIdNoVisited(node_id* v[], node_id size){
    node_id i=0;
    for(i=0;i<size;i++){
        if((*v)[i]!=1){
            return i;
        }
    }
    return size;
}

node_id countElement(node_id* v[], node_id size){
    node_id i=0, count=0;
    
    for(i=0;i<size;i++){
        if((*v)[i]!=node_id_max){
            count++;
        }
    }
    return count;
}

node_id max(node_id x, node_id y){
    if(x>y)return x;
    else return y;
}

node_id existEdge(Graph_n g, node_id origin, node_id destination){
  node_id i;
  for(i=0;i<g.vertices[origin].num_neighbors;i++){
    if(g.vertices[origin].neighbors[i]==destination){
      return 1;
    }
  }
  return 0;
}
