%
% Plot the plots for one PA variant. 
%
% PARAMETERS 
%	network
%	letter		For output filename
%	pa_x		Curve fitting values (see pa_compute_one)
%	pa_data_x	Plotting data (see pa_compute_one) 
%
% OUTPUT 
%	plot/pa.[a...][letter].[network].eps	
%

function pa_plot_one(network, letter, pa_x, pa_data_x)

network
letter

font_size = 18; 

%
% [h] Cumulative distribution
%
loglog(pa_data_x.xx, cumsum(pa_data_x.yy), '-');

konect_print(sprintf('plot/pa.h%s.%s.eps', letter, network)); 

%
% [d] Non-cumulative; Q-Q plot 
%
s_1 = sort(pa_data_x.d_1);
s_2 = sort(pa_data_x.d_2);

loglog(s_1, s_2, '-'); 

konect_print(sprintf('plot/pa.d%s.%s.eps', letter, network)); 

%
% [i] stddev in function of degree
%

semilogx(pa_data_x.xx, pa_data_x.yy_dev, '-');
xlabel('Degree (d)');
ylabel('stddev'); 
konect_print(sprintf('plot/pa.i%s.%s.eps', letter, network)); 

%
% [k] - Separate fit 
%

% Size of lower and upper error bar 
yy_l = (pa_data_x.yy_geo_orig) .* (1 - pa_data_x.yy_dev_geo .^ -1);
yy_u = (pa_data_x.yy_geo_orig) .* (pa_data_x.yy_dev_geo - 1);

yy_l_begin = yy_l(1:10)
yy_u_begin = yy_u(1:10)

hold on; 
errorbar(pa_data_x.xx, pa_data_x.yy_geo_orig, yy_l, yy_u, '+');
set(gca, 'XScale', 'log', 'YScale', 'log'); 
ax = axis()

xlabel('Regularized degree at time t_1 (1 + d_1(u))', 'FontSize', font_size); 
ylabel('Regularized number of new edges (\lambda + d_2(u))', 'FontSize', font_size); 

% Fitted lines
x_begin = 1
x_end = pa_data_x.xx(end)

y_begin = exp(pa_x.e(2) + pa_x.e(1) * log(x_begin))
y_end   = exp(pa_x.e(2) + pa_x.e(1) * log(x_end  ))
line([x_begin, x_end], [y_begin, y_end], 'Color', [0 1 0], 'Linewidth', 3); 

% Invisible line to add the "RMSE" text to the legend 
line([ax(3) ax(3)], [ax(4) ax(4)], 'Color', [1 1 1]); 

% y_begin = exp(pa_x.f(2) + pa_x.f(1) * log(x_begin))
% y_end   = exp(pa_x.f(2) + pa_x.f(1) * log(x_end  ))
% line([x_begin, x_end], [y_begin, y_end], 'Color', [0 0 1]); 

% y_begin = exp(pa_x.g(2) + pa_x.g(1) * log(x_begin))
% y_end   = exp(pa_x.g(2) + pa_x.g(1) * log(x_end  ))
% line([x_begin, x_end], [y_begin, y_end], 'Color', [1 0 0]); 

axis(ax); 

legend({ 'Data', ...
         sprintf('%.4f * x^{%.4f}', exp(pa_x.e(2)), pa_x.e(1)), ...
         sprintf('\\epsilon = %.4f', exp(sqrt(pa_x.e(3)))), ...
%          sprintf('%.4f * x^{%.4f} (first 10)', exp(pa_x.f(2)), pa_x.f(1)), ...
%          sprintf('%.4f * x^{%.4f} (last 99%%)', exp(pa_x.g(2)), pa_x.g(1)), ...
       }, ...
       'Location', 'NorthWest'); 

set(gca, 'FontSize', font_size); 

set(gca, 'XMinorTick', 'on');
set(gca, 'YMinorTick', 'on'); 
set(gca, 'TickLength', [0.05 0.05]); 

konect_print(sprintf('plot/pa.k%s.%s.eps', letter, network)); 

%
% [a]
%


N = min(1000, length(pa_data_x.d_1));
ii = randperm(length(pa_data_x.d_1));

loglog(pa_data_x.d_1(ii(1:N)) + pa_x.lambda_1, pa_data_x.d_2(ii(1:N)), '.'); 
xlabel('Degree of node in old graph');
ylabel('Degree of node in new graph');
konect_print(sprintf('plot/pa.a%s.%s.eps', letter, network)); 


