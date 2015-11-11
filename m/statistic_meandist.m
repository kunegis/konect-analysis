%
% Computer average distance
%
% PARAMETERS 
%	$NETWORK
%
% INPUT 
%	dat/hopdistr2.$NETWORK
%
% OUTPUT 
%	dat/statistic.meandist.$NETWORK
%

network = getenv('NETWORK'); 

data = load(sprintf('dat/hopdistr2.%s', network));

x = konect_diammean(data);

save(sprintf('dat/statistic.meandist.%s', network), 'x', '-ascii');

