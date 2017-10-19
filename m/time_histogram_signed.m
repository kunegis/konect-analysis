%
% Plot a signed time histogram. 
%
% PARAMETERS 
%	$network
%
% INPUT FILES 
%	uni/out.$network
%	uni/meta.$network 
% 
% OUTPUT FILES
%	plot/time_histogram_signed.[a].$network.eps
% 

bins = 90; 
font_size = 22; 
color_pos = [0 1 0];
color_neg = [1 0 0];

consts = konect_consts(); 
[negative, interval_scale] = konect_data_weights(); 

network = getenv('network');

weights = read_statistic('weights', network);  weights = weights(1) 

T = load(sprintf('uni/out.%s', network));

size_T = size(T) 

assert(size(T,2) == 4); % There must be timestamps in the dataset

% If the tag #aggregatetime is set, filter out entries with the
% lowest timestamp 
meta = read_meta(network); 
tags = get_tags(meta); 
if isfield(tags, 'aggregatetime')
    fprintf(1, '#aggregatetime:  Filtering out oldest timestamp\n'); 
    timestamp_min = min(T(:,4)) 
    T = T(T(:,4) ~= timestamp_min, :); 
    size_T = size(T) 
end

years = T(:,4) / (365.25 * 24 * 60 * 60) + 1970; 

range_step = ((max(years)-min(years))/ bins)
range = min(years) : range_step : max(years);

if interval_scale(weights)
  threshold = mean(T(:,3))
else
  threshold = 0;
end

% In the following, values equal to the threshold are counted as
% positive.  This includes zero weights in non-interval scales when they
% are allowed. 
i_pos = T(:,3) >= threshold;
i_neg = T(:,3) <  threshold; 

nn_pos = histc(years(i_pos), range);
nn_neg = histc(years(i_neg), range);

hold on; 

set(gca, 'FontSize', font_size); 

bar(range, nn_pos / range_step, 'FaceColor', color_pos, 'EdgeColor', color_pos); 
bar(range, - nn_neg / range_step, 'FaceColor', color_neg, 'EdgeColor', color_neg); 

xlabel('Time (t)', 'FontSize', font_size);
ylabel('Growth rate [edges / year]', 'FontSize', font_size); 

ax = axis(); 
ax(1) = min(years);
ax(2) = max(years);
axis(ax); 

set(gca, 'YGrid', 'on'); 

time_xaxis(min(years), max(years));

konect_print(sprintf('plot/time_histogram_signed.a.%s.eps', network));   
