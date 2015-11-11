%
% Generate an assortativity plot.
%
% PARAMETERS 
%	d	(n*1) Degree vector
%	A	(n*m) Unweighted adjacency / biadjacency matrix; does
%		not contain edge weights, but may contain other
%		values than 0/1 when there are multiple edges 
%	letter	Determines the color
%	text	(string) The word "degree" or similar in lower case
%

function assortativity_one(d, d2, A, letter, text)

colors = konect_colors_letter(); 

font_size = 22; 

q = A * d2;
e = q ./ d;

assert(text(1) >= 'a' && text(1) <= 'z'); 
text_sentence = text;  text_sentence(1) = text_sentence(1) + ('A' - 'a'); 

plot(d, e, '.', 'Color', colors.(letter));

xlabel(text_sentence, 'FontSize', font_size);
ylabel(sprintf('Average neighbor %s', text), 'FontSize', font_size);

set(gca, 'XScale', 'log', 'YScale', 'log');

set(gca, 'FontSize', font_size); 

set(gca, 'XMinorTick', 'on');
set(gca, 'YMinorTick', 'on'); 
set(gca, 'TickLength', [0.05 0.05]); 

% Workaround for Matlab bug. Otherwise, the minor ticks are not visible. 
ax = axis(); 
if ax(1) > 0 & ax(3) > 0 
    set(gca, 'XTick', 10 .^ (ceil(log(ax(1)) / log(10)):floor(log(ax(2)) / log(10)))); 
    set(gca, 'YTick', 10 .^ (ceil(log(ax(3)) / log(10)):floor(log(ax(4)) / log(10)))); 
end
