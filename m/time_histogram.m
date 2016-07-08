%
% Plot a time histogram.
%
% PARAMETERS 
%	$network
%
% INPUT 
%	dat/time.$network
%	uni/meta.$network
% 
% OUTPUT 
%	plot/time_histogram.$network.eps
%	plot/time_histogram.[b].$network.eps
%

bins = 90; 
font_size = 22; 
color_1 = [0 0 1]; 

network = getenv('network'); 

timestamps = load(sprintf('dat/time.%s', network)); 

% If the tag #aggregatetime is set, filter out entries with the
% lowest timestamp 
meta = read_meta(network); 
tags = get_tags(meta); 
if isfield(tags, 'aggregatetime')
    fprintf(1, '#aggregatetime:  Filtering out oldest timestamp\n'); 
    timestamp_min = min(timestamps) 
    timestamps = timestamps(timestamps ~= timestamp_min, :); 
    size_timestamps = size(timestamps) 
end

years = timestamps / (365.25 * 24 * 60 * 60) + 1970; 

%
% Main plot
% 

set(gca, 'FontSize', font_size); 

range_step = ((max(years)-min(years))/ bins)
range = min(years) : range_step : max(years);

nn = histc(years, range);

bar(range, nn / range_step); 

h = findobj(gca,'Type','patch');
set(h, 'FaceColor', color_1, 'EdgeColor', color_1)

xlabel('Time (t)', 'FontSize', font_size);
ylabel('Growth rate [edges / year]', 'FontSize', font_size); 

%min_timestamps = min(timestamps) 

ax = axis(); 
ax(1) = min(years);
ax(2) = max(years);
axis(ax); 

set(gca, 'YGrid', 'on'); 

time_xaxis(min(years), max(years));

konect_print(sprintf('plot/time_histogram.%s.eps', network));   

%
% (b) Cumulative
%

stairs(sort(timestamps), 1:length(timestamps)); 

xlabel('Time (y)', 'FontSize', font_size); 
ylabel(konect_label_statistic('volume', 'matlab'), 'FontSize', font_size); 
    
konect_print(sprintf('plot/time_histogram.b.%s.eps', network));   
