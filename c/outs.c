
/*
 * Create the timestamps-sorted out file.  The dataset must have timestamps. 
 *
 * PARAMETERS
 *	$1 	The network 
 *
 * INPUT
 *	uni/out.$NETWORK
 *
 * OUTPUT
 *	dat/outs.$NETWORK
 *		The same in out.* format, but sorted by increasing timestamp.  All field separated by a single tab. 
 */

#include <assert.h>
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <fcntl.h>
#include <ctype.h>

#include "asxprintf.h"

struct Entry
{
	unsigned from;
	unsigned to;
	float weight;
	int timestamp;
}; 

int compar(const void *o1, const void *o2)
{
	const struct Entry *const e1 = (const struct Entry *)o1;
	const struct Entry *const e2 = (const struct Entry *)o2;

	if (e1->timestamp > e2->timestamp)  return +1;
	if (e1->timestamp < e2->timestamp)  return -1;
	return 0; 
}

int main(int argc, char **argv)
{
	assert(argc == 2); 
	assert(sizeof(struct Entry) == 16); 

	const char *const network = argv[1]; 
	const char *filename_in= asxprintf("uni/out.%s", network); 
	const char *filename_out= asxprintf("dat/outs.%s", network); 

	FILE *file = fopen(filename_in, "r");
	
	if (file == NULL)  { 
		perror("fopen"); 
		exit(1); 
	}

	posix_fadvise(fileno(file), 0, 0, POSIX_FADV_SEQUENTIAL); 

	const int LEN = 100;
	char line[LEN];

	struct Entry *entries = NULL; /* malloced */
	size_t len= 0; 
    
	while (fgets(line, LEN, file)) {
		char *p = line;
		while (isspace(*p))  ++p;
		if (*p == '%') continue; 
		
		entries = realloc(entries, sizeof(struct Entry) * (len+1)); 

		int c = sscanf(p, "%u %u %f %d\n", 
			       &entries[len].from, &entries[len].to, 
			       &entries[len].weight, &entries[len].timestamp); 

		if (c >= 0 && c < 4) {
			perror("format");
			exit(1); 
		}
		if (c == 0) break;
		
		++len;
	}

	if (fclose(file)) {
		perror("fclose"); 
		exit(1); 
	}

	qsort(entries, len, sizeof(struct Entry), compar); 

	FILE *file_out = fopen(filename_out, "w");

	if (! file_out)  { 
		perror("fopen"); 
		exit(1); 
	}

	for (size_t i= 0;  i < len;  ++i) {
		fprintf(file_out, "%u\t%u\t%g\t%d\n", 
			entries[i].from, entries[i].to, 
			entries[i].weight, entries[i].timestamp); 
	}

	if (fclose(file_out)) { 
		perror("fclose"); 
		exit(1); 
	}

	exit(0);
}


