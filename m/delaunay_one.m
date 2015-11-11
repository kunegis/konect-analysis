
function delaunay_one(A, U)

hold on;

gplot2(A | A', U, '-', 'LineWidth', 0.1, 'Color', 0.6 * [1 1 1]);
gplot2(A | A', U, '.', 'Color', [0.7 0.3 0], 'MarkerSize', 50); 

axis off equal; 
