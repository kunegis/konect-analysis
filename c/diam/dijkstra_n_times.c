
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <time.h>

#include "graph.h"
#include "distance_distribution.h"
#include "dijkstra.h"

/* 
 * Compute the distance distribution using Dijkstra's algorithm.  
 *
 * ARGUMENTS 
 *    $1	Input filename
 *    $2	Output filename
 *    $3	Size of network 
 */
int main(int argc, char **argv)
{
	assert(argc == 4);

	const char *text_n= argv[3];

	node_fid size;

	if (1 != sscanf(text_n, FORMAT_NODEFID, &size)) {
		perror(text_n);
		exit(1); 
	}
    

	char llc_file[50];
	clock_t initiation, end;
	node_id i, j;
    
	Graph_n g = getGraphFromFile(argv[1], size);
    
	distance_distribution c=createDistance_distribution();
    initiation=clock();
    for (node_id n = 0; n < g.num_nodes; n++) {
        node_id *d;
        d=(node_id*)malloc(sizeof(node_id) * g.num_nodes);
        dijkstra(g, n, &d);
        c=insertDistancesInDistance_distribution(d,g.num_nodes,c);
        free(d);
        d=NULL;
    }
    end=clock();

    printf("%.16f\n", ((float)(end-initiation))/(float)CLOCKS_PER_SEC);

    FILE *f;
    /* char output_file[50]; */
    /* sprintf(output_file,"output/hopdistr.dijkstra.%s",argv[1]); */
    node2_id count=c.distances[0];
    f = fopen(argv[2], "w+");
    if(f==NULL){
        perror("Error opening file");
    }
    
    for (i=1;i<c.num_distances;i++) {
        count=count+c.distances[i];
        fprintf(f, FORMAT_NODEID2 "\n",count);
    }
        
    exit(0);
}
