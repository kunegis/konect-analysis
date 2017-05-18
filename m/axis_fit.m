%
% Return suitable values for the parameters of axis() given the
% range. 
%
% Given X axis values, it returns values of axis(1) and axis(2).
% Given Y axis values, it returns values of axis(3) and axis(4).
%
% PARAMETERS 
%	x	(n*1) Values to be plotted
%	is_log	(0/1) Whether a logarithmic axis is used 
%
% RESULTS 
%	ret	(1*2) Min/max values to be passed to axis()
%

function ret = axis_fit(x, is_log)

is_log

offset = 0.1; 

% When the axis is logarithmic, there cannot be nonpositive values 
%% assert((~is_log) | sum(x <= 0) == 0); 

% Filter out nonpositive values when is_log
if is_log
    'filter'
    ii = find(x > 0);
    x = x(ii); 
end

xi = min(x); 
xa = max(x); 

if is_log
    dx = log(xa) - log(xi); 
    if dx == 0
        dx = 1; 
    end;
    ret = [ (exp(log(xi) - offset * dx)) exp(log(xa) + offset * dx) ];
else
    dx = xa - xi;
    if dx == 0
        dx = 1;
    end;
    ret = [ (xi - offset * dx) (xa + offset * dx) ]; 
end
