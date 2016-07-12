%
% Compute a spectral distribution.
%
% PARAMETERS 
%	$network		Network
%	$decomposition		Decomposition type
%
% INPUT 
% 	dat/data.$network.mat
%	dat/meansi.$network.mat
%
% OUTPUT 
%	dat/distr.$decomposition.$network
%		One line per bin.  Three columns:  count, begin end.
%		For time networks, all columns are doubled for the
%		halftime graph.   
%

% Odd to avoid splitting on zero
bin_count = 49; 

network = getenv('network'); 
decomposition = getenv('decomposition'); 

info = read_info(network)

data = load(sprintf('dat/data.%s.mat', network)); 
means = load(sprintf('dat/meansi.%s.mat', network)); 

A = konect_spconvert(konect_normalize_additively(data.T, means), info.n1, info.n2); 

[counts, begins, ends] = konect_spectral_distribution(A, decomposition, info.format, bin_count); 

ret = [ counts begins ends ]; 

save(sprintf('dat/distr.%s.%s', decomposition, network), '-ascii', 'ret'); 
