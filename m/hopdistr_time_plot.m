%
% Draw hop plot in function of time.
%
% PARAMETERS 
%	$network
%	$type		"full" or "split"
%
% INPUT FILES 
%	dat/hopdistr_time.$type.$statistic.$network
%	dat/hopdistr_time_runtime.$type.$statistic.$network
%	dat/stepsi.$network (full only)
%	dat/steps.$network.mat (split only) 
%
% OUTPUT FILES 
%	plot/hopdistr_time.$type.[a].$network.eps
%		a - Number of vertex pairs on Y axis
%		b - Average number of vertices on Y axis
%		c - Mean reachable part on Y axis
% 

network = getenv('network'); 
type = getenv('type'); 
is_split = strcmp(type, 'split'); 

font_size = 18; 
font_size_label = 10; 

data = load(sprintf('dat/hopdistr_time.%s.%s', type, network));

if ~is_split
  e_steps = load(sprintf('dat/stepsi.%s', network)); 
else
  steps_data = load(sprintf('dat/steps.%s.mat', network)); 
  e_steps = steps_data.e_steps; 
  range_test = (1 + steps_data.steps_source + steps_data.steps_target) : length(e_steps); 
end

%
% (b) - Average of vertices
%
legends = []; 
data_b = data;
for i = 1 : size(data,1), data_b(i,:) = data_b(i,:) / sqrt(max(data_b(i,:))); end
hold on; 
for i = size(data,2) : -1 : 1
  color = hsv2rgb([(i / size(data,2)) 1 1]); 
  row = data_b(:,i);
  row(find(row == 0)) = NaN; 
  plot(e_steps, row, '*-', 'Color', color);
  legends = [ legends ; cellstr(sprintf('%u hops', i)) ]; 
end

axis([0 (e_steps(end)*1.05) 0 (max(max(data_b))*1.05)]); 
xlabel(konect_label_statistic('volume', 'matlab'), 'FontSize', font_size);
ylabel('Average reachable vertices [vertices]', 'FontSize', font_size); 
legend(legends, 'Location', 'EastOutside', 'FontSize', font_size_label); 
set(gca, 'FontSize', font_size); 

konect_print(sprintf('plot/hopdistr_time.%s.b.%s.eps', type, network));

%
% (c) - Mean reachable part
%
legends = []; 
data_c = data;
for i = 1 : size(data,1), data_c(i,:) = data_c(i,:) / max(data_c(i,:)); end
hold on; 
for i = size(data,2) : -1 : 1
  color = hsv2rgb([(i / size(data,2)) 1 1]); 
  row = data_c(:,i);
  row(find(row == 0)) = NaN; 
  plot(e_steps, row, '*-', 'Color', color);
  legends = [ legends ; cellstr(sprintf('%u hops', i)) ]; 
end

axis([0 (e_steps(end)) 0 1]); 
xlabel(konect_label_statistic('volume', 'matlab'), 'FontSize', font_size);
ylabel('Mean reachable part', 'FontSize', font_size); 
legend(legends, 'Location', 'EastOutside', 'FontSize', font_size_label); 
set(gca, 'FontSize', font_size); 
set(gca, 'YTick', 0:.1:1); 
set(gca, 'YTickLabel', { '0%', '10%', '20%', '30%', '40%', '50%', '60%', '70%', '80%', '90%', '100%' }); 
set(gca, 'YGrid', 'on'); 

konect_print(sprintf('plot/hopdistr_time.%s.c.%s.eps', type, network));

%
% (a) - Default plot
%
legends = []; 
hold on; 
for i = size(data,2) : -1 : 1
  color = hsv2rgb([(i / size(data,2)) 1 1]); 
  line = data(:,i);
  line(find(line == 0)) = NaN; 
  plot(e_steps, line, '*-', 'Color', color);
  legends = [ legends ; cellstr(sprintf('%u hops', i)) ]; 
end

axis([0 (e_steps(end)*1.05) 0 (max(max(data))*1.05)]); 
xlabel(konect_label_statistic('volume', 'matlab'), 'FontSize', font_size);
ylabel('Vertex pairs [vertex^2]', 'FontSize', font_size); 
legend(legends, 'Location', 'EastOutside', 'FontSize', font_size_label); 
set(gca, 'FontSize', font_size); 

konect_print(sprintf('plot/hopdistr_time.%s.a.%s.eps', type, network));
