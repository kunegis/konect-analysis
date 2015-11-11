%
% Compute the 'prefatt' statistic, by reading the dat/pa.%.mat
% files. 
%
% We only compute this for temporal networks, even though
% non-temporal networks also have a SPLIT. 
%
% PARAMETERS 
%	$NETWORK
%
% INPUT 
%	dat/pa.$NETWORK.mat
%
% OUTPUT 
% 	dat/statistic.prefatt.$NETWORK
%		[1] normal \beta
%		[2] normal mse
%		[3] long-tail \beta
%		[4] long-tail mse
%

network = getenv('NETWORK'); 

if has_timestamps(network)

    pa = load(sprintf('dat/pa.%s.mat', network)); 

    % Take V if it exists, because it is the 'passive' side.
    % Otherwise take A. 
    if isfield(pa.pa, 'v')
        values = [ pa.pa.v.e(1); exp(sqrt(pa.pa.v.e(3))); pa.pa.v.g(1); exp(sqrt(pa.pa.v.g(3))) ];
    else
        tmp1 = pa.pa.a.e(1)
        tmp2 = pa.pa.a.g(3)
        values = [ pa.pa.a.e(1); exp(sqrt(pa.pa.a.e(1))); pa.pa.a.g(1); exp(sqrt(pa.pa.a.g(3))) ]; 
    end

else

    values = [ NaN ; NaN ; NaN ; NaN ];

end

save(sprintf('dat/statistic.prefatt.%s', network), 'values', '-ascii'); 
