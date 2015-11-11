%
% Estimate the trend in the time evolution of a statistic.
%
% PARAMETERS 
%	$NETWORK
%	$STATISTIC
%	$TYPE
%
% INPUT 
%	dat/statistic_time.$TYPE.$STATISTIC.$NETWORK
%
% OUTPUT 
%	dat/trend.$TYPE.$STATISTIC.$NETWORK.mat
%		H	1 when the trend is significant, 0 otherwise (regardless of direction)
%		p 	p value (regardless of direction)
%		updown	Direction of trend: +1 up, -1 down
%		range	Range of time values used (in 1..100)
%		values	Values used
%

network = getenv('NETWORK');
statistic = getenv('STATISTIC');
type = getenv('TYPE') 

data = load(sprintf('dat/statistic_time.%s.%s.%s', type, statistic, network)); 

alpha = 0.05; 

if strcmp(type, 'full')
  first = floor(size(data,1) / 2);
elseif strcmp(type, 'split')
  steps = load(sprintf('dat/steps.%s.mat', network))
  first = 1 + steps.steps_source;
else
  error '***'; 
end

range = first:size(data,1);

values = data(range, 1)

[ H p ] = Mann_Kendall(values, alpha)

% New code for estimating updown:  Linear least squares on ranks
if size(values,1) > size(values,2), values = values'; end; 
[x i] = sort(values) ; 
X = i / [ 1 : length(values) ; ones(1, length(values)) ]; 
updown = sign(X(1))

% Old code for estimating updown:  sign of difference of sum between first and second half of values
%l = floor(length(values) / 2)
%values_begin = values(1:l)
%values_end   = values(end:-1:end-l+1)
%updown = sign(sum(values_end) - sum(values_begin))

save(sprintf('dat/trend.%s.%s.%s.mat', type, statistic, network), '-v7.3', ...
  'H', 'p', 'updown', 'range', 'values');
