%
% Apply a spectral transformation to a central matrix. 
%
% PARAMETERS 
%	d	(r*r) Central matrix
%	curve	Name of curve to apply
%	values	Parameters of the curve
%
% RESULT 
%	d_new	(r*r) New central matrix 
%

function [d_new] = curve_apply(d, curve, values, data_decomposition)

r = size(d,1); 

pivot = pivotize(data_decomposition, d); 

if strcmp(curve, 'exp')

    d_new = pivot * values(2) * expm(values(1) * d / pivot);

elseif strcmp(curve, 'expo')

    d_new = pivot * values(2) * 0.5 * (expm(values(1) * d / pivot) + expm(- values(1) * d / pivot)); 

elseif strcmp(curve, 'expl')

    d_new = pivot * values(2) * expm(- values(1) * d / pivot); 

elseif strcmp(curve, 'expnl')

    d_new = pivot * values(2) * expm(- values(1) * (eye(size(d,1)) - d / pivot)); 

elseif strcmp(curve, 'poly') | strcmp(curve, 'polyn') | strcmp(curve, 'polyx')

    d_new = zeros(size(d,1));
    dk = eye(size(d,1));
    for k = 1 : length(values)
        if k > 1, dk = d * dk / pivot; end
        d_new = d_new + values(k) * dk;     
    end
    d_new = pivot * d_new; 

elseif strcmp(curve, 'polyo') | strcmp(curve, 'polyon') 

    d_new = zeros(size(d,1)); 
    dk = d / pivot;
    for k = 1:length(values)
        if k > 1, dk = dk * d * d / (pivot^2); end
        d_new = d_new + values(k) * dk;
    end
    d_new = pivot * d_new;   

elseif strcmp(curve, 'polyl') | strcmp(curve, 'polynl')

    d = pinv(d / pivot); 
    d_new = zeros(size(d,1));
    dk = eye(size(d,1));
    for k = 1 : length(values)
        if k > 1, dk = d * dk; end
        d_new = d_new + values(k) * dk;
    end
    d_new = pivot * d_new; 

elseif strcmp(curve, 'rr')

    cutoff = d(r,r);
    i = diag(d) >= cutoff;
    r_new = sum(i);
    d_new = zeros(size(d));
    d_new(1:r_new, 1:r_new) = values(1) * d(i,i); 

elseif strcmp(curve, 'rrs')

    r = values(2);
    d_new = zeros(size(d)); 
    d_new(1:r, 1:r) = values(1) * d(1:r, 1:r); 

elseif strcmp(curve, 'rrl')

    r = values(2)
    size_d = size(d) 
    d_new = zeros(size(d));
    d_new(1:r, 1:r) = values(1) * pinv(d(1:r, 1:r));

elseif strcmp(curve, 'lap')

    d_new = pivot * values(1) * pinv(d / pivot); 

elseif strcmp(curve, 'rat')

    d_new = pivot * values(2) * inv(eye(size(d,1)) - values(1) * d / pivot); 

elseif strcmp(curve, 'ratn')

    d_new = pivot * values(1) * pinv(eye(size(d,1)) - d / pivot); 

elseif strcmp(curve, 'ratno')

    d_new = values(1) * d * pinv(eye(size(d,1)) - d * d / (pivot^2)); 

elseif strcmp(curve, 'rato')

    d_new = values(1) * values(2) * d * inv(eye(size(d,1)) - values(1)^2 * d * d / (pivot^2)); 
    
elseif strcmp(curve, 'ratl')

    d_new = pivot * values(2) * inv(eye(size(d,1)) + values(1) * d / pivot); 

elseif strcmp(curve, 'like')

    if length(values) > size(d,1)
        values = values(1:size(d,1));
    elseif length(values < size(d,1))
        size_values = size(values) 
        values = [ values; zeros(size(d,1) - length(values), 1) ]; 
    end

    d_new = diag(values);  

elseif strcmp(curve, 'lin')

    d_new = values(1) * d; 

elseif strcmp(curve, 'uni')

    d_new = pivot * values(1) * (eye(size(d,1)) + (pinv(d / pivot) - eye(size(d,1))) * log(eye(r) - d / pivot) * pinv(d / pivot)); 

else 
    error(sprintf('*** Invalid curve %s', curve)); 
end
