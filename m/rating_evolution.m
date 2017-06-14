%
% Plot the rating evolution, i.e. the mean rating of each item in
% function of number of ratings.
%
% PARAMETERS 
%	$network
%
% INPUT FILES 
%	dat/data.$network.mat
%
% OUTPUT FILES 
%	plot/rating_evolution.[ab].$network.eps
%

network = getenv('network');

data = load(sprintf('dat/data.%s.mat', network));

ids = unique(data.T(:,2));

%
% (b) - normalized to zero final mean weight
%
hold on; 

for k = 1:length(ids)

  i = ids(k);

  ati = data.T(find(data.T(:,2) == i), 3);

  n = length(ati); 
 
  range = 1:n;
  
  averages = cumsum(ati) ./ range';

  plot(range, averages - mean(ati), '-');  
  
end

konect_print(sprintf('plot/rating_evolution.b.%s.eps', network)); 

%
% (a) - all
%
hold on; 

for k = 1:length(ids)

  i = ids(k);

  ati = data.T(find(data.T(:,2) == i), 3);

  n = length(ati); 
 
  range = 1:n;
  
  averages = cumsum(ati) ./ range';

  plot(range, averages, 'g-');  
  
end

konect_print(sprintf('plot/rating_evolution.a.%s.eps', network)); 
