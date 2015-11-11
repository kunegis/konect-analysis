#ifndef _distance_distribution_h
#define _distance_distribution_h

#include "graph.h"

typedef struct {
    node_id num_distances;
    node2_id* distances;
} distance_distribution;

distance_distribution createDistance_distribution();

distance_distribution insertDistancesInDistance_distribution
(node_id d[], node_id size, distance_distribution c);

distance_distribution insertDistancesInDistance_distribution_for_sampling
(node_id d[], node_id size, distance_distribution c, node_id *diameter);

node_id getDiameter(node_id *d, node_id size);

void deleteDistance_distribution(distance_distribution c);

#endif /* ! _distance_distribution_h */

