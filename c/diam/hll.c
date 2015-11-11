
UNUSED

#include <math.h>
#include <stdlib.h>
#include <stdio.h>
#include "limits.h"
#include <string.h>
#include <strings.h>

#include "graph.h"
#include "hll.h"
#include "murmur3.h"

HyperLogLog createHyperLogLog() 
{
    HyperLogLog hll;
    hll.b=6;
    hll.m=1<<hll.b;
    hll.M=(node2_id*)malloc(hll.m*(sizeof(node2_id)));
    node_id i;
    for(i=0;i<hll.m;i++){
        hll.M[i]=0;
    }
    switch(hll.m){
        case 16:
            hll.alpha = 0.673;
            break;
        case 32:
            hll.alpha = 0.697;
            break;
        case 64:
            hll.alpha = 0.709;
            break;
        default:
            hll.alpha = 0.7213/(1.0 + 1.079/hll.m);
    }
    hll.alpha = hll.alpha * hll.m * hll.m;
    return hll;
}


/* 
 * Add an item to a HyperLogLog counter.
 * 
 * str:  string to add to the counter
 * size:  length of the string
 */
void add(const char* str, int size, HyperLogLog hll)
{
    uint32_t hash;
    MurmurHash3_x86_32(str,size,313, (void*)&hash);
    int index = hash >> ( 32 - hll.b );
    int set = num_zeros((hash << hll.b), 32 - hll.b);
    if( set > hll.M[index] ){
        hll.M[index] = set;
    }
}

int num_zeros(int a, int b) 
{
    int cont=1;
    while (cont<=b && !(a & 0x80000000)) {
        cont++;
        a <<= 1;
    }
    return cont;
}

double value(HyperLogLog hll)
{
    node_id i,set=0;
    double value,num = 0.0;
    for (i=0;i<hll.m;i++) {
        num+=1.0/pow(2.0,hll.M[i]);
    }
    value = hll.alpha/num;
    if (value<=2.5*hll.m) {
        node_id cont = 0;
        for (i = 0; i < hll.m; i++) {
            if (hll.M[i] == 0) {
                cont++;
            }
        }
        if (cont != 0) {
            value = hll.m * log((double)hll.m/cont);
        }
    }
    else if (value > (1.0/30.0)*4294967296.0) {
        value = -4294967296.0*log(1.0-(value/4294967296.0));
    }
    return value;
}
