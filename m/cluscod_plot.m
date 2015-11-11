%
% Plot the clustering coefficient degree distribution.
%
% PARAMETERS 
%	$NETWORK
%
% INPUT 
%	dat/cluscod.$NETWORK.mat
%
% OUTPUT 
%	plot/cluscod.[a].$NETWORK.eps
%

network = getenv('NETWORK');

font_size = 22; 
line_width = 3; 

data = load(sprintf('dat/cluscod.%s.mat', network)); 

c_local = data.c_local;

F = cdfplot(c_local);

set(F, 'LineWidth', line_width);

axis([0 1 0 1]); 

title(''); 
xlabel('Local clustering coefficient (c)', 'FontSize', font_size); 
ylabel('P(x \leq c)', 'FontSize', font_size); 

set(gca, 'FontSize', font_size); 

konect_print(sprintf('plot/cluscod.a.%s.eps', network)); 
