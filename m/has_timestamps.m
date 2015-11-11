function [ret] = has_timestamps(network)

FILE = fopen(sprintf('uni/out.%s', network)); 

line = fgetl(FILE); line = fgetl(FILE); line = fgetl(FILE); line = fgetl(FILE); line = fgetl(FILE); line = fgetl(FILE); 

[a count] = sscanf(line, '%s %s %s %s');

ret = count >= 4; 
