%
% Plot one Zipf plot.
%
% PARAMETERS 
%	p	(e*1) Node indexes
%	q	(e*1) Multiplicities; [] to denote all ones
%	letter
%

function zipf_one(p, q, letter)

font_size = 24; 
marker_size = 13; 
point_style = '.'; 

colors = konect_colors_letter();

if length(q) == 0
    q = 1; 
end

degrees = full(sparse(p, 1, q, max(p), 1)); 

degrees = degrees(find(degrees)); 

[~,i] = sort(-degrees);

degrees = degrees(i); 

loglog(1:length(degrees), degrees, point_style, 'Color', colors.(letter), 'MarkerSize', marker_size); 

set(gca, 'FontSize', font_size); 

xlabel('Rank (i)', 'FontSize', font_size);
ylabel('Degree (d(i))', 'FontSize', font_size); 

ax = axis()

set(gca, 'XMinorTick', 'on');
set(gca, 'YMinorTick', 'on'); 
set(gca, 'TickLength', [0.05 0.05]); 

% Workaround for Matlab bug. Otherwise, the minor ticks are not visible. 
ax = axis(); 
if ax(1) > 0 & ax(3) > 0 
  set(gca, 'XTick', 10 .^ (ceil(log(ax(1)) / log(10)):floor(log(ax(2)) / log(10)))); 
  set(gca, 'YTick', 10 .^ (ceil(log(ax(3)) / log(10)):floor(log(ax(4)) / log(10)))); 
end
