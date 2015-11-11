%
% Compute a network decomposition on the full network.
%
% PARAMETERS 
%	$NETWORK
%	$DECOMPOSITION
%
% INPUT 
%	dat/data.$NETWORK.mat
%	dat/info.$NETWORK
%	dat/meansi.$NETWORK.mat
%
% OUTPUT 
%	dat/decomposition{,_map}.$DECOMPOSITION.$NETWORK.mat
%		.D	Eigenvalues / Singular value / Middle matrix
%		.U	Eigenvectors or equivalent
%		.V	Eigenvectors; may be []
%		.r	Used rank
%		.n	Used number of nodes (may be less than input)
%

network = getenv('NETWORK');
decomposition = getenv('DECOMPOSITION');

info = read_info(network); 

data = load(sprintf('dat/data.%s.mat', network)); 

means = load(sprintf('dat/meansi.%s.mat', network)); 

T = konect_normalize_additively(data.T, means); 

A = konect_spconvert(T, info.n1, info.n2); 

opts.disp = 2;
opts.maxit = 10;
opts.tol = 1e-3; 

first = konect_first_index(decomposition);
r = first + 1;

[U D V D_u D_v n] = konect_decomposition(decomposition, A, r, info.format, info.weights, opts); 

save(sprintf('dat/decomposition_map.%s.%s.mat', decomposition, network'), '-v7.3', ...
  'D', 'U', 'V', 'r', 'n'); 
