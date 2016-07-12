%
% Double layout
%
% PARAMETERS 
%	$network
%
% INPUT 
%	dat/info.$network
%	dat/data.$network.mat
%	dat/decomposition_map.stoch.$network.mat
%

network = getenv('network');

consts = konect_consts(); 

info = read_info(network); 

n = info.n

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

data_decomposition = ...
  load(sprintf('dat/decomposition_map.%s.%s.mat', 'stoch', network));

if info.format ~= consts.BIP
    x = data_decomposition.U(:,2);
    y = data_decomposition.U(:,3); 
else
    x = [ data_decomposition.U(:,2); data_decomposition.V(:,2)]; 
    y = [ data_decomposition.U(:,3); data_decomposition.V(:,3)]; 
end
assert(size(x,1) == n);
assert(size(y,1) == n);
assert(size(x,2) == 1);
assert(size(y,2) == 1);
X = [ x y ];

%
% Second embedding
%

% Characteristic length
ll = 0.2; 
l = ll * mean([max(X(:,1)) - min(X(:,1)), max(X(:,2)) - min(X(:,2))]);

% Similarity matrix 
Q = sparse(n,n); 
K = min(80, n); 
for i = 1 : n
    Q_i = (X(:,1) - X(i,1)) .^ 2 + (X(:,2) - X(i,2)) .^ 2;
    assert(size(Q_i,1) == n);
    [Q_i_s ii] = sort(Q_i);
    assert(size(Q_i_s, 1) == n);
    assert(size(ii, 1) == n); 
    ii = ii(1:K);
    Q_i_s = Q_i_s(1:K);
    Q_i_s_sim = exp(-0.5 * Q_i_s / (l^2));
    Q(ii,i) = Q(ii,i) + Q_i_s_sim;
    Q(i,ii) = Q(i,ii) + Q_i_s_sim';
end

% B = exp(-0.5 * Q / (l^2));

[U D] = konect_decomposition_stoch1(Q, 3, consts.ASYM, consts.WEIGHTED);

U = U(:,2:3);

%U(:,1) = U(:,1) - mean(U(:,1));
%U(:,2) = U(:,2) - mean(U(:,2));

delaunay_one(A, U);
plot(0, 0, '+', 'MarkerSize', 300); 
konect_print_bitmap(sprintf('plot/lybl.a.%s.png', network));

h1 = atan2(U(:,2), U(:,1)) / (2 * pi) + 0.5;
dists = sum(U(:,1).^2 + U(:,2).^2, 2); 
h3 = ones(n,1); 
%h3 = dists ./ max(dists);
hsv = [h1, ones(n,1), h3];
rgb = hsv2rgb(hsv);

hold on;
gplot2(A, X, '-', 'LineWidth', 0.1, 'Color', 0.5 * [1 1 1]);
assert(size(X,1) == n); 
for i = 1 : n
    plot(X(i,1), X(i,2), '.', 'Color', rgb(i,:), 'MarkerSize', 50); 
end
axis equal off; 
konect_print_bitmap(sprintf('plot/lybl.b.%s.png', network));
