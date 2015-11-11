UNUSED

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "ifub_operations.h"

#include "binary_heap.h"
#include "dijkstra.h"

node_fid ifub(Graph_n g, node_id u, node_id l, node_id k)
{
	int lb, ub;
	node_id i,j,b_size=0, x;
    
	node_id *d;
	d = (node_id*)malloc(sizeof(node_id) * g.num_nodes);
    
	dijkstra(g, u, &d);
	i = d[0];
    
	for(j=1;j<g.num_nodes;j++){
		if(i<d[j]){
			i=d[j];
		}
	}

	lb=max(i,l);
	ub=2*i;

	while(ub - lb > k){
		node_id *b;
		b_size=0;
		b=(node_id*)malloc(b_size*sizeof(node_id));
		for(j=0;j<g.num_nodes;j++){
			if(i==d[j]){
				b_size++;
				b=(node_id*)realloc(b,b_size*(sizeof(node_id)));
				b[b_size-1]=j;
			}
		}
		x = max_ecc(g, &b, b_size);
		free(b);
		b=NULL;
		if(max(lb, x ) > 2*(i-1)){
			free(d);
			d=NULL;
			return max(lb, x );
		}
		else{
			lb=max(lb,  x );
			ub=2*(i-1);
		}
		i=i-1;
	}
	free(d);
	d = NULL;
	return lb;
}

node_id max_ecc(Graph_n g, node_id *b[], node_id b_size) 
{
	node_id i,j,sol=0,k;
    for(k=0;k<b_size;k++){
        node_id *e;
        e=(node_id*)malloc(sizeof(node_id) * g.num_nodes);
        dijkstra(g,(*b)[k],&e);
        i=e[0];
        for(j=1;j<g.num_nodes;j++){
            if(i<e[j]){
                i=e[j];
            }
        }
        if(i>sol){
            sol=i;
        }
        free(e);
        e=NULL;
    }
    return sol;
}

node_id middlePunt(Graph_n g, node_id nodeId, node_id fin, node_id *d[]){
    if(nodeId==fin){
        return 0;
    }
    else{
        node_id previo[g.num_nodes];
        node_id i,j;
        char s[BITNSLOTS(g.num_nodes)];
        memset(s, 0, BITNSLOTS(g.num_nodes));
        binary_heap b=createBinaryHeap();
        
        for(i=0;i<g.num_nodes;i++){
            previo[i]=-1;
        }
        
        for(i=0;i<g.num_nodes;i++){
            (*d)[i]=node_id_max;
        }
        
        insertInBinaryHeap(nodeId,0,&b);
        (*d)[nodeId]=0;
        while (!emptyBinaryHeap(b)) {
            i=getMinInBinaryHeap(b);
            removeMinInBinaryHeap(&b);
            if(!BITTEST(s,i)){
                BITSET(s,i);
                for(j=0;j<g.vertices[i].num_neighbors;j++){
                    if(!BITTEST(s,g.vertices[i].neighbors[j])){
                        
                        if((*d)[g.vertices[i].neighbors[j]]>((*d)[i])+1){
                            (*d)[g.vertices[i].neighbors[j]]=((*d)[i])+1;
                            previo[g.vertices[i].neighbors[j]]=i;
                            insertInBinaryHeap(g.vertices[i].neighbors[j],((*d)[i])+1,&b);
                        }
                    }
                }
            }
        }
        deleteBinaryHeap(&b);
        i=0;
        while( i<= (*d)[fin]/2 ){
            fin=previo[fin];
            i++;
        }
        return fin;
    }
}

node_id fourSweep(Graph_n g, node_id *l){
    node_id i,j,r1=0,a1,b1,r2,a2,b2,u,ecc_a1,ecc_a2;
    
    //r -> Node with the highest degree.
    for(j=1;j<g.num_nodes;j++){
        if(g.vertices[r1].num_neighbors < g.vertices[j].num_neighbors){
            r1=j;
        }
    }
    
    // a -> one of the farthest nodes from r.
    node_id *d;
    d=(node_id*)malloc(sizeof(node_id) * g.num_nodes);
    dijkstra(g,r1,&d);
    i=d[0];
    a1=0;
    for(j=1;j<g.num_nodes;j++){
        if(i<d[j]){
            i=d[j];
            a1=j;
            ecc_a1=i;
        }
    }
    free(d);
    d=NULL;
    
    // b -> one of the farthest nodes from a.
    d=(node_id*)malloc(sizeof(node_id) * g.num_nodes);
    dijkstra(g,a1,&d);
    i=d[0];
    b1=0;
    for(j=1;j<g.num_nodes;j++){
        if(i<d[j]){
            i=d[j];
            b1=j;
        }
    }
    free(d);
    d=NULL;
    
    d=(node_id*)malloc(sizeof(node_id) * g.num_nodes);
    r2=middlePunt(g,a1,b1,&d);
    free(d);
    d=NULL;
    
    d=(node_id*)malloc(sizeof(node_id) * g.num_nodes);
    dijkstra(g,r2,&d);
    i=d[0];
    a2=0;
    for(j=1;j<g.num_nodes;j++){
        if(i<d[j]){
            i=d[j];
            a2=j;
            ecc_a2=i;
        }
    }
    free(d);
    d=NULL;
    
    d=(node_id*)malloc(sizeof(node_id) * g.num_nodes);
    dijkstra(g,a2,&d);
    i=d[0];
    b2=0;
    for(j=1;j<g.num_nodes;j++){
        if(i<d[j]){
            i=d[j];
            b2=j;
        }
    }
    free(d);
    d=NULL;
    
    d=(node_id*)malloc(sizeof(node_id) * g.num_nodes);
    u=middlePunt(g,a2,b2,&d);
    free(d);
    d=NULL;
    
    *l=max(ecc_a1,ecc_a2);
    return u;
}
