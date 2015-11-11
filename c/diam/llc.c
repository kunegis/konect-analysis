UNUSED

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>

#include "graph.h"

int main(int argc, char **argv) 
{
	char input_file[100];
	char route[100] = "input/out.";

	sprintf(input_file,"%s%s",route, argv[1]);

	node_id num_vertices=llcGraph(input_file);

	assert(num_vertices > 0);

	return 0; 
}
