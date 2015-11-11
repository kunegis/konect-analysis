%
% Plot one BETA curve.
%
% PARAMETERS
%	p	(e*1) Node indexes
%	q	(e*1) Multiplicities; [] to denote all ones
%	enable_normalization	Enable division with degree sum
%	type
% 

function beta_one(p, q, type)

colors = konect_colors_letter(); 

font_size = 24; 

if length(q) == 0, q = 1; end
degrees = full(sparse(p, 1, q, max(p), 1)); 
degrees = degrees(find(degrees));

beta_plot(degrees, colors.(type)); 

xlabel('Relative degree (d / D)', 'FontSize', font_size);
ylabel('P(x = d / D)', 'FontSize', font_size); 

