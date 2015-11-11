#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <time.h>

#include "distance_distribution.h"
#include "dijkstra.h"

/*
 * Compute the distance distribution by sampling and Dijkstra's
 * algorithm.   
 *
 * PARAMETERS 
 * $1 :  input filename
 * $2 :  output filename
 * $3 :  sampling rate  (in percent, an integer) 
 * $4 :	 n, size of network, number of nodes
 */
int main (int argc, char **argv)
{
	assert(argc == 5);

	const char *filename_input = argv[1];
	const char *filename_output = argv[2];
	const char *text_rate = argv[3];
	const char *text_n = argv[4]; 

	node_fid n;

	if (1 != sscanf(text_n, FORMAT_NODEFID, &n)) {
		perror(text_n);
		exit(1); 
	}

	int rate = atoi(text_rate);

	assert(rate>0 && rate<=100);

	int m2 = rate;
	/* char llc_file[50]; */
	clock_t initiation, end;
	node_id i, v, j;
	/* sprintf(llc_file,"output/llc.%s",argv[1]); */
    
	Graph_n g = getGraphFromFile(filename_input, n);

	/* Sample size */ 
	int n_sample = (rate * g.num_nodes) / 100;
	if(n_sample == 0) { n_sample = 1; }

	node_id aux, min_e=node_id_max,radio=node_id_max;
	node_id random[g.num_nodes];
	distance_distribution c=createDistance_distribution();
	srand(time(NULL));
	initiation=clock();

	if (n_sample * 100 / g.num_nodes > 20) {
		/* Fisher--Yates shuffle */ 
		for(i=0;i<g.num_nodes;i++){
			random[i]=i;
		}
		n--;
		for(i=0;i<n;n--){
			j = rand() % (n+1);
			aux=random[j];
			random[j]=random[n];
			random[n]=aux;
		}
		for (i = 0; i < n_sample; i++) {
			node_id *d;
			d=(node_id*)malloc(sizeof(node_id) * g.num_nodes);
			dijkstra(g,random[i],&d);
			c=insertDistancesInDistance_distribution_for_sampling(d,g.num_nodes,c,&min_e);
			if(min_e<radio){
				radio=min_e;
			}
			free(d);
			d=NULL;
		}
	}
	else{
		char bitarray[BITNSLOTS(g.num_nodes)];
		memset(bitarray, 0, BITNSLOTS(g.num_nodes));
		for (i = 0; i < n_sample; ) {
			v= rand() % (g.num_nodes);
			if(!BITTEST(bitarray,v)){
				BITSET(bitarray,v);
				i++;
				node_id *d;
				d=(node_id*)malloc(sizeof(node_id) * g.num_nodes);
				dijkstra(g,v,&d);
				c=insertDistancesInDistance_distribution_for_sampling(d,g.num_nodes,c,&min_e);
				if(min_e<radio){
					radio=min_e;
				}
				free(d);
				d=NULL;
			}
		}
	}
	end=clock();

	int time_seconds = ((float)(end-initiation))/(float)CLOCKS_PER_SEC; /* unused */ 
	/* printf("%.16f\n",((float)(end-initiation))/(float)CLOCKS_PER_SEC); */
	//*********************************************************
    
	/*
	 * Output 
	 */
	FILE *f;
	/* char output_file[50]; */
	/* sprintf(output_file,"output/hopdistr.sampling.%d.%s",m2,argv[1]); */
	node2_id count=c.distances[0];
	f = fopen(filename_output, "w");
	if (!f) {
		perror(filename_output);
		exit(1); 
	}
	for(i=1;i<c.num_distances;i++){
		count=count+c.distances[i];
		fprintf(f,FORMAT_NODEID2 "\n",count);
	}
	if (fclose(f)) {
		perror(filename_output);
		exit(1); 
	}

	/* deleteGraph(g); */
	/* deleteDistance_distribution(c); */

	exit(0);
}
