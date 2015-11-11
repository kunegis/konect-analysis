%
% Plot the network evolution together with the p-value and tendency. 
%
% PARAMETERS 
%	$NETWORK
%	$STATISTIC
%	$TYPE		full or split
%
% INPUT 
%	dat/trend.$TYPE.$STATISTIC.$NETWORK.mat
%
% OUTPUT 
%	plot/trend.$TYPE.$STATISTIC.$NETWORK.eps
%

network = getenv('NETWORK');
statistic = getenv('STATISTIC');
type = getenv('TYPE');

line_width = 5; 
font_size = 86; 

data = load(sprintf('dat/trend.%s.%s.%s.mat', type, statistic, network)); 

updown_statistic = get_updown_statistic(); 

shrinking = data.H & data.updown == updown_statistic.(statistic) 
		    
if shrinking
    color_test = [ 0 .7 0 ]; 
else
    color_test = [ .7 0 0 ];
end

plot(data.range, data.values, '-', 'LineWidth', line_width, 'Color', color_test); 

set(gca, 'XTick', [], 'YTick', []); 

axis tight;

if shrinking
    ax = axis(); 
    text(ax(2), ax(3), sprintf('%.3g', data.p), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'FontSize', font_size); 
end

konect_print(sprintf('plot/trend.%s.%s.%s.eps', type, statistic, network)); 

