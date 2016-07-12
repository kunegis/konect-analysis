%
% PARAMETERS 
%	$network
%
% INPUT 
%	dat/data.$network.mat
%	dat/info.$network
%
% OUTPUT 
%	plot/delaunay.a.$network.eps
%

consts = konect_consts(); 

network = getenv('network')

info = read_info(network); 
n = info.n;

%
% Actual graph 
%
data = load(sprintf('dat/data.%s.mat', network)); 
T = data.T(:,1:2); 
if info.format ~= consts.BIP
    A = sparse(T(:,1), T(:,2), 1, n, n); 
    A = (A ~= 0);
    A = (A | A');
    A = triu(A); 
else
    A = sparse(T(:,1), T(:,2), 1, info.n1, info.n2); 
    A = (A ~= 0); 
    A = [ sparse(info.n1,info.n1), A; sparse(info.n2, info.n1+info.n2) ]; 
end

assert(size(A,1) == n); 
assert(size(A,2) == n); 

%
% Original embedding
%

[U_l D_l V_l] = konect_decomposition_stoch1(A, 3, consts.SYM, ...
                                            consts.UNWEIGHTED); 

if info.format ~= consts.BIP
    x = U_l(:,2);
    y = U_l(:,3); 
else
    x = [ U_l(:,2); V_l(:,2)]; 
    y = [ U_l(:,3); V_l(:,3)]; 
end

assert(size(x,1) == n);
assert(size(y,1) == n);
assert(size(x,2) == 1);
assert(size(y,2) == 1);

U = [ x y ];

%
% Original drawing
%
delaunay_one(A, U);
konect_print_bitmap(sprintf('plot/delaunay.b.%s.png', network));

%
% Stochastic matrix of original graph
%

d = sum(A,2) + sum(A,1)';
d_inv = d .^ -1;
d_inv(isinf(d_inv)) = 0;
P = spdiags(d_inv, [0], n, n) * (A | A');

%
% Delaunay triangulation
%

xe = U(:,1) + rand(n,1) * 1e-5 * mean(U(:,1));
ye = U(:,2) + rand(n,1) * 1e-5 * mean(U(:,2));

tri = delaunay(xe, ye);

T_d = [ tri(:,[1 2]); tri(:,[1 3]); tri(:,[2 3])];
A_d = sparse(T_d(:,1), T_d(:,2), 1, n, n);
A_d = (A_d ~= 0); 
A_d = (A_d | A_d');
A_d = triu(A_d); 

%
% Drawing of Delaunay triangulation on original embedding 
%

delaunay_one(A_d, U);
konect_print_bitmap(sprintf('plot/delaunay.c.%s.png', network));

%
% Embedding of the Delaunay triangulation
%

[V D] = konect_decomposition_stoch1(A_d, 3, consts.SYM, consts.UNWEIGHTED);
V = V(:,2:3);

%
% Stretched Delaunay drawing
%

delaunay_one(A_d, V);
konect_print_bitmap(sprintf('plot/delaunay.d.%s.png', network));

%
% Delaunay drawing
%

delaunay_one(A, V); 
konect_print_bitmap(sprintf('plot/delaunay.a.%s.png', network));

%
% Convex hull of Delaunay triangulation 
%

k = convhull(V(:,1), V(:,2));

%
% Stochastic matrix of Delaunay triangulation 
%

d_d = sum(A_d,2) + sum(A_d,1)';
assert(sum(d_d == 0) == 0); % No zero-degree nodes 
d_d_inv = d_d .^ -1;
P_d = spdiags(d_d_inv, [0], n, n) * (A_d | A_d');

%
% Re-arrange interior, fixing the hull
%

V_e = V;
for i = 1:50
    V_e = P_d * V_e; 
    V_e(k,:) = V(k,:);
end

%
% Drawing based on uniformized Delaunay triangulation, showing
% original graph 
%

delaunay_one(A, V_e);
konect_print_bitmap(sprintf('plot/delaunay.g.%s.png', network));

%
% Drawing based on uniformized Delaunay triangulation, showing
% the Delaunay triangulation
%

delaunay_one(A_d, V_e);
konect_print_bitmap(sprintf('plot/delaunay.h.%s.png', network));

%exit(0);

%
% + Layout; this is not scalable 
%

v = konect_connect_square(A);
vv = find(v); 
X = kamada_kawai_spring_layout(double(A(vv,vv) | A(vv,vv)'), ...
                               'progressive', U(vv,:));

delaunay_one(A(vv,vv), X); 
konect_print_bitmap(sprintf('plot/delaunay.f.%s.png', network));


