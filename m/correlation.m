%
% Perform a correlation analysis of statistics.
%
% PARAMETERS 
%	$NETWORKS	Space-separated list of networks
%	$STATISTICS	Space-separated list of statistics
%	$CLASS		Class name (test, 1, 2, 3, etc.)
%	$FORMAT		e.g., "square"
%
% INPUT 
%	dat/statistic.$STATISTIC.$NETWORK
%
% OUTPUT 
%	dat/correlation.$FORMAT.$CLASS.mat
%

cd ..;

networks = getenv('NETWORKS');
statistics = getenv('STATISTICS');
class = getenv('CLASS')
format = getenv('FORMAT')

networks = regexp(networks, '[a-zA-Z0-9_-]+', 'match')
statistics = regexp(statistics, '[a-zA-Z0-9_-]+', 'match')

n = length(networks)
k = length(statistics)


%
% Load all data
%

stat = zeros(n, k); % network * statistic

for i = 1 : n
    
    network = networks{i}
    
    for j = 1 : k
        
        statistic = statistics{j}

        values = load(sprintf('dat/statistic.%s.%s', statistic, ...
                              network));
        
        stat(i, j) = values(1);

    end
    
end

stat

stat_log = log(stat)

%
% Regression
%

for i = 2 : k

    i

    x = [ stat_log(:,1:i-1) ones(n,1) ] \ stat_log(:,i)

end

%
% Save
%

save(sprintf('dat/correlation.%s.%s.mat', format, class), '-v7.3', ...
     'stat_log');


