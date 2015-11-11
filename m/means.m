%
% Compute the row and column means.  The halves are saved, to streamline
% normalization. 
%
% PARAMETERS 
%	$NETWORK
%	$TYPE		
%		full		On the full dataset
%		split		On the source set of the split
%		training	One the training set of the split
%
% INPUT 
%	dat/data.$NETWORK.mat (only FULL) 
%	dat/split.$NETWORK.mat (only SPLIT)
%
% OUTPUT 
%	dat/means{,i,t}.$NETWORK.mat	The means
%		U,V	The weights or []
% 

network = getenv('NETWORK'); 
type = getenv('TYPE'); 

info = read_info(network); 

if strcmp(type, 'full') 
    data = load(sprintf('dat/data.%s.mat', network)); 
    T = data.T; 
    suffix = 'i'; 
elseif strcmp(type, 'split')
    split = load(sprintf('dat/split.%s.mat', network)); 
    T = split.T_source; 
    suffix = ''; 
elseif strcmp(type, 'training')
    split = load(sprintf('dat/split.%s.mat', network)); 
    T = [ split.T_source ; split.T_target ]; 
    suffix = 't'; 
end

[U V] = means_best(T, info.n1, info.n2, info.weights); 

save(sprintf('dat/means%s.%s.mat', suffix, network), '-v7.3', 'U', 'V'); 
