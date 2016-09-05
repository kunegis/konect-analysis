%
% Compute the 'prefatt' statistic (preferential attachment exponent),
% by reading the 'dat/pa.%.mat' files. 
%
% We only compute this for temporal networks, even though
% non-temporal networks also have a SPLIT.  
%
% PARAMETERS 
%	$network
%
% INPUT FILES
%	dat/pa.$network.mat
%
% OUTPUT FILES
% 	dat/statistic.prefatt.$network
%		[1] normal \beta
%		[2] normal mse
%		[3] long-tail \beta
%		[4] long-tail mse
%

function statistic_full_prefatt

network = getenv('network'); 

if has_timestamps(network)

    pa = load(sprintf('dat/pa.%s.mat', network))
    pa.pa.a

    % Take V if it exists, because it is the 'passive' side.
    % Otherwise take A. 
    if isfield(pa.pa, 'v')
        values = get_values(pa.pa.v); 
    else
        values = get_values(pa.pa.a); 
    end

else

    values = [ NaN ; NaN ; NaN ; NaN ];

end

% The values are a column vector 
[m n] = size(values);
assert(n == 1); 

save(sprintf('dat/statistic.prefatt.%s', network), 'values', '-ascii'); 

end

function [ret] = get_values(vect)

ret = [ NaN ; NaN ; NaN ; NaN ]; 

ret(1) = vect.e(1);

if ret(1) > 0
    ret(2) = exp(sqrt(vect.e(3))); 
else 
    ret(2) = NaN;
end

ret(3) = vect.g(1);

if ret(3) > 0
    ret(4) = exp(sqrt(vect.g(3))); 
else
    ret(3) = NaN; 
end

end
