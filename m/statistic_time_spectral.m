%
% Compute a spectral network statistic over time on either the full or the split dataset. 
%
% PARAMETERS 
%	$NETWORK	The network; must have timestamps
%	$STATISTIC	The statistic
%	$DECOMPOSITION
%	$TYPE		The data to use, "full" or "split"
%
% INPUT 
%	dat/info.$NETWORK
%	dat/stepsi.$NETWORK (only full)
%	dat/steps.$NETWORK.mat (only split) 
%	dat/decomposition_time.$TYPE.$DECOMPOSITION.$NETWORK.mat 
%
% OUTPUT 
%	dat/statistic_time.$TYPE.$STATISTIC.$NETWORK	
%		All statistics as text.  One timepoint per line.  Each
%		line contains the statistics, with the first number
%		being the main statistic. 
%

network = getenv('NETWORK'); 
statistic = getenv('STATISTIC'); 
decomposition = getenv('DECOMPOSITION'); 
type = getenv('TYPE');
is_split = strcmp(type, 'split'); 

info = read_info(network); 

if ~is_split
    e_steps = load(sprintf('dat/stepsi.%s', network)); 
else 
    steps = load(sprintf('dat/steps.%s.mat', network)); 
    e_steps = steps.e_steps; 
end

data_decomposition = load(sprintf('dat/decomposition_time.%s.%s.%s.mat', type, decomposition, network)); 

ret = []; 

for k = 1 : prod(size(e_steps))

    values = statistic_spectral(statistic, data_decomposition.decompositions(k).D, data_decomposition.decompositions(k).n); 

    if sum(size(ret)) ~= 0
        ret = [ret zeros(1, size(values,1) - size(ret, 2))];
    end
    ret = [ret ; values'];

end

save(sprintf('dat/statistic_time.%s.%s.%s', type, statistic, network), 'ret', '-ascii');
