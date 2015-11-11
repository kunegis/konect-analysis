%
% Get information about one dataset.
%
% DEPRECATED - instead, load individual statistics from dat/statistic.$STATISTIC.$NETWORK
%
% RESULT 
%	A struct with the following fields
%		
%		n1,n2		Number of left/right nodes equal in
%				unipartite networks
%		n		Total number of edges
%		lines		Number of edges, but mot counting
%				multiple edges when they are
%				aggregated
%		rmn_		= r / (m*n)  [deprecated]
%		format		as a number (see constants.m)
%		weights		as a number (see constants.m)
%
% PARAMETERS 
%	network		Dataset name
%

function info = read_info(network)

network

info_data = load(sprintf('dat/info.%s', network));

consts = konect_consts(); 

info= struct(); 

info.n1 = 	info_data(1);
info.n2 = 	info_data(2); 
info.lines = 	info_data(3);
info.rmn_ = 	info_data(4); 
info.format = 	info_data(5); 
info.weights = 	info_data(6); 

if info.format == consts.BIP
    info.n = sum(info_data(1:2));
else
    assert (info_data(1) == info_data(2)); 
    info.n = info_data(1);
end
