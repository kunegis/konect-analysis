UNUSED

%
% Compute the density statistic of a network. 
%
% PARAMETERS 
%	$NETWORK 
%
% OUTPUT 
%	dat/statistic_full.density.$NETWORK
%
% INPUT 
%	dat/info.$NETWORK
%

network = getenv('NETWORK');

info = read_info(network); 

consts = konect_consts(); 

if info.format == consts.BIP

    values = [ 2 * info.m_ / (info.n1 + info.n2)  ; info.m_ / info.n1 ; info.m_ / info.n2 ]; 

else

    % TODO There is a bug here:  for ASYM networks, we should also output
    % the out/in-density. 

    values = [ 2 * info.m_ / info.n1 ]; 

end

save(sprintf('dat/statistic_full.density.%s', network), 'values', '-ascii'); 
