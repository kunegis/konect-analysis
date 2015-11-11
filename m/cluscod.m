%
% Compute the distribution of local clustering coefficients.  The
% values are computed for the underlying undirected, unweighted
% network. 
%
% PARAMETERS 
%	$NETWORK	Network name
%
% INPUT 
%	dat/data.$NETWORK.mat
%	dat/info.$NETWORK
%
% OUTPUT 
%	dat/cluscod.$NETWORK.mat
%		c_local		Vector of node degree distributions
%		c
%		c2
%

consts = konect_consts(); 

network = getenv('NETWORK'); 

data = load(sprintf('dat/data.%s.mat', network)); 

info = read_info(network);

assert(info.format ~= consts.BIP); 

% Ignore edge weights
A = sparse(data.T(:,1), data.T(:,2), 1, info.n1, info.n2); 

% Remove multiple edges 
A = (A ~= 0); 

% Ignore edge directions 
A = A | A'; 

[c_local c c2] = konect_clusco(A); 

c
c2

save(sprintf('dat/cluscod.%s.mat', network), 'c_local', 'c', 'c2', '-v7.3');
