%
% Generate 'slice' from a temporal statistic.
%
% PARAMETERS
%	$statistic	Name of the statistic
%	$network	Name of the network
%	$type
%	$K		The slide ID, i.e., column number
%
% INPUT FILES
%	dat/statistic_time.$type.$statistic.$network
%		The temporal statistics:  one timepoint per line, each
% 		line contains multiple numbers, the $K'th number being
% 		the substatistic we are interested in
%
% OUTPUT FILES
%	dat/statistic_time.$type.${statistic}+${K}.$network
%		A file containing only a single column, taken from the
% 		input file
%

statistic = getenv('statistic')
network   = getenv('network')
type      = getenv('type')
k_text    = getenv('K')

k = str2num(k_text)

assert(k >= 2); 

data = load(sprintf('dat/statistic_time.%s.%s.%s', type, statistic, network));

size_data = size(data) 
assert(size_data(1) >= 10);
assert(size_data(2) >= k); 
	    
data_k = data(:,k);

save(sprintf('dat/statistic_time.%s.%s+%s.%s', type, statistic, k_text, network), ...
     'data_k', ...
     '-ascii');
