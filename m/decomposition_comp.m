%
% Compute a network decomposition on the full network.
%
% PARAMETERS 
%	$network
%	$decomposition
%
% INPUT 
%	dat/data.$network.mat
%	dat/info.$network
%	dat/meansi.$network.mat
%
% OUTPUT 
%	dat/decomposition{,_map}.$decomposition.$network.mat
%		.D	Eigenvalues / Singular value / Middle matrix
%		.U	Eigenvectors or equivalent
%		.V	Eigenvectors; may be []
%		.r	Used rank
%		.n	Used number of nodes (may be less than input)
%

network = getenv('network');
decomposition = getenv('decomposition');

info = read_info(network); 

data = load(sprintf('dat/data.%s.mat', network)); 

means = load(sprintf('dat/meansi.%s.mat', network)); 

T = konect_normalize_additively(data.T, means); 

A = konect_spconvert(T, info.n1, info.n2); 

opts.disp = 2;

r = get_rank_type(network, decomposition);

[U D V D_u D_v n] = konect_decomposition(decomposition, A, r, info.format, info.weights, opts); 

save(sprintf('dat/decomposition.%s.%s.mat', decomposition, network'), '-v7.3', ...
  'D', 'U', 'V', 'r', 'n'); 
