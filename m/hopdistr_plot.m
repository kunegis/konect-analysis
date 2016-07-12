%
% Plot a hop plot.
%
% PARAMETERS 
%	$network
%
% INPUT 
%	dat/hopdistr2.$network
%
% OUTPUT 
%	plot/hopdistr.[abc...].$network.eps
%		a - Normal plot
%		b - logistic axis
%		c - tangent
%		d - artanh
%		e - inverse error function
%		f - Weibull function
%		g - exponential distribution 
%

network = getenv('network'); 

font_size = 20;
line_width = 3; 

consts = konect_consts(); 

data = load(sprintf('dat/hopdistr2.%s', network))
info = read_info(network); 

%nn = floor(sqrt(data(end)))

datan = data
%datan = [nn ; data]

yvalues = datan / max(data); 

%
% Effective diameters
%
de9 = konect_diameff(data, 0.9)
de5 = konect_diameff(data, 0.5)
dm  = konect_diammean(data)

%
% a - Normal plot 
%

hold on; 

plot(0:(length(data)-1), 100 * yvalues, '-', 'LineWidth', line_width / 4, ...
     'Color', [0 0 0]);
stairs(0:(length(data)-1), 100 * yvalues, '-', 'LineWidth', line_width, ...
       'Color', [0 0 1]);

xlabel('Distance (d) [edges]', 'FontSize', font_size);
ylabel('Cumulative distribution (P(x \geq d))', 'FontSize', font_size); 

set(gca, 'FontSize', font_size); 
set(gca, 'YGrid', 'on'); 

% Add percents to Y labels
yticks = [get(gca,'ytick')]';
percentsy = repmat('%', length(yticks),1);
yticklabel = [num2str(yticks) percentsy];
set(gca,'yticklabel',yticklabel)

if length(data) <= 8
    set(gca, 'XTick', 0 : length(data)); 
    for i = 0 : length(data)
        labels(1+i) = cellstr(sprintf('%d', i)); 
    end
    set(gca, 'XTickLabel', labels); 
else
    set(gca, 'XMinorTick', 'on');
end

set(gca, 'TickLength', [0.05 0.05]); 


datax = [data(2:end) ; data(end)]; 
line([de9 de9], [0, (datan(1+floor(de9)) + (de9 - floor(de9)) * (datax(1+floor(de9)) - datan(1+floor(de9)))) * 100 / data(end)], ...
     'LineStyle', '-', 'Color', [0.8 0 0], 'LineWidth', line_width * 2 / 3);
line([de5 de5], [0, (datan(1+floor(de5)) + (de5 - floor(de5)) * (datax(1+floor(de5)) - datan(1+floor(de5)))) * 100 / data(end)], ...
     'Linestyle', '-', 'Color', [0.8 0 0], 'LineWidth', line_width * 2 / 3);
line([dm  dm ], [0, 100], ...
     'Linestyle', '--', 'Color', [0 0.8 0], 'LineWidth', line_width * 2 / 3);

% Axis
ax = axis()
ax(1) = 0;
ax(2) = length(data)+1; 
ax(3) = 0;
ax(4) = 100;
axis(ax); 

% Text

xx = ax(1)+0.75*(ax(2)-ax(1))

yy = ax(3)+0.23*(ax(4)-ax(3))
text(xx, yy, ...
     sprintf('\\delta_{0.9} = %.2f', de9), ...
     'FontSize', font_size); 
yy = ax(3)+0.33*(ax(4)-ax(3))
text(xx, yy, ...
     sprintf('\\delta_{0.5} = %.2f', de5), ...
     'FontSize', font_size); 
yy = ax(3)+0.43*(ax(4)-ax(3))
text(xx, yy, ...
     sprintf('\\delta_m = %.2f', dm), ...
     'FontSize', font_size); 


konect_print(sprintf('plot/hopdistr.a.%s.eps', network)); 

%
% b - Logistic plot
%
plot(0:(length(data) - 1), -log(1 ./ yvalues - 1), 'go-', 'LineWidth', line_width);

xlabel('Distance (d) [edges]', 'FontSize', font_size);
ylabel('Logistic (-log(1 / H(d) - 1))', 'FontSize', font_size); 

set(gca, 'FontSize', font_size); 

set(gca, 'YGrid', 'on'); 

% Axis
ax = axis()
ax(1) = 0;
ax(2) = length(data)+1; 
axis(ax); 

konect_print(sprintf('plot/hopdistr.b.%s.eps', network)); 

%
% c - Tangent
%
plot(0:(length(data)-1), tan((yvalues + pi/2) / pi), 'ro-', 'LineWidth', line_width);

xlabel('Distance (d) [edges]', 'FontSize', font_size);
ylabel('Tangent (tan((H(d) + \pi / 2) / \pi))', 'FontSize', font_size); 

set(gca, 'FontSize', font_size); 

set(gca, 'YGrid', 'on'); 

% Axis
ax = axis()
ax(1) = 0;
ax(2) = length(data)+1; 
axis(ax); 

konect_print(sprintf('plot/hopdistr.c.%s.eps', network)); 

%
% d - Artanh
%
plot(0:(length(data)-1), 0.5 * log((yvalues + 3) / (1 - yvalues)), 'k-', 'LineWidth', line_width);

xlabel('Distance (d) [edges]', 'FontSize', font_size);
ylabel('Artanh (1/2 * log((H(d) + 3) / (1 - H(d))))', 'FontSize', font_size); 

set(gca, 'FontSize', font_size); 

set(gca, 'YGrid', 'on'); 

% Axis
ax = axis()
ax(1) = 0;
ax(2) = length(data)+1; 
axis(ax); 

konect_print(sprintf('plot/hopdistr.d.%s.eps', network)); 

%
% e - Inverse error function
%
plot(0:(length(data)-1), erfinv(2 * yvalues - 1), 'mo-', 'LineWidth', line_width);

xlabel('Distance (d) [edges]', 'FontSize', font_size);
ylabel('Normal (erfinv(2 H(d) - 1))', 'FontSize', font_size); 

set(gca, 'FontSize', font_size); 

set(gca, 'YGrid', 'on'); 

% Axis
ax = axis()
ax(1) = 0;
ax(2) = length(data)+1; 
axis(ax); 

konect_print(sprintf('plot/hopdistr.e.%s.eps', network)); 

%
% f - Weibull
%
loglog(0:(length(data)-1), -log(1-yvalues), 'co-', 'LineWidth', line_width);

xlabel('Distance (d) [edges]', 'FontSize', font_size);
ylabel('Weibull (-log(1 - H(d)))', 'FontSize', font_size); 

set(gca, 'FontSize', font_size); 
set(gca, 'YGrid', 'on'); 

% Axis
ax = axis()
ax(1) = 0;
ax(2) = length(data)+1; 
axis(ax); 

konect_print(sprintf('plot/hopdistr.f.%s.eps', network)); 


%
% g - exponential
%

semilogy(0:(length(data)-1), yvalues, 'o-', 'Color', [1 (140/255) 0], 'LineWidth', ...
         line_width);

xlabel('Distance (d) [edges]', 'FontSize', font_size); 
ylabel('H(d)', 'FontSize', font_size);

set(gca, 'FontSize', font_size);
set(gca, 'YGrid', 'on');

% Axis
ax = axis()
ax(1) = 0;
ax(2) = length(data)+1; 
axis(ax); 

konect_print(sprintf('plot/hopdistr.g.%s.eps', network)); 
