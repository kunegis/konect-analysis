%
% Compute the steps
%
% PARAMETERS 
%	$network
%
% INPUT 
%	dat/info.$network
%
% OUTPUT 
%	dat/stepsi.$network
%		The list of step values as text, with one number per line
%

count = 100; 

network = getenv('network'); 

info = read_info(network); 

stepsi_data = floor((1:count) * info.lines / count); 

filename = sprintf('dat/stepsi.%s', network);

FILE = fopen(filename, 'w'); 

if FILE < 0, error; end; 

fprintf(FILE, '%u\n', stepsi_data); 

if fclose(FILE) < 0, error; end; 



