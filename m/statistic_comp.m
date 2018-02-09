%
% Compute a network statistic using Matlab. 
%
% PARAMETERS 
%	$network 
%	$statistic
%
% INPUT 
%	dat/data.$NETWORK.mat
%	dat/info.$NETWORK
%	dat/meansi.$NETWORK.mat 
%
% OUTPUT 
%	dat/statistic.$STATISTIC.$NETWORK
%		Text file with one number per line, the first being the statistic
%		itself and the other lines being additional values such as the error
%		on the value.  As a last value, the runtime is added. 
%

network = getenv('network');
statistic = getenv('statistic'); 

format long; 

data = load(sprintf('dat/data.%s.mat', network)); 
T = data.T; 

info = read_info(network); 

means = load(sprintf('dat/meansi.%s.mat', network)); 
T = konect_normalize_additively(T, means); 

A = konect_spconvert(T, info.n1, info.n2); 

t0 = cputime;
values = konect_statistic(statistic, A, info.format, info.weights);
t1 = cputime;
runtime = t1 - t0; 
values = [full(values) ; runtime]; 

if sum(isnan(values)) ~= 0
  values
  error('*** NaN in statistic computation'); 
end

save(sprintf('dat/statistic.%s.%s', statistic, network), 'values', ...
     '-ascii', '-double'); 
