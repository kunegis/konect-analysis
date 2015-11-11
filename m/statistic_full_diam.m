DEPRECATED

%
% Compute the diameter from the hopdistr data.
%
% PARAMETERS 
%	$NETWORK
%
% INPUT 
%	dat/hopdistr.$NETWORK
%
% OUTPUT 
%	dat/statistic_full.diam.$NETWORK
%		[1] diameter
%		[2] 90-percentile effective diameter
%		[3] 50-percentile effective diameter
%		[4] mean path length
%		[5] median path length
%

network = getenv('NETWORK')

data = load(sprintf('dat/hopdistr.%s', network)); 

values(1) = length(data); 
values(2) = konect_diameff(data, 0.9); 
values(3) = konect_diameff(data, 0.5); 
values(4) = konect_diammean(data); 
values(5) = floor(values(3)); 

values = values'; 

save(sprintf('dat/statistic_full.diam.%s', network), 'values', '-ascii'); 
