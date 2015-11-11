%
% Plot a distribution in Beta style. 
%
% PARAMETERS 
%	values			(n*1) Values; must all be larger than zero
%	color			(optional) Color of the line
%

function beta_plot(values, color)

if ~exist('color', 'var')
    color = [0 0 1]; 
end

font_size = 24; 

[counts ids] = sort(values); 

maxcount = counts(end);
freq = histc(counts, 0 : maxcount); 

nz = freq ~= 0; 
x = 0 : maxcount; 
x = x(nz);
y = freq(nz); 

hold on; 
loglog(x / sum(values), y / length(values), '+', 'Color', color);

set(gca, 'XScale', 'log', 'YScale', 'log'); 

ax = axis()

[phat pci] = betafit(values / sum(values)) 

N = 200;
xx = exp(log(ax(1)) + (0:1:N) / N * (log(ax(2)) - log(ax(1)))); 

yy = xx .^ (phat(1) - 1) .* (1 - xx) .^ (phat(2) - 1) / beta(phat(1), phat(2)) / sum(values); 

plot(xx, yy, '-');

axis(ax); 

%n = 50;
%hist(values / sum(values), (1 / (2 * n)) : (1 / n) : (1 - 1 / (2 * n)));
%axis([0 1 0 (sum(values) / n)]); 

set(gca, 'FontSize', font_size); 

set(gca, 'XMinorTick', 'on');
set(gca, 'YMinorTick', 'on'); 
set(gca, 'TickLength', [0.05 0.05]); 

% Workaround for Matlab bug. Otherwise, the minor ticks are not visible. 
ax = axis(); 
if ax(1) > 0 & ax(3) > 0 
    set(gca, 'XTick', 10 .^ (ceil(log(ax(1)) / log(10)):floor(log(ax(2)) / log(10)))); 
    set(gca, 'YTick', 10 .^ (ceil(log(ax(3)) / log(10)):floor(log(ax(4)) / log(10)))); 
end

