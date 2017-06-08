%
% Computer the average distance in a network. 
%
% PARAMETERS 
%	$network
%
% INPUT FILES 
%	dat/hopdistr.$network
%
% OUTPUT FILES 
%	dat/statistic.meandist.$network
%

network = getenv('network'); 

data = load(sprintf('dat/hopdistr.%s', network));

x = konect_diammean(data);

save(sprintf('dat/statistic.meandist.%s', network), 'x', '-ascii');
