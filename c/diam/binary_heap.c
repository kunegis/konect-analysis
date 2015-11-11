
UNUSED

#include <stdio.h>
#include <stdlib.h>

#include "binary_heap.h"

binary_heap createBinaryHeap()
{
	binary_heap b;
	b.last=node_id_max;
	return b;
}

node_id emptyBinaryHeap(binary_heap b)
{
	return b.last==node_id_max;
}

node_id getMinInBinaryHeap(binary_heap b)
{
	return b.elements[0].n;
}

void deleteBinaryHeap(binary_heap *b)
{
	free((*b).elements);
	(*b).elements=NULL;
}

void insertInBinaryHeap(node_id n, node_id d,binary_heap *b)
{
  node_id p;
  if(emptyBinaryHeap(*b)){
    (*b).last++;
    (*b).elements=(element*)calloc(((*b).last)+1,sizeof(element));
  }
  else{
    (*b).last++;
    (*b).elements=(element*)realloc((*b).elements,(((*b).last)+1)*sizeof(element));
  }
    
  p=(*b).last;
  while((p>0)&&((*b).elements[(p-1)/2].d>d)){
    (*b).elements[p].d=(*b).elements[(p-1)/2].d;
    (*b).elements[p].n=(*b).elements[(p-1)/2].n;
    p=(p-1)/2;
  }
  (*b).elements[p].d=d;
  (*b).elements[p].n=n;
}

void removeMinInBinaryHeap(binary_heap *b)
{
  node_id p, pmin, end;
  element e;
    
  if(emptyBinaryHeap(*b)){
    printf("\nBinary Heap ist empty\n\n");
  }
  else if((*b).last==0){
    (*b).last=node_id_max;
    free((*b).elements);
    (*b).elements=NULL;
  }
  else{
    e=(*b).elements[(*b).last];
    (*b).last--;
    (*b).elements=(element*)realloc((*b).elements,(((*b).last)+1)*sizeof(element));
    if(!emptyBinaryHeap(*b)){
      p=0;
      if((*b).last>0){
	end=0;
	while(p <= ((*b).last-1)/2 && end==0){
                
	  if(((2*p)+1)==(*b).last){
	    pmin=(2*p)+1;
	  }
	  else if((*b).elements[(2*p)+1].d < (*b).elements[(2*p)+2].d){
	    pmin=(2*p)+1;
	  }
	  else{
	    pmin=(2*p)+2;
	  }
                
	  if((*b).elements[pmin].d < e.d){
	    (*b).elements[p]=(*b).elements[pmin];
	    p=pmin;
	  }
	  else
	    end=1;
	}
      }
      (*b).elements[p]=e;
    }
  }
}
