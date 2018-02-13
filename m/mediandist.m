%
% Determine the median distance in the network, from the hop
% distribution.
%
% In case the atcual median value would be a non-integer, because we are
% averaging between two values, the result is rounded up, to always
% result in an integer.  There must always be one pair of nodes for each
% possible distance between zero and the diameter, and thus the only
% case of averaging happens between two adjacent integers.  For large
% networks, this is exceedingly unlikely. 
%
% PARAMETERS
%	$network
%
% INPUT FILES
%	dat/hopdistr.$network 
%
% OUTPUT FILES
%	dat/statistic.mediandist.$network
%

network = getenv('network')

h = load(sprintf('dat/hopdistr.%s', network))

v = sum(h <= (h(end) / 2))

values = [ v ]

filename_OUT = sprintf('dat/statistic.mediandist.%s', network);
OUT = fopen(filename_OUT, 'w');
if OUT < 0,  error(filename_OUT); exit(1);  end;
fprintf(OUT, '%u\n', values);
if fclose(OUT) < 0,  error(filename_OUT); exit(1);  end;
