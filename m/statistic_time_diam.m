%
% Computer the "diam" statistic from the hop distribution.
%
% PARAMETERS 
%	$NETWORK
%	$TYPE		"full" or "split"
%
% INPUT 
%	dat/hopdistr_time.$TYPE.$NETWORK
%
% OUTPUT 
%	dat/statistic_time.$TYPE.diam.$NETWORK
%

network = getenv('NETWORK');
type = getenv('TYPE');

data = load(sprintf('dat/hopdistr_time.%s.%s', type, network)); 

ret = [];

for i = 1 : size(data,1)
    line = data(i, :); 
    line = data(find(data > 0)); 
    values = []; 
    values(1) = length(line); 
    values(2) = konect_diameff(line, 0.9); 
    values(3) = konect_diameff(line, 0.5); 
    values(4) = konect_diammean(line); 
    ret = [ret ; values];
end

save(sprintf('dat/statistic_time.%s.diam.%s', type, network), 'ret', '-ascii'); 

