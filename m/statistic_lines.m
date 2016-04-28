%
% Compute the number of lines in the definition of a network, i.e.,
% the number of lines in the out.* file.  This is different from the
% volume for networks with multiple edges without timestamps, because
% these networks aggregate multiple edges into one line. 
%
% PARAMETERS 
%	$network 
%
% INPUT 
%	dat/info.$network
%
% OUTPUT 
%	dat/statistic.lines.$network
%

network = getenv('network');

info = read_info(network); 

consts = konect_consts(); 

values = [ info.lines ]; 

save(sprintf('dat/statistic.lines.%s', network), 'values', '-ascii'); 
