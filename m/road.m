DEPRECATED - superceded by map.m and layout.m

%
% Plot a road network. 
% 
% ENVIRONMENT 
%	$NETWORK		Dataset name
%
% OUTPUT 
%	plot/road.$NETWORK.eps
%
% INPUT 
%	uni/out.$NETWORK
%

network = getenv('NETWORK'); 

at = load(sprintf('uni/out.%s', network)); 

info = read_info(network); 

a = konect_spconvert(at, info.m, info.n); 

v = konect_connect_square(a); 

a = a(v,v); 

opts.disp = 2; 

[u,d] = konect_decomposition('lap', a, 3, info.format, info.weights, opts); 

d 

gplot2(a, u(:,2:3));

print(sprintf('plot/road.%s.eps', network), '-depsc'); close all; 

