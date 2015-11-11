%
% Compute the steps
%
% PARAMETERS 
%	$NETWORK
%
% INPUT 
%	dat/info.$NETWORK
%
% OUTPUT 
%	dat/stepsi.$NETWORK
%		The list of step values as text, with one number per line
%

count = 100; 

network = getenv('NETWORK'); 

info = read_info(network); 

stepsi_data = floor((1:count) * info.lines / count); 

filename = sprintf('dat/stepsi.%s', network);

FILE = fopen(filename, 'w'); 

if FILE < 0, error; end; 

fprintf(FILE, '%u\n', stepsi_data); 

if fclose(FILE) < 0, error; end; 



