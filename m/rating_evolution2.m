%
% Plot the rating evolution, i.e. the mean rating of each item in
% function of number of ratings.  Plot only the fast stuff.
%
% PARAMETERS 
%	$network
%
% INPUT FILES 
%	dat/data.$network.mat
%
% OUTPUT FILES 
%	plot/rating_evolution.[c].$network.eps
%

network = getenv('network');

bins = 10; 
font_size = 22;
line_width = 3; 

data = load(sprintf('dat/data.%s.mat', network));

ids = unique(data.T(:,2));

rating_min = min(data.T(:,3))
rating_max = max(data.T(:,3)) 

sums   = zeros(bins, 0); 
counts = zeros(bins, 0);

%
% (c) - all
%

for k = 1:length(ids)

  i = ids(k);
  ati = data.T(find(data.T(:,2) == i), 3);
  n = length(ati); 
  range = 1:n;
  average = cumsum(ati)' ./ range;

  if length(average) > size(sums,2)
    sums     = [sums    , zeros(bins, length(average) - size(sums  , 2))]; 
    counts   = [counts  , zeros(bins, length(average) - size(counts, 2))]; 
  end  

  i_bin = 1 + floor(bins * (average(end) - rating_min) / (rating_max - rating_min)); 
  if i_bin > 10, i_bin = 10; end

  rating_midbin = rating_min + (i_bin - 0.5) * (rating_max - rating_min) / bins;

  average = average - average(end) + rating_midbin; 

  sums(i_bin, 1 : length(average)) = sums(i_bin, 1 : length(average)) + average;
  counts(i_bin, 1 : length(average)) = counts(i_bin, 1 : length(average)) + ones(size(average));   
  
end

hold on;

for i = 1 : bins
  plot(1 : size(sums, 2), sums(i, :) ./ counts(i, :), '-', ...
      'LineWidth', line_width); 
end

set(gca, 'FontSize', font_size); 

konect_print(sprintf('plot/rating_evolution2.c.%s.eps', network)); 
