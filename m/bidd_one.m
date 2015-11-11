%
% Plot one BIDD curve.
%
% PARAMETERS 
%	p	(e*1) Node indexes
%	q	(e*1) Multiplicities; [] to denote all ones
%	enable_normalization	Enable division with degree sum
%	type
%	name
%	symbol
% 

function bidd_one(p, q, enable_normalization, type, name, symbol)

colors = konect_colors_letter(); 

font_size = 24; 

if length(q) == 0, q = 1; end
degrees = full(sparse(p, 1, q, max(p), 1)); 
degrees = degrees(find(degrees));

konect_power_law_plot(degrees, [], enable_normalization, colors.(type)); 

if enable_normalization
    xlabel(sprintf('Relative %s (%s / D)', name, symbol), 'FontSize', font_size);
    ylabel(sprintf('P(x \\geq %s / D)', symbol), 'FontSize', font_size); 
else
    xlabel(sprintf('%s (%s) [vertices]', name, symbol), 'FontSize', font_size);
    ylabel(sprintf('P(x \\geq %s)', symbol), 'FontSize', font_size); 
end
