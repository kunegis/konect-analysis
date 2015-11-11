%
% Compute the hop plot of the largest connected component.  We always
% compute the undirected hop plot (and thus also the undirected
% diameter).  
%
% PARAMETERS 
%	$NETWORK
%
% INPUT 
%	dat/data.$NETWORK.mat
%	dat/info.$NETWORK
% 
% OUTPUT 
%	dat/hopdistr.$NETWORK
%		As integer, the number of hops (zero excluded) 
%

network = getenv('NETWORK');

consts = konect_consts(); 

data = load(sprintf('dat/data.%s.mat', network)); 

info = read_info(network);

A = sparse(data.T(:,1), data.T(:,2), 1, info.n1, info.n2);
A = (A ~= 0); 

% Make undirected and keep largest connected component
if info.format == consts.ASYM | info.format == consts.SYM
    A = konect_connect_matrix_square(A); 
elseif info.format == consts.BIP
    A = konect_connect_matrix_bipartite(A); 
else
    error('*** Invalid format'); 
end

n = length(A)

d = konect_hopdistr(A, info.format); 

OUT = fopen(sprintf('dat/hopdistr.%s', network), 'w');
fprintf(OUT, '%ld\n', d); 
if fclose(OUT), error 'fclose'; end; 

