%
% Decompose the source and training matrices.
%
% PARAMETERS 
%	$NETWORK
%	$DECOMPOSITION
%	$TYPE		"source" or "training"
%
% INPUT 
%	dat/split.$NETWORK.mat 
%	dat/means.$NETWORK.mat (source only)
%	dat/meanst.$NETWORK.mat (training only)
%	dat/info.$NETWORK
% 
% OUTPUT 
%	dat/decomposition_split.$TYPE.$DECOMPOSITION.$NETWORK.mat
%		.D	Eigenvalues / Singular value / Middle matrix
%		.U	Eigenvectors or equivalent
%		.V	Eigenvectors; may be []
%		.r	Used rank
%		.n	Used number of nodes (may be less than input)
% 

network = getenv('NETWORK');
decomposition = getenv('DECOMPOSITION'); 
type = getenv('TYPE'); 

split = load(sprintf('dat/split.%s.mat', network));
info = read_info(network); 

if strcmp(type, 'source')
    T = split.T_source;
    means = load(sprintf('dat/means.%s.mat', network));
elseif strcmp(type, 'training')
    T = [ split.T_source ; split.T_target ];
    means = load(sprintf('dat/meanst.%s.mat', network));
else
    error(sprintf('*** Invalid type %s', type)); 
end

T = konect_normalize_additively(T, means); 

A = konect_spconvert(T, split.n1, split.n2);

opts.disp = 2;

r = get_rank_type(network, decomposition);

[U D V D_u D_v n] = konect_decomposition(decomposition, A, r, info.format, info.weights, opts); 

save(sprintf('dat/decomposition_split.%s.%s.%s.mat', type, decomposition, network), '-v7.3', ...
  'D', 'U', 'V', 'r', 'n'); 
