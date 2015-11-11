%
% Draw one degree distribution.
%
% When the two last parameters are not given, the gamma plot is not drawn. 
%
% PARAMETERS 
%	a		The adjacency matrix.  The left distribution is taken out of it. 
%       power		The gamma exponent, NaN when no exponent is drawn 
%	xmin		The xmin to show; NaN to not show it
%	pvalue		The pvalue to show; NaN to not show it
%	name		Used in xlabel
%	type		Determines the color
%			a	Uniform
%			u	Left / outdegree
%			v 	Right / outdegree
%

function degree_print(a, power, xmin, pvalue, name, type)

% TODO:  use konect_plot_degdist() 

font_size = 24; 
point_style = '.'; 
marker_size = 13; 

% Slope line
p = .1; % distance to center of line in proportion to plot width
length = .2; % relative length of line

% Positions
X = .6; 
Y = .6; 

colors = konect_colors_letter(); 

degree = full(sum(a, 2));

[counts ids] = sort(degree); 

maxcount = counts(end);
freq = histc(counts, 0 : maxcount); 

nz = freq ~= 0; 
ra = 0 : maxcount; 
ra = ra(nz);
fq = freq(nz); 

loglog(ra, fq, point_style, 'Color', colors.(type), 'MarkerSize', marker_size);

set(gca, 'FontSize', font_size); 

xlabel(name);
ylabel('Frequency'); 

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


if ~isnan(power) 

  % Line of estimated slope

  % Log-length of line
  l = length * min(log(ax(4)/ax(3)), log(ax(2)/ax(1))) 

  % Log radius 
  lrx = l / sqrt(power^2 + 1) 
  lry = sqrt(l^2 * (1 - 1/(power^2 + 1))) 

  % Log positions of centers
  lx = (1-X) * log(ax(1)) + X * log(ax(2))
  ly = (1-Y) * log(ax(3)) + Y * log(ax(4))

  line([exp(lx - lrx) exp(lx + lrx)], [exp(ly + lry) exp(ly - lry)], ...
       'Color', [0 0 0], 'LineWidth', 3);

  % Text showing gamma
  t = sprintf('\\gamma = %.2f', power)
  text(exp((1-X)*log(ax(1))+X*log(ax(2))), exp((1-Y)*log(ax(3))+Y*log(ax(4))), ...
     t, 'Color', [0 0 0], 'FontSize', font_size, ...
     'HorizontalAlignment', 'Left', 'VerticalAlignment', 'Bottom'); 

end

if ~isnan(xmin)
  gridxy([xmin], [], 'LineStyle', '--'); 

  % Text showing the p-value
  t = sprintf('x_{min} = %d', xmin)
  Y_xmin = X + .12; % Print p-value text over the \gamma text
  text(exp((1-X)*log(ax(1))+X*log(ax(2))), exp((1-Y_xmin)*log(ax(3))+Y_xmin*log(ax(4))), ...
     t, 'Color', [0 0 0], 'FontSize', font_size, ...
     'HorizontalAlignment', 'Left', 'VerticalAlignment', 'Bottom'); 
  
end

if ~isnan(pvalue)
  % Text showing the p-value
  t = sprintf('p = %.4f', pvalue)
  Y_pvalue = X + .28; % Print p-value text over the x_min text
  text(exp((1-X)*log(ax(1))+X*log(ax(2))), exp((1-Y_pvalue)*log(ax(3))+Y_pvalue*log(ax(4))), ...
     t, 'Color', [0 0 0], 'FontSize', font_size, ...
     'HorizontalAlignment', 'Left', 'VerticalAlignment', 'Bottom'); 
end
