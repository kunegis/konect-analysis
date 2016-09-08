%
% For one network, scatter plot of degree vs local clustering coefficient.
% 
% PARAMETERS 
%	$network
%
% INPUT FILES 
%	dat/cluscod.$network.mat
%	uni/out.$network
%
% OUTPUT FILES 
%	plot/degcc.{a}.$network.eps
%

network = getenv('network');

consts = konect_consts(); 

weights = read_statistic('weights', network);
weights = weights(1)
forma = read_statistic('format', network);
forma = forma(1)
n     = read_statistic('size', network); 
n     = n(1); 

T = load(sprintf('uni/out.%s', network)); 

x = [T(:,1) ; T(:,2)];

if weights == consts.POSITIVE
    w = [ T(:,3) ; T(:,3) ]; 
else
    w = 1;
end

degrees = sparse(x, 1, w, n, 1); 

cluscod = load(sprintf('dat/cluscod.%s.mat', network)); 

hold on; 

x = degrees;
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
