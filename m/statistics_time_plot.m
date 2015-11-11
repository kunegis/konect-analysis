%
% Aggregate plot of all statistics over time.
%
% PARAMETERS 
%	$NETWORK
%	$TYPE		"full" or "split"
%	$STATISTICS	Space-separated list of statistics
%
% INPUT 
%	dat/statistic_time.$TYPE.$STATISTIC.$NETWORK
%		for each $STATISTICS in $STATISTICS
%
% OUTPUT 
%	plot/statistics_time.[a].$TYPE.$NETWORK.eps
%

network = getenv('NETWORK');
type = getenv('TYPE'); 
statistics = getenv('STATISTICS'); 

statistics = regexp(statistics, '\S+', 'match')

datas = []; 
legends = []; 

for k = 1:size(statistics, 2)
    statistic = statistics(k)
    statistic = statistic{:}

    data = load(sprintf('dat/statistic_time.%s.%s.%s', type, statistic, network));
    data = data(:,1); 

    % Normalize
    part = data(10:end); 
    i = min(part); 
    a = max(part); 
    data = (data - i) / (a - i); 

    datas = [ datas  data ];

    legends = [ legends ; cellstr(konect_label_statistic(statistic, 'matlab-short')) ]; 
end

colors= [0  0  0;
         1  0  0;
         0  1  0;
         0  0  1;
         .5 0  0; 
         0  .5 0; 
         .7 .7 0;
         1  0  1;
         0  1  1 ];

set(0,'DefaultAxesColorOrder', colors, 'DefaultAxesLineStyleOrder','-|--|-.')

plot(1 : size(datas, 1), datas); 

axis([ 0 size(datas,1) 0 1]); 

xlabel(konect_label_statistic('volume', 'matlab')); 

legend(legends, 'Location', 'EastOutside'); 

konect_print(sprintf('plot/statistics_time.a.%s.%s.eps', type, network)); 
