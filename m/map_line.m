%
% Draw a full graph (with edges) using decomposition data. 
%
% PARAMETERS
%	x, y	(n*1) Coordinates
%	T	(e*2) Edges 
%	dense	0/1 dense plot
%

function map_line(x, y, T, dense)

if dense
    line_width = 0.1; 
else
    line_width = 1; 
end

colors_letter = konect_colors_letter();

if dense
    style = '-'; 
else
    style = '-o';
end

if dense
    hold on; 
end

gplot2(sparse(T(:,1), T(:,2), 1), [x y], style, 'LineWidth', line_width, ...
       'Color', colors_letter.a);

if dense 
    gplot2(sparse(T(:,1), T(:,2), 1), [x y], '.', 'Color', [1 0.5 0]); 
end

axis equal; 
axis off; 
