
all: dijkstra_n_timesA dijkstra_n_timesB ifubA ifubB sampling_algorithmA sampling_algorithmB hyperanfA hyperanfB 

CFLAGS_COMMON := -std=c99 -pedantic -Werror -D_GNU_SOURCE
CFLAGS := $(CFLAGS_COMMON) -g  -lmcheck 
# CFLAGS := $(CFLAGS_COMMON) -O3 -DNDEBUG

dijkstra_n_timesA: dijkstra_n_timesA.o graphA.o dijkstraA.o distance_distributionA.o binary_heapA.o
	gcc $(CFLAGS) -o dijkstra_n_timesA dijkstra_n_timesA.o graphA.o dijkstraA.o distance_distributionA.o binary_heapA.o

dijkstra_n_timesB: dijkstra_n_timesB.o graphB.o dijkstraB.o distance_distributionB.o binary_heapB.o
	gcc $(CFLAGS) -o dijkstra_n_timesB dijkstra_n_timesB.o graphB.o dijkstraB.o distance_distributionB.o binary_heapB.o

dijkstra_n_timesA.o: dijkstra_n_times.c
	gcc $(CFLAGS) -c dijkstra_n_times.c -o $@  -D VARIANT_A 

dijkstra_n_timesB.o: dijkstra_n_times.c
	gcc $(CFLAGS) -c dijkstra_n_times.c -o $@  

# llcA: llcA.o graphA.o dijkstraA.o binary_heapA.o
# 	gcc $(CFLAGS) -o llcA llcA.o graphA.o dijkstraA.o binary_heapA.o

# llcB: llcB.o graphB.o dijkstraB.o binary_heapB.o
# 	gcc $(CFLAGS) -o llcB llcB.o graphB.o dijkstraB.o binary_heapB.o                                       

# llcA.o: llc.c
# 	gcc $(CFLAGS) -c llc.c -o $@ -D VARIANT_A 

# llcB.o: llc.c
# 	gcc $(CFLAGS) -c llc.c -o $@ 

ifubA: ifubA.o graphA.o dijkstraA.o distance_distributionA.o binary_heapA.o ifub_operationsA.o
	gcc $(CFLAGS) -o ifubA ifubA.o graphA.o dijkstraA.o distance_distributionA.o binary_heapA.o ifub_operationsA.o

ifubB: ifubB.o graphB.o dijkstraB.o distance_distributionB.o binary_heapB.o ifub_operationsB.o
	gcc $(CFLAGS) -o ifubB ifubB.o graphB.o dijkstraB.o distance_distributionB.o binary_heapB.o ifub_operationsB.o

ifubA.o: ifub.c
	gcc $(CFLAGS) -c ifub.c -o $@ -D VARIANT_A 

ifubB.o: ifub.c
	gcc $(CFLAGS) -c ifub.c -o $@

ifub_operationsA.o: ifub_operations.c
	gcc $(CFLAGS) -c ifub_operations.c -o $@ -D VARIANT_A 

ifub_operationsB.o: ifub_operations.c
	gcc $(CFLAGS) -c ifub_operations.c -o $@

sampling_algorithmA: sampling_algorithmA.o graphA.o dijkstraA.o distance_distributionA.o binary_heapA.o
	gcc $(CFLAGS) -o sampling_algorithmA sampling_algorithmA.o graphA.o dijkstraA.o distance_distributionA.o binary_heapA.o

sampling_algorithmB: sampling_algorithmB.o graphB.o dijkstraB.o distance_distributionB.o binary_heapB.o
	gcc $(CFLAGS) -o sampling_algorithmB sampling_algorithmB.o graphB.o dijkstraB.o distance_distributionB.o binary_heapB.o

sampling_algorithmA.o: sampling_algorithm.c
	gcc $(CFLAGS) -c sampling_algorithm.c -o $@ -D VARIANT_A 

sampling_algorithmB.o: sampling_algorithm.c
	gcc $(CFLAGS) -c sampling_algorithm.c -o $@

graphA.o: graph.c graph.h
	gcc $(CFLAGS) -c graph.c -o $@ -D VARIANT_A 

graphB.o: graph.c graph.h
	gcc $(CFLAGS) -c graph.c -o $@

dijkstraA.o: dijkstra.c
	gcc $(CFLAGS) -c dijkstra.c -o $@ -D VARIANT_A 

dijkstraB.o: dijkstra.c
	gcc $(CFLAGS) -c dijkstra.c -o $@

hyperanfA: hyperanfA.o graphA.o dijkstraA.o distance_distributionA.o binary_heapA.o hllA.o
	gcc $(CFLAGS) -o hyperanfA hyperanfA.o graphA.o dijkstraA.o distance_distributionA.o binary_heapA.o hllA.o -lm

hyperanfB: hyperanfB.o graphB.o dijkstraB.o distance_distributionB.o binary_heapB.o hllB.o
	gcc $(CFLAGS) -o hyperanfB hyperanfB.o graphB.o dijkstraB.o distance_distributionB.o binary_heapB.o hllB.o -lm

hyperanfA.o: hyperanf.c
	gcc $(CFLAGS) -c hyperanf.c -o $@ -D VARIANT_A 

hyperanfB.o: hyperanf.c
	gcc $(CFLAGS) -c hyperanf.c -o $@

hllA.o: hll.c hll.h murmur3.h
	gcc $(CFLAGS) -c hll.c -o $@ -D VARIANT_A 

hllB.o: hll.c hll.h murmur3.h
	gcc $(CFLAGS) -c hll.c -o $@

distance_distributionA.o: distance_distribution.c distance_distribution.h
	gcc $(CFLAGS) -c distance_distribution.c -o $@ -D VARIANT_A 

distance_distributionB.o: distance_distribution.c distance_distribution.h
	gcc $(CFLAGS) -c distance_distribution.c -o $@

binary_heapA.o: binary_heap.c binary_heap.h
	gcc $(CFLAGS) -c binary_heap.c -o $@ -D VARIANT_A 

binary_heapB.o: binary_heap.c binary_heap.h
	gcc $(CFLAGS) -c binary_heap.c -o $@

clean:
	rm -f  dijkstra_n_timesB ifubB sampling_algorithmB hyperanfB dijkstra_n_timesA ifubA sampling_algorithmA hyperanfA *.o \

