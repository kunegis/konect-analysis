%
% Draw one fitting curve. 
%
% PARAMETERS 
%	curve	Name of curve
%	mi,ma	Min and max values on the X axis to draw
%	a	Eigenvalues on X axis
%	values	Parameters of the curve; column vector as generated in fit.m 
%	color,line_style	To be used for plotting; no markers shall be used 
%	pivot
%
% RESULT 
%	h	Handle of drawn plot 
%

function [h] = fit_plot_curve(curve, mi, ma, a, values, color, line_style, pivot)

granularity = 0.01; 

marker = 'none'; 

range = mi : granularity * (ma - mi) : ma; 

if strcmp(curve, 'lin')

    h = line([mi ma], values(1) * [mi ma], [1 1]); 

elseif strcmp(curve, 'poly') | strcmp(curve, 'polyn') | strcmp(curve, 'polyx')

    h = plot(range, pivot * polyval(values(end:-1:1), range/pivot)); 

elseif strcmp(curve, 'polyo') | strcmp(curve, 'polyon')

    v = zeros(2 * prod(size(values)), 1);
    v(end-1:-2:1) = values
    h = plot(range, pivot * polyval(v, range/pivot)); 
      
elseif strcmp(curve, 'exp')

    h = plot(range, pivot * values(2) * exp(values(1) * range / pivot)); 

elseif strcmp(curve, 'expo')

    h = plot(range, pivot * values(2) * sinh(values(1) * range / pivot)); 

elseif strcmp(curve, 'expnl')

    h = plot(range, pivot * values(2) * exp(-values(1) * (1 - range / pivot))); 

elseif strcmp(curve, 'rat')

    h = plot(range, pivot * values(2) ./ (1 - values(1) * range / pivot)); 

elseif strcmp(curve, 'rato')

    h = plot(range, pivot * values(2) * values(1) * (range / pivot) ./ (1 - values(1)^2 * ((range / pivot) .^ 2))); 

elseif strcmp(curve, 'rr')

    cutoff = abs(a(values(2))); 
    h = line([mi cutoff cutoff ma], [0 0 (cutoff*values(1)) (ma * values(1))]); 

elseif strcmp(curve, 'rrs')

    cutoff = abs(a(values(2))); 
    h = line([mi (-cutoff) (-cutoff) cutoff cutoff ma], ...
             [(mi * values(1)) (-cutoff * values(1)) 0 0 (cutoff * values(1)) (ma * values(1))]); 

elseif strcmp(curve, 'rrl')

    cutoff = abs(a(values(2))); 
    rangex = range(range < cutoff);
    h = plot(rangex, pivot^2 * values(1) ./ rangex); 
    set(h, 'LineStyle', line_style, 'Marker', marker, 'Color', color); 

    h = line([cutoff cutoff ma], [(pivot^2/cutoff) 0 0]); 

elseif strcmp(curve, 'ratn')
 
    h = plot(range, values(1) ./ (1 - range)); 

elseif strcmp(curve, 'ratno')
 
    h = plot(range, values(1) * range ./ (1 - range.^2)); 

elseif strcmp(curve, 'uni')

    h = plot(range, values(1) * (1 + (range.^-1 -1) .* log(ones(size(range)) - range)) ./ range); 

elseif strcmp(curve, 'lap')

    h = plot(range, values(1) * pivot ./ (range / pivot)); 

elseif strcmp(curve, 'ratl')

    h = plot(range, values(2) * pivot ./ (1 + values(1) * range / pivot)); 

elseif strcmp(curve, 'expl')

    h = plot(range, pivot * values(2) * exp(- values(1) * range / pivot)); 

elseif strcmp(curve, 'polyl')

    h = plot(range, pivot * polyval(values(end:-1:1), pivot ./ range)); 

elseif strcmp(curve, 'polynl')

    h = plot(range, pivot * polyval(values(end:-1:1), pivot ./ range)); 

else
  
    error(sprintf('*** Invalid curve %s', curve)); 
end

set(h, 'LineStyle', line_style, 'Marker', marker, 'Color', color); 

