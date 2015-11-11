#include <stdio.h>
#include <stdlib.h>
#include "distance_distribution.h"
#include "graph.h"

distance_distribution createDistance_distribution(){
    distance_distribution c;
    c.distances=NULL;
    c.num_distances=0;
    return c;
}

node_id getDiameter(node_id *d, node_id size){
    node_id i,diameter;
    diameter=d[0];
    for(i=1;i<size;i++){
        if(diameter<d[i]){
            diameter=d[i];
        }
    }
    return diameter;
}

distance_distribution insertDistancesInDistance_distribution(node_id d[], node_id size, distance_distribution c){
    node_id diameter=getDiameter(d,size);
    node_id i;
    if(c.num_distances == 0){
        c.num_distances=diameter+1;
        c.distances=(node2_id*)malloc(sizeof(node2_id)*c.num_distances);
        for(i=0;i<c.num_distances;i++){
            c.distances[i]=0;
        }
    }
    
    else{
        if(diameter+1>c.num_distances){
            node_id aux=c.num_distances;
            c.num_distances=diameter+1;
            c.distances=(node2_id*)realloc(c.distances, (diameter+1) * sizeof(node2_id));
            for(i=aux;i<c.num_distances;i++){
                c.distances[i]=0;
            }
        }
    }
    
    for(i=0;i<size;i++){
        c.distances[d[i]]=c.distances[d[i]]+1;
    }
    return c;
}

distance_distribution insertDistancesInDistance_distribution_for_sampling(node_id d[], node_id size, distance_distribution c, node_id *diameter){
    *diameter=getDiameter(d,size);
    node_id i;
    if(c.num_distances == 0){
        c.num_distances=(*diameter)+1;
        c.distances=(node2_id*)malloc(sizeof(node2_id)*c.num_distances);
        for(i=0;i<c.num_distances;i++){
            c.distances[i]=0;
        }
    }
    
    else{
        if((*diameter)+1>c.num_distances){
            node_id aux=c.num_distances;
            c.num_distances=(*diameter)+1;
            c.distances=(node2_id*)realloc(c.distances, ((*diameter)+1) * sizeof(node2_id));
            for(i=aux;i<c.num_distances;i++){
                c.distances[i]=0;
            }
        }
    }
    
    for(i=0;i<size;i++){
        c.distances[d[i]]=c.distances[d[i]]+1;
    }
    return c;
}

void deleteDistance_distribution(distance_distribution c){
    free(c.distances);
    c.distances=NULL;
}
