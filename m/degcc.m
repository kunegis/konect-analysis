%
% For one network, scatter plot of degree vs local clustering coefficient.
% 
% PARAMETERS 
%	$NETWORK
%
% INPUT 
%	dat/feature.degree.$NETWORK.mat
%	dat/cluscod.$NETWORK.mat
%
% OUTPUT 
%	plot/degcc.{a}.$NETWORK.eps
%

network = getenv('NETWORK');

feature = load(sprintf('dat/feature.degree.%s.mat', network));  feature = feature.feature; 
cluscod = load(sprintf('dat/cluscod.%s.mat', network)); 

hold on; 

x = feature.a;
y = cluscod.c_local; 

i = find(x > 0);
x = x(i);
y = y(i); 

plot(x, y, '.'); 

xlabel('Degree');
ylabel('Local clustering coefficient'); 

n = max(x); 

clusco_count = sparse(x, 1, 1); 
clusco_sum   = sparse(x, 1, y);
clusco_sq    = sparse(x, 1, y .^ 2); 

plot(1:n, clusco_sum ./ clusco_count, '+-', 'Color', [1 0 0]); 

set(gca, 'XScale', 'log', 'YScale', 'log'); 

konect_print(sprintf('plot/degcc.a.%s.eps', network));


% df sfd
% alkjdlajdlakjsd
%ccc