%
% Generate and plot a SynGraphy graph.
%
% PARAMETERS 
%	$network
%
% INPUT 
%	dat/statistic.size.$network
%	dat/statistic.uniquevolume.$network
%	dat/statistic.twostars.$network
%	dat/statistic.threestars.$network
%	dat/statistic.fourstars.$network
%	dat/statistic.triangles.$network
%	dat/statistic.squares.$network
%	
% OUTPUT 
%	plot/syngraphy.[a].$network.eps
%

% Fixed parameters of the output
n2 = 80; 
d2 = 5;

consts = konect_consts(); 

network = getenv('network');

statistics = {'size', 'uniquevolume', 'twostars', 'threestars', 'fourstars', ...
              'triangles', 'squares'};

for i = 1 : length(statistics)
    i
    statistic = statistics{i}
    data = load(sprintf('dat/statistic.%s.%s', statistic, ...
                        network))
    values(i) = data(1); 
end

values

n1 = values(1)
m1 = values(2)
s1 = values(3)
z1 = values(4)
x1 = values(5)
t1 = values(6)
q1 = values(7)

[m2 s2 z2 x2 t2 q2] = syngraphy_scale_degree(n2, d2, n1, m1, s1, z1, x1, t1, q1);

A = syngraphy_generate(n2, m2, s2, z2, x2, t2, q2);

n = size(A,1); 

%
% (a):  Fruchterman--Reingold
%

[U_l D_l] = konect_decomposition('lap', A, 3, consts.SYM, consts.UNWEIGHTED);
X = fruchterman_reingold_force_directed_layout(A | A', 'progressive', U_l(:,2:3));
gplot2(A, X, 'o-', 'MarkerFaceColor', [0 0 0], 'MarkerEdgeColor', [0 0 0]);
axis off equal; 
konect_print(sprintf('plot/syngraphy.a.%s.eps', network));

%
% (b) Delaunay
%

[U D] = konect_decomposition_stoch1(A, 3, consts.SYM, consts.UNWEIGHTED);

U = U(:,2:3);

xe = U(:,1) + rand(n,1) * 1e-5 * mean(U(:,1));
ye = U(:,2) + rand(n,1) * 1e-5 * mean(U(:,2));

tri = delaunay(xe, ye);

T_d = [ tri(:,[1 2]); tri(:,[1 3]); tri(:,[2 3])];
A_d = sparse(T_d(:,1), T_d(:,2), 1, n, n);
A_d = (A_d ~= 0); 
A_d = (A_d | A_d');
A_d = triu(A_d); 

[V D] = konect_decomposition_stoch1(A_d, 3, consts.SYM, consts.UNWEIGHTED);
V = V(:,2:3);

k = convhull(V(:,1), V(:,2));

d_d = sum(A_d,2) + sum(A_d,1)';
assert(sum(d_d == 0) == 0); % No zero-degree nodes 
d_d_inv = d_d .^ -1;
P_d = spdiags(d_d_inv, [0], n, n) * (A_d | A_d');

V_e = V;
for i = 1:50
    V_e = P_d * V_e; 
    V_e(k,:) = V(k,:);
end

delaunay_one(A, V_e);
konect_print(sprintf('plot/syngraphy.b.%s.eps', network));

%
% (c) Laplacian
%

gplot2(A, U_l(:,2:3), 'o-', 'MarkerFaceColor', [0 0 0], 'MarkerEdgeColor', [0 0 0]);
axis equal off; 
konect_print(sprintf('plot/syngraphy.c.%s.eps', network));
