% 
% The key used for sorting datasets. 
%
% PARAMETERS 
%	network 
%

function ret = network_key(metadata)

name = metadata.name; 

name_no_space = regexprep(name, ' ', '-'); 

ret = sprintf('%s:%s', metadata.category, name_no_space); 

