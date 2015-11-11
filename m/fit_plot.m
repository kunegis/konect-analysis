%
% Plot curve fitting.
%
% PARAMETERS 
%	$NETWORK
%	$DECOMPOSITION
%
% INPUT 
%	dat/fit.$DECOMPOSITION.$NETWORK.mat
%
% OUTPUT 
%	plot/fit.[ab].$DECOMPOSITION.$NETWORK.eps
%

network = getenv('NETWORK');
decomposition = getenv('DECOMPOSITION');

font_size = 18; 

fit = load(sprintf('dat/fit.%s.%s.mat', decomposition, network)); 

a = fit.a;
d = fit.d; 

% In complex decompositions, show the absolute values
if ~isreal(a) | ~isreal(d)

  a_show = real(a); 
  d_show = real(d); 

else
  a_show = a;
  d_show = d
end

%
% (b) Bare plot
% 

plot(a_show, d_show, 'ok');

gridxy([0], [0], 'LineStyle', '--');

xlabel('Eigenvalue (\lambda_k)', 'FontSize', font_size); 
ylabel('New eigenvalue (f(\lambda_k))', 'FontSize', font_size); 
set(gca, 'FontSize', font_size); 

konect_print(sprintf('plot/fit.b.%s.%s.eps', decomposition, network)); 

%
% (a) With curves
%

[colors line_styles markers] = styles_submethod(); 

hold on; 

plot(a_show, d_show, 'ok');

ax = axis(); 

mi = ax(1);
ma = ax(2); 
		
curves = fieldnames(fit.curves) 
handles = []; 
legends = [];
for i = 1 : length(curves)
  curve = curves{i}
  values = fit.curves.(curve)

  if strcmp(curve, 'like'), continue; end; 

  h = fit_plot_curve(curve, mi, ma, a, values, colors.(curve), line_styles.(curve), fit.pivot);

  handles = [handles h]; 
  legends = [legends cellstr(curve)]; 
end

gridxy([0], [0], 'LineStyle', '--');

xlabel('Eigenvalue (\lambda_k)', 'FontSize', font_size); 
ylabel('New eigenvalue (f(\lambda_k))', 'FontSize', font_size); 

set(gca, 'FontSize', font_size); 

axis(ax); 

legend(handles, legends, 'Location', 'EastOutside'); 

konect_print(sprintf('plot/fit.a.%s.%s.eps', decomposition, network)); 
