%
% Return whether a network has timestamps.
%
% ARGUMENTS
%	network		Name of network 
%
% INPUT FILES
%	uni/out.$network
%
% RETURN VALUE
%	1/0	True/false
%

function [ret] = has_timestamps(network)

filename= sprintf('uni/out.%s', network); 
  
FILE = fopen(filename, 'r');

if FILE < 0,
  error(sprintf('opening "%s"', filename)); 
end

line = fgetl(FILE); line = fgetl(FILE); line = fgetl(FILE); line = fgetl(FILE); line = fgetl(FILE); line = fgetl(FILE); 

[a count] = sscanf(line, '%s %s %s %s');

ret = count >= 4; 

if fclose(FILE) < 0,
  error(sprintf('closing "%s"', filename)); 
end
