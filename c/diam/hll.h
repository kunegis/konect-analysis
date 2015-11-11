UNUSED

#ifndef _llc_h
#define _llc_h

#include "stdint.h"
#include "limits.h"

/*
 * Implement the LogLog counter from
 *
 * [1] Marianne Durand and Philippe Flajolet, LogLog counting of large
 * cardinalities In Annual European Symposium on Algorithms,
 * pp. 605--617, 2003.   
 */

typedef struct {
    node_id b;
    node_id m;
    double alpha;
    node2_id* M;
} HyperLogLog;

HyperLogLog createHyperLogLog();
void add(const char* str, int size, HyperLogLog hll);
int num_zeros(int x, int b);
double value(HyperLogLog hll);

#endif /* ! _llc_h */ 

