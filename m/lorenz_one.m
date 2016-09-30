%
% Plot one Lorenz curve.
%
% PARAMETERS 
%	p	(e*1) Node indexes
%	q	(e*1) Multiplicities; [] to denote all ones
%	b	1 for bare, else 0
%	type	One letter [auv]; determines the plot color
% 

function lorenz_one(p, q, b, type)

font_size = 18; 

colors = konect_colors_letter(); 

color_line = colors.(type); 
color_fill = 0.1 * color_line + 0.9 * [1 1 1]; 

[gini r_x r_y] = konect_gini(p, q); 
own = konect_own(p, q); 

hold on; 

plot(r_x, r_y, '-', 'LineWidth', 3, 'Color', color_line);

axis square;

axis([0, 1, 0, 1]); 

set(gca, 'FontSize', font_size); 

fill([r_x ; 0], [r_y ; 0], color_fill, 'LineStyle', 'none'); 

line([0 1],  [0 1], 'LineWidth', 2, 'Color', [0 0 0], 'LineStyle', '--'); 

if ~b
  line([1 0],  [0 1], 'LineWidth', 2, 'Color', [0 0 0], 'LineStyle', '--'); 
  plot(1-own, own, '.', 'MarkerSize', 30, 'Color', [0 0 0]); 
  text(1-own+0.04, own, sprintf('P = %.1f%%', own*100), 'FontSize', font_size, 'HorizontalAlign', 'Left', 'VerticalAlign', 'Middle'); 
end



grid on; 

set(gca, 'XTick', [0 .2 .4 .6 .8 1], 'XTickLabel', [cellstr('0%') cellstr('20%') cellstr('40%') cellstr('60%') cellstr('80%') cellstr('100%')]); 
set(gca, 'YTick', [0 .2 .4 .6 .8 1], 'YTickLabel', [cellstr('0%') cellstr('20%') cellstr('40%') cellstr('60%') cellstr('80%') cellstr('100%')]); 

xlabel('Share of nodes with smallest degrees');
ylabel('Share of edges'); 

text(0.25, 0.20, sprintf('G = %.1f%%', gini*100), 'FontSize', font_size); 
