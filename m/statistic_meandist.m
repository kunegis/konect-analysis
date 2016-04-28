%
% Computer average distance
%
% PARAMETERS 
%	$network
%
% INPUT 
%	dat/hopdistr2.$network
%
% OUTPUT 
%	dat/statistic.meandist.$network
%

network = getenv('network'); 

data = load(sprintf('dat/hopdistr2.%s', network));

x = konect_diammean(data);

save(sprintf('dat/statistic.meandist.%s', network), 'x', '-ascii');

