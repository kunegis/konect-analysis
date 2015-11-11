%
% Test the hypothesis of shrinking diversity
%
% PARAMETERS 
%	$NETWORKS	Space-separated list of networks
%	$STATISTIC
%	$TYPE		"split" or "full"
%
% INPUT 
%	dat/trend.$TYPE.$STATISTIC.$NETWORK.mat
%		For each $STATISTIC in $STATISTICS
%
% OUTPUT 
%	dat/shrinkingdiversity.$TYPE.$STATISTIC		Unspecified content (evaluated by hand)
%

networks = getenv('NETWORKS');  networks = regexp(networks, '[a-zA-Z0-9_-]+', 'match')
statistic = getenv('STATISTIC'); 
type = getenv('TYPE'); 

alpha = 0.05;

updown_statistic = get_updown_statistic(); 
updown_statistic_i = updown_statistic.(statistic); 

% Each column is a network
% Rows correspond to those in dat/trend.*
data = [];

n = length(networks) 

for i = 1 : n
    network = networks{i}

    data_i = load(sprintf('dat/trend.%s.%s.%s.mat', type, statistic, network));

    data = [ data [ data_i.H ; data_i.updown ] ]; 
end

going_up   = data(2,:) > 0; 
going_down = data(2,:) < 0; 
k_up =   sum(going_up)		% Number of networks where statistic goes up
k_down = sum(going_down)	% Number of networks where statistic goes down


p_up   = betainc(0.5, k_up  , n - k_up   + 1)	% p-value for hypothesis of going up
p_down = betainc(0.5, k_down, n - k_down + 1)	% p-value for hypothesis of going down
H_up   = p_up   < alpha 			% whether the going-up hypothesis is validated
H_down = p_down < alpha 			% whether the going-down hypothesis is validated

if updown_statistic_i > 0
    H = H_up
else
    H = H_down
end

%
% Save
%
OUT = fopen(sprintf('dat/shrinkingdiversity.%s.%s', type, statistic), 'w');
fprintf(OUT, '%u\n%u\n%u\n%g\n%u\n%g\n%u\n%u\n', ...
        k_up, k_down, n, p_up, H_up, p_down, H_down, H); 
if fclose(OUT); error '*** fclose'; end;

