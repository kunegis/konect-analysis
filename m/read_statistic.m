%
% Read a network statistic.
%
% RETURN VALUES 
%	data	(k*) Vector of all computed values
%
% PARAMETERS  
%	statistic	Internal name of statistic
%	network		Internal name of network
%	k		(optional) Number of values to return; by
% 			default, return all values 
%

function data = read_statistic(statistic, network, k)

data = load(sprintf('dat/statistic.%s.%s', statistic, network));

assert(size(data, 2) == 1); 

if (exist('k', 'var') == 1)
  assert(length(data) >= k); 
  data = data(:,1:k);
end
