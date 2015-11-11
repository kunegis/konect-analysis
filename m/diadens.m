%
% Plot average degree and diameter by time. 
%
% ENVIRONMENT 
%	$NETWORK		Network name 
%
% INPUT 
%	dat/stepsi.$NETWORK
%	dat/statistic_time.full.diameter.$NETWORK
%	dat/statistic_time.full.avgdegree.$NETWORK
%
% OUTPUT 
%	plot/diadens.$NETWORK.eps
%

font_size_label = 18; 

network = getenv('NETWORK');

steps = load(sprintf('dat/stepsi.%s', network));
statistic_diameter = load(sprintf('dat/statistic_time.full.diameter.%s', network)); 
statistic_avgdegree  = load(sprintf('dat/statistic_time.full.avgdegree.%s', network)); 

[ax, h1, h2] = plotyy(steps, statistic_avgdegree(:,1), steps, statistic_diameter(:,1), 'plot'); 
set(h1, 'LineWidth', 2.5) 
set(h2, 'LineWidth', 2.5);
set(h1,'LineStyle','--')
set(h2,'LineStyle','-')

set(get(ax(1),'Ylabel'),'String','Average degree (d)', 'FontSize', font_size_label); 
set(get(ax(2),'Ylabel'),'String','Effective diameter (\delta_{0.9})', 'FontSize', font_size_label); 
set(ax(1), 'FontSize', font_size_label); 
set(ax(2), 'FontSize', font_size_label); 

legend(konect_label_statistic('avgdegree', 'matlab'), konect_label_statistic('diameter', 'matlab'), 'Location', 'SouthEast'); 
legend('boxoff'); 

xlabel(konect_label_statistic('volume', 'matlab'), 'FontSize', font_size_label); 

konect_print(sprintf('plot/diadens.%s.eps', network)); 
