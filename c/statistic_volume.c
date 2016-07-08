/*
 * Determine the volume of a network using constant memory.  This
 * program scales to all networks in KONECT.  
 *
 * This is *not* the number of lines in the network, because this
 * measure takes into account multiple edges even if they are stored as
 * weights in POSITIVE networks.    
 *
 * PARAMETERS 
 *	$network 	Name of the network
 * 
 * INPUT
 *  	dat/info.$network
 *	uni/out.$network (only when the network is POSITIVE)
 * 
 * OUTPUT
 *	dat/statistic.volume.$network
 */

#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <stdint.h>
#include <inttypes.h>

#include "consts.h"
#include "asxprintf.h"

#define LEN 256

char line[LEN];

int main() {
	const char *network = getenv("network"); 

	char *const filename_info= asxprintf("dat/info.%s", network);
	
	FILE *info = fopen(filename_info, "r");
	if (!info) {
		perror(filename_info);
		exit(1); 
	}

	char *line = NULL;
	size_t len = 0;

	unsigned weights;
	unsigned lines;

	for (int i = 1; i <= 6; ++i) {
		if (0 > getline(&line, &len, info)) {
			perror(filename_info);
			exit(1); 
		}
		switch (i) {

		case 3:
			if (sscanf(line, "%u", &lines) != 1) {
				perror(line);
				exit(1); 
			}
			break;

		case 6:
			if (sscanf(line, "%u", &weights) != 1) {
				perror(line);
				exit(1); 
			}
			break;
		}

	}

	uintmax_t volume;

	if (weights == WEIGHTS_POSITIVE) {

		char *const filename_out= asxprintf("uni/out.%s", network);

		FILE *out = fopen(filename_out, "r");
		if (!out) {
			perror(filename_out);
			exit(1); 
		}
		posix_fadvise(fileno(out), 0, 0, POSIX_FADV_SEQUENTIAL); 

		volume= 0; 

		while (fgets(line, LEN, out)) {

			unsigned u, v;
			unsigned multiplicity;
			int number = sscanf(line, " %u %u %u", &u, &v, &multiplicity); 

			if (number == 3) {
				volume += multiplicity;
			}

			if (number == 2) {
				goto l_lines;
			}
		}
		if (fclose(out)) {
			perror(filename_out);
			exit(1); 
		}

	} else {
	l_lines:
		volume = lines; 
	}

	char *const filename_statistic= asxprintf("dat/statistic.volume.%s", network); 

	FILE *statistic = fopen(filename_statistic, "w");
	
	if (!statistic) {
		perror(filename_statistic);
		exit(1); 
	}

	fprintf(statistic, "%" PRIuMAX "\n", volume);

	if (fclose(statistic)) {
		perror(filename_statistic);
		exit(1);
	}

	exit(0); 
}
