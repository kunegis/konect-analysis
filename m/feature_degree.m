
DEPRECATED - now computed in C. 

%
% Compute the "degree" feature
%
% PARAMETERS 
%	$NETWORK
%
% INPUT 
%	dat/info.$NETWORK
%	dat/data.$NETWORK.mat
%
% OUTPUT 
%	dat/feature.degree.$NETWORK.mat
%		.feature, containing: 
%			.a	Degrees	(SYM and ASYM)
%			.u	Outdegrees (ASYM), Left degrees (BIP)
%			.v	Indegrees (ASYM), Right degrees (BIP) 
%

network = getenv('NETWORK');

consts = konect_consts(); 

info = read_info(network); 

data = load(sprintf('dat/data.%s.mat', network));

feature = {}; 

if info.format == consts.SYM | info.format == consts.ASYM

    feature.a = full(sparse(data.T(:,1), 1, 1, info.n1, 1) + sparse(data.T(:,2), 1, 1, info.n1, 1));

end

if info.format == consts.ASYM | info.format == consts.BIP

    feature.u = full(sparse(data.T(:,1), 1, 1, info.n1, 1));
    feature.v = full(sparse(data.T(:,2), 1, 1, info.n2, 1)); 

end

save(sprintf('dat/feature.degree.%s.mat', network), 'feature', '-v7.3'); 
