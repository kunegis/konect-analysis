%
% Read a network statistic.
%
% RESULTS 
%	value	Vector of all computed values
%
% PARAMETERS 
%	statistic
%	network
%

function data = read_statistic(statistic, network)

data = load(sprintf('dat/statistic.%s.%s', statistic, network));
