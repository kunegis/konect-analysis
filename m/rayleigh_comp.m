%
% Compute the Rayleigh coefficient distribution.
%
% PARAMETERS 
%	$NETWORK
%	$DECOMPOSITION
%
% INPUT 
%	dat/data.$NETWORK.mat 
%	dat/info.$NETWORK
%
% OUTPUT 
%	dat/rayleigh.$DECOMPOSITION.$NETWORK.mat
%		.values		(k*1) Rayleigh quotients, sorted
%				ascendingly 
% 

network = getenv('NETWORK');
decomposition = getenv('DECOMPOSITION'); 

info = read_info(network); 

data = load(sprintf('dat/data.%s.mat', network)); 

T = data.T;
if size(T,2) > 3
    T = T(:, 1:3); 
end

A = konect_spconvert(T, info.n1, info.n2); 

if strcmp(decomposition, 'sym')
    d2 = 'symfull';
elseif strcmp(decomposition, 'sym-n')
    d2 = 'sym-nfull';
else
    d2 = decomposition; 
end

A = konect_matrix(d2, A, info.format, info.weights); 

size_A = size(A) 

n = size(A, 1) 

k = 100000; 

values = zeros(k, 1); 

t = konect_timer(k); 

for i = 1:k
    
    t = konect_timer_tick(t, i); 

    x = randn(n, 1); 
    values(i) = (x' * A * x) / (x' * x); 
end

konect_timer_end(t); 

values = sort(values); 

save(sprintf('dat/rayleigh.%s.%s.mat', decomposition, network), 'values', '-v7.3'); 
