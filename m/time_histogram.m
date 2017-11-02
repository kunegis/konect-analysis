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
%	plot/time_histogram.[ab].$network.eps
%		(a) Distribution density plot
%		(b) Cumulative plot 
%

bins = 90; 
font_size = 22;
line_width = 3; 
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

ax = axis(); 
ax(1) = min(years);
ax(2) = max(years);
axis(ax); 

set(gca, 'YGrid', 'on'); 

set(gca, 'YMinorTick', 'on'); 
set(gca, 'TickLength', [0.05 0.05]); 

time_xaxis(min(years), max(years));

konect_print(sprintf('plot/time_histogram.a.%s.eps', network));   

%
% (b) Cumulative
%

stairs(sort(timestamps), 1:length(timestamps), 'LineWidth', line_width, 'Color', color_1); 

mi = min(timestamps)
ma = max(timestamps)

axis([(mi - 0.05 * (ma-mi)) (ma + 0.05 * (ma-mi)) 0 length(timestamps)]); 

xlabel('Time (t)', 'FontSize', font_size); 
ylabel(konect_label_statistic('volume', 'matlab'), 'FontSize', font_size); 
    
set(gca, 'FontSize', font_size); 

set(gca, 'XMinorTick', 'on');
set(gca, 'YMinorTick', 'on'); 
set(gca, 'TickLength', [0.05 0.05]); 

konect_print(sprintf('plot/time_histogram.b.%s.eps', network));   
