UNUSED

%
% Plot and print an edge distribution plot. 
%
% PARAMETERS 
%	A	Adjacency matrix (the left side is used)
%	text	
%	letter	For filename and color
%	network	For filename
%
% OUTPUT 
%	plot/edge.[letter].[network].eps
%

function edge_print(A, text, letter, network)

font_size = 27; 
colors = konect_colors_letter();
line_width = 3; 

v = -sort(-sum(A, 2));

stairs(1:length(v), v, 'Color', colors.(letter), 'LineWidth', line_width);

set(gca, 'XScale', 'log');
set(gca, 'YScale', 'log');

xlabel('Vertex (i)', 'FontSize', font_size); 
ylabel(sprintf('%s (d(i))', text), 'FontSize', font_size); 

set(gca, 'FontSize', font_size); 

konect_print(sprintf('plot/edge.%s.%s.eps', letter, network)); 
