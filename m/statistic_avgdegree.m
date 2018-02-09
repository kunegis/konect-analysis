%
% Compute the average degree statistic of a network. 
%
% PARAMETERS 
%	$network 
%
% INPUT 
%	dat/statistic.volume.$network
%	dat/statistic.size.$network 
%	dat/statistic.format.$network 
%
% OUTPUT 
%	dat/statistic.avgdegree.$network
%		The meaning of the values is the same as that described
% 		in konect-toolbox/m/konect_statistic_avgdegree.m 
%

network = getenv('network');

consts = konect_consts(); 

format long; 

values_m = load(sprintf('dat/statistic.volume.%s', network)); 
m = values_m(1); 

values_n = load(sprintf('dat/statistic.size.%s', network)); 
n= values_n(1); 

values= 2 * m / n; 

value_format = load(sprintf('dat/statistic.format.%s', network)); 

if value_format == consts.BIP

    assert(length(values_n) == 3); 

    n1= values_n(2);
    n2= values_n(3); 

    assert(n == n1 + n2); 

    values(2) = m / n1;
    values(3) = m / n2;

elseif value_format == consts.SYM || value_format == consts.ASYM

    assert(length(values_n) == 1); 

else
    
    error('*** invalid format'); 

end

values = values';

save(sprintf('dat/statistic.avgdegree.%s', network), 'values', ...
     '-ascii', '-double'); 

