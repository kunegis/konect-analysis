UNUSED

%
% Plot the edge distribution.
%
% PARAMETERS
%	$NETWORK
%
% INPUT
%	dat/data.$NETWORK.mat
%
% OUTPUT
%	plot/edge.[auv].$NETWORK.eps
%		a - Overall
%		u - Left (BIP)
%		v - Right (BIP
%		u - Outgoing edges (ASYM)
%		v - Ingoing edges (ASYM)
%

network = getenv('NETWORK');

consts = konect_consts(); 

info = read_info(network); 

data = load(sprintf('dat/data.%s.mat', network)); 
T = data.T; 
A = konect_spconvert(T, info.m, info.n); 


if info.weights == consts.SIGNED | info.weights == consts.WEIGHTED
  A = A ~= 0; 
end


if info.format == consts.SYM

  edge_print(A + A', 'Degree', 'a', network); 

elseif info.format == consts.ASYM

  edge_print(A + A', 'Degree', 'a', network);
  edge_print(A, 'Outdegree', 'u', network);
  edge_print(A', 'Indegree', 'v', network);

elseif info.format == consts.BIP

  edge_print([ sparse(info.m,info.m) A ; A' sparse(info.n,info.n) ], 'Edges', 'a', network);
  edge_print(A, 'Left degree', 'u', network);
  edge_print(A', 'Right degree', 'v', network);   

end
