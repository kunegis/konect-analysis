%
% Draw a permutation plot.  Given two eigenvector matrices, this will
% draw a square matrix of cosine similarities using black for 1 and
% white for 0. 
%
% PARAMETERS 
%	u1,u2	(n*r) Eigenvectors to be compared
%

function evol_permutation(u1, u2)

font_size = 20; 

cm = 1:-0.01:0; 
cm = [cm.^.6' cm.^.6' cm.^.9']; 

u1 = u1 ./ norm(u1);
u2 = u2 ./ norm(u2); 

similarities = abs(u1' * u2);

imagesc(similarities', [0 1]);
colorbar; 
pbaspect([size(u1,2) size(u2,2) 1]); 
colormap(cm); 
xlabel('k', 'FontSize', font_size); 
ylabel('l', 'FontSize', font_size); 
set(gca, 'FontSize', font_size); 

