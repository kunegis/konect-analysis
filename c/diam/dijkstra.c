
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "dijkstra.h"
#include "binary_heap.h"

void dijkstra(Graph_n g, node_id nodeId, node_id *d[])
{
    node_id i,j;
    char s[BITNSLOTS(g.num_nodes)];
    memset(s, 0, BITNSLOTS(g.num_nodes));
    binary_heap b=createBinaryHeap();
    
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
                        insertInBinaryHeap(g.vertices[i].neighbors[j],((*d)[i])+1,&b);
                    }
                }
            }
            
        }
    }
    deleteBinaryHeap(&b);
}
