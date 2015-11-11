%
% Compute the number of lines in the definition of a network, i.e.,
% the number of lines in the out.* file.  This is different from the
% volume for networks with multiple edges without timestamps, because
% these networks aggregate multiple edges into one line. 
%
% PARAMETERS 
%	$NETWORK 
%
% INPUT 
%	dat/info.$NETWORK
%
% OUTPUT 
%	dat/statistic.lines.$NETWORK
%

network = getenv('NETWORK');

info = read_info(network); 

consts = konect_consts(); 

values = [ info.lines ]; 

save(sprintf('dat/statistic.lines.%s', network), 'values', '-ascii'); 
