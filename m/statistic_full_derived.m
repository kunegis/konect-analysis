DEPRECATED

%
% Compute a statistic from another statistic
%
% PARAMETERS 
%	$NETWORK		Network
%	$STATISTIC 		Statistic to be computed
%	$STATISTIC_UNDERLYING	Statistic which is used for computation
%
% INPUT 
%	dat/statistic_full.$STATISTIC_UNDERLYING.$NETWORK
%	dat/statistic_full.*.$NETWORK
%	dat/info.$NETWORK
%
% OUTPUT 
%	dat/statistic_full.$STATISTIC.$NETWORK
%

network = getenv('NETWORK');
statistic = getenv('STATISTIC');
statistic_underlying = getenv('STATISTIC_UNDERLYING');

values_underlying = load(sprintf('dat/statistic_full.%s.%s', statistic_underlying, network));

values_size = load(sprintf('dat/statistic_full.size.%s', network)); 
values_volume = load(sprintf('dat/statistic_full.volume.%s', network)); 
values_uniquevolume = load(sprintf('dat/statistic_full.uniquevolume.%s', network)); 
values_fill = load(sprintf('dat/statistic_full.fill.%s', network)); 
values_avgdegree = load(sprintf('dat/statistic_full.avgdegree.%s', network)); 

values = konect_statistic_derived(statistic, statistic_underlying, ...
                                  values_underlying, values_size, ...
                                  values_volume, values_uniquevolume, ...
                                  values_fill, values_avgdegree); 

save(sprintf('dat/statistic_full.%s.%s', statistic, network), 'values', ...
     '-ascii'); 
