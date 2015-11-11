
UNUSED

%
% Plot the briclo (bridging vs closing) plots. 
%
% PARAMETERS 
%	$NETWORK
%
% INPUT 
%	dat/briclo.$NETWORK
%
% OUTPUT 
%	plot/briclo.$NETWORK.eps
%

network = getenv('NETWORK'); 

slices = 100; 

a = load(sprintf('dat/briclo.%s', network)); 

n = size(a,1); 

froms = floor(((1:slices)-1) * n / slices + 1);
tos = [froms(2:end) + 1, n]; 

size_a = size(a)
size_froms = size(froms)
size_tos = size(tos)


for i = 1 : slices
    counts(i) = sum(a(froms(i) : tos(i))); 		 
    sums(i)   = tos(i) - froms(i) + 1; 
end

xx = (froms + tos) / 2; 
yy = counts ./ sums; 

area(xx, yy); 

ax = axis();
ax(3) = 0;  ax(4) = 1;
axis(ax); 

xlabel('Volume (|E|)'); 
ylabel('Proportion of bridging (|E_{bridging}| / |E_{all}|)'); 

print(sprintf('plot/briclo.%s.eps', network), '-depsc'); close all; 
