UNUSED

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <strings.h>
#include <time.h>
#include <math.h>
#include <assert.h>

#include "graph.h"
#include "hll.h"

/*
 * Estimate the distance distribution of a network using the HyperANF
 * algorithm.   
 * 
 * PARAMETERS 
 *     $1    input filename; network must be connected 
 *     $2    (integer) Size of network; number of nodes
 * 
 * OUTPUT
 * 	stdout:  The distance distribution 
 */
int main (int argc, char **argv)
{
	assert(argc == 3);

	const char *filename_input = argv[1]; 
	const char *text_n = argv[2];

	node_fid n;

	if (1 != sscanf(text_n, FORMAT_NODEFID, &n)) {
		perror(text_n);
		exit(1); 
	}

	Graph_n g = getGraphFromFile(filename_input, n);
    
	HyperLogLog c[g.num_nodes];

	for (node_fid i = 0; i < g.num_nodes; i++)
		c[i] = createHyperLogLog();
    
	HyperLogLog m[g.num_nodes];
	for (node_fid i = 0; i < g.num_nodes; i++)
		m[i] = createHyperLogLog();
    
	node_id j,k,t,aux;
	node2_id x;
	char val[32];
	for (node_fid i = 0; i < g.num_nodes ; i++) {
		sprintf(val, FORMAT_NODEID ,i);
		add(val,strlen(val),c[i]);
	}
    
	t = 0;
	aux = 1;

	while (aux == 1) {
		t++;
		aux=0;
		for(node_fid i=0; i<g.num_nodes; i++){
			for(j=0;j<c[i].m;j++){
				m[i].M[j]=c[i].M[j];
			}
			for(k=0;k<g.vertices[i].num_neighbors;k++){
				for(j=0;j<m[i].m;j++){
					m[i].M[j]=max(m[i].M[j],c[g.vertices[i].neighbors[k]].M[j]);
				}
			}
		}
		for (node_fid i=0; i<g.num_nodes; i++){
			for(j=0;j<c[i].m;j++){
				if(c[i].M[j]!=m[i].M[j]){
					c[i].M[j]=m[i].M[j];
					aux=1;
				}
			}
		}
		if(aux==0) break;
		x=0;

		for (node_fid i=0; i<g.num_nodes; i++)
			x=x+value(m[i]);

		printf(FORMAT_NODEID2 "\n",x);
	}
    
	exit(0);
}
