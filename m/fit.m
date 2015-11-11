%
% Perform curve fitting.
%
% PARAMETERS 
%	$NETWORK
%	$DECOMPOSITION
%
% INPUT 
%	dat/info.$NETWORK
%	dat/decomposition_split.source.$DECOMPOSITION.$NETWORK.mat
%	dat/split.$NETWORK.mat
%	dat/means.$NETWORK.mat
%
% OUTPUT 
%	dat/fit.$DECOMPOSITION.$NETWORK.mat
%		curves 		Struct by name of curve of parameters in column vectors
%		Delta		The diagonality test matrix 
%		a,d		Source and target values for curve fitting 
%		pivot		The pivot value used 
%

network = getenv('NETWORK');
decomposition = getenv('DECOMPOSITION'); 

consts = konect_consts(); 

info = read_info(network); 
decomposition_source = load(sprintf('dat/decomposition_split.source.%s.%s.mat', decomposition, network))
split = load(sprintf('dat/split.%s.mat', network));
means = load(sprintf('dat/means.%s.mat', network)); 

T_target = konect_normalize_additively(split.T_target, means);
A_target = konect_spconvert(T_target, split.n1, split.n2);

data_decomposition = konect_data_decomposition(decomposition);

%
% Spectral diagonality test matrix
%
Delta = spectral_diagonality_test(decomposition, decomposition_source, A_target, info.format); 

% 
% Create A and D
%
isdedicom = norm(decomposition_source.D - diag(diag(decomposition_source.D)), 'fro') > 0
if isdedicom
    [a_u a_d] = eig(decomposition_source.D);
    a = diag(a_d); 
    d = diag(inv(a_u) * Delta * a_u); 
else
    a = diag(decomposition_source.D);
    d = diag(Delta);
end

%
% Normalize the largest eigenvalue to 1
%
pivot = pivotize(data_decomposition, decomposition_source.D);
aa = a ./ pivot;
dd = d ./ pivot; 

%
% Map to real values
% 
if ~isreal(aa) | ~isreal(dd)
    fprintf(1, 'Complex values:  using real part\n'); 
    
    aa = real(aa); 
    dd = real(dd); 
end

%
% Remove trivial latent dimensions
%
first = konect_first_index(decomposition, a)
aa_first = aa(first:end);
dd_first = dd(first:end); 

%
% DEDICOM A and D
%

if isdedicom
    ax = decomposition_source.D;
    dx = Delta;
    aax = ax / pivot;
    ddx = dx / pivot; 
end

curves = {};

%
% (lin) Linear
% [a] such that f(x) = ax
%

if ~data_decomposition.l
    curves.lin = [ (aa \ dd)]'; 
end

%
% (poly) Polynomial
% [a b c ...] such that f(x) = a + bx + cx^2 + ...
%
if ~data_decomposition.l
    deg_poly = 4; 
    values = polyfit(aa, dd, deg_poly);
    curves.poly = values(end:-1:1);
end

%
% (polyo) Odd polynomial
% [a b c ...] such that f(x) = ax + bx^3 + cx^5 + ... 
%
if ~data_decomposition.l 
    deg_polyo = 7; 
    Co = [];
    for i = 1:2:deg_polyo
        Co = [Co (aa .^ i)]; 
    end
    curves.polyo = Co \ dd; 
end

%
% (polyn) Nonnegative polynomial 
% [a b c ...] such that f(x) = a + bx + cx^2 + ... 
%

if ~data_decomposition.l 
    deg_polyn = 7; 
    C = [];
    for i = 0:deg_polyn
        C = [C (aa .^ i)]; 
    end
    curves.polyn = lsqlin(C, dd, -eye(deg_polyn+1), zeros(deg_polyn+1,1)); 
end

%
% (polyon) Nonnegative odd polynomial
% [a b c ...] such that f(x) = ax + bx^3 + cx^5 + ... 
%
if ~data_decomposition.l 
    if sum(abs(a) > 0)
        deg_polyon = 7; 
        C = [];
        for i = 1:2:deg_polyon
            C = [C (aa .^ i)]; 
        end
        n = (deg_polyon+1) / 2; 
        curves.polyon = lsqlin(C, dd, -eye(n), zeros(n,1)); 
    else
        curves.polyon = [1]; 
    end
end

%
% (polyl) Laplacian polynomial
% [a b c ...] such that f(x) = a + b/x + c/x^2 + ... 
%
if data_decomposition.l
    if length(aa_first) > 1
        deg_poly = 4; 
        values = polyfit(aa_first .^ -1, dd_first, deg_poly);
        curves.polyl = values(end:-1:1);
    else
        curves.polyl = [0 1]; 
    end
end

%
% (polynl) Nonnegative Laplacian polynomial 
% [a b c ...] such that f(x) = a + b/x + c/x^2 + ... 
%

if data_decomposition.l 
    'polynl'
    deg_polyn = 7; 
    C = [];
    for i = 0:deg_polyn
        C = [C (aa_first .^ -i)]; 
    end
    C
    if length(aa_first) > 1
        dd_first
        curves.polynl = lsqlin(C, dd_first, -eye(deg_polyn+1), zeros(deg_polyn+1,1));
        cp = curves.polynl 
    else
        curves.polynl = [0 1]; 
    end
end

%
% (polyx) DEDICOM polynomial
% [a b c ...] such that f(x) = a + bx + cx^2 + ...
%

if isdedicom
    % Solve the system [ a0 a1 a2 ... ] x = b
    % where ai is the vectorization of ax^i and b is b is the vectorization of Delta 

    deg_polyx = 4;

    A = [];
    r = size(ax,1); 
    axi = eye(r); 
    for i = 0 : deg_polyx
        A = [A, axi(:)]; 
        axi = axi * aax; 
    end
    curves.polyx = A \ ddx(:);
end


%
% (rr) Rank reduction 
% (rrs) Signed rank reduction 
% [a r] with f(x) = ax when |x| >= |lambda_r| and f(x)=0 otherwise 
%
if ~data_decomposition.l
    enable_signed = sum(a < 0) > 0; 

    square_sum_best = +Inf;
    r_best = -1;
    y_best = -1;

    if enable_signed
        square_sum_s_best = +Inf; 
        r_s_best = -1; 
        y_s_best = -1; 
    end

    for r= 1:length(aa) % number of singular values that we keep

        y = aa(1:r) \ dd(1:r);
        square_sum  = sum(((aa(1:r) * y  ) - dd(1:r)).^2) + sum(dd((r+1):end).^2);
        if square_sum < square_sum_best
            square_sum_best = square_sum;
            r_best = r;
            y_best = y;
        end;

        if enable_signed
            y_s = aa(1:r) \ abs(dd(1:r)); 
            square_sum_s  = sum(((aa(1:r) * y_s) - dd(1:r)).^2) + sum(dd((r+1):end).^2);
            if square_sum_s < square_sum_s_best
                square_sum_s_best = square_sum_s;
                r_s_best = r;
                y_s_best = y_s;
            end 
        end
    end

    if r_best < 0, r_best = length(aa); y_best = 1; end; 
    curves.rr = [y_best r_best];

    if enable_signed
        if r_s_best < 0, r_s_best = length(aa); y_s_best = 1; end; 
        curves.rrs = [y_s_best r_s_best]; 
    end
end


%
% (rrl) Rank reduction 
% [a r] with f(x) = a/x when |x| <= lambda_r and f(x)=0 otherwise 
%
if data_decomposition.l
    square_sum_best = +Inf;
    r_best = -1;
    y_best = -1;

    for r= 1:length(aa_first) % number of singular values that we keep
        y = (aa_first(1:r) .^ -1) \ dd_first(1:r);
        square_sum = sum(((y ./ aa_first(1:r)) - dd_first(1:r)).^2) + sum(dd_first((r+1):end).^2)
        if square_sum < square_sum_best
            square_sum_best = square_sum;
            r_best = r;
            y_best = y;
        end;
    end

    if r_best < 0, r_best = length(aa_first); y_best = 1; end; 
    curves.rrl = [y_best (r_best + first - 1)];
end


%
% (exp) Exponential 
% [a b] such that f(x) = b * e^(ax) = \sum_k (b a^k / k!) x^k
%

if ~ data_decomposition.l 
    curves.exp = lsqnonlin(@(y)(dd - y(2) * exp(y(1) * aa)), [1,1], [0, 0], [+Inf, +Inf]); 
end

%
% (expl) Exponential Laplacian; heat diffusion kernel
% [a b] with f(x) = b e^-ax
%
if data_decomposition.l
    if length(aa_first) > 1
        curves.expl = lsqnonlin(@(y)(dd - y(2) * exp(- y(1) * aa)), [1 1], [0 0], [+Inf,+Inf]);
    else
        curves.expl = [1 1]; 
    end
end

%
% (expnl) Exponential of normalized Laplacian
% [a b] with f(x) = b e^(-a(1-x))
%
if data_decomposition.n
    curves.expnl = lsqnonlin(@(y)(dd - y(2) * exp(- y(1) * (1 - aa))), [1 1], [0 0], [+Inf,+Inf]); 
end

%
% (expo) Hyperbolic sine (i.e., odd exponential) 
% [a b] such that f(x) = b * sinh(ax) = \sum_{k odd} (b/k!) x^k 
%

if ~ data_decomposition.l 
    curves.expo = lsqnonlin(@(y)(dd - y(2) * sinh(y(1) * aa)), [1,1], [0,0], [+Inf, +Inf]); 
end

%
% (rat) Rational function
% [a b] such that f(x) = b / (1 - ax) = \sum_k (b a^k) x^k
%

if ~data_decomposition.l 
    starting_value_alpha = .9;
    starting_value_beta  = .1; 
    epsilon = 1e-4; 
    min_alpha = 0 + epsilon;
    max_alpha = 1 - epsilon; 
    min_beta  = 0 + epsilon; 
    max_beta  = +Inf;

    curves.rat = lsqnonlin(@(y)(dd - y(2) * ((1 - y(1) * aa).^-1)), ...
                           [starting_value_beta starting_value_alpha], [min_alpha, min_beta], [max_alpha, max_beta]);
end

%
% (rato) Odd rational function
% [a b] such that f(x) = abx / (1 - a^2 x^2) = \sum_{k odd} (b a^k) x^k 
%
if ~data_decomposition.l 
    starting_value_alpha = .9;
    starting_value_beta  = .1; 
    epsilon = 1e-4; 
    min_alpha = 0 + epsilon;
    max_alpha = 1 - epsilon; 
    min_beta  = 0 + epsilon; 
    max_beta  = +Inf;

    curves.rato = lsqnonlin(@(y)(dd - y(1) * y(2) * aa ./ (1 - y(1)^2 * (aa.^2))), ...
                            [starting_value_beta starting_value_alpha], [min_alpha, min_beta], [max_alpha, max_beta]); 
end

%
% (ratn) Normalized rational function
% [a] such that f(x) = a / (1 - x)
%
if data_decomposition.n
    curves.ratn = [ ((1 - aa) .^ -1) \ dd ]; 
end

%
% (ratno) Odd normalized rational function
% [a] such that f(x) = ax / (1 - x^2)
%
if data_decomposition.n
    curves.ratno = [ (aa ./ (1 - aa.^2)) \ dd ];
end

%
% (uni) Uniform integral over regularized Laplacian [348]
% [a] such that f(x) = a (1 + (1/x -1 ) ln(1 - x)) / x 
%
if data_decomposition.n
    curves.uni = [ ((1 + (aa.^-1 - 1) .* log(1-aa))./aa) \ dd ];
end

%
% (lap) Moore--Penrose pseudoinverse of Laplacian
% [a] with f(x) = a / x when x≠0, f(x)=0 otherwise
%
if data_decomposition.l
    if length(aa_first) > 1
        aa_pinv = aa_first .^ -1;
        curves.lap = [ aa_pinv \ dd_first ]; 
    else
        curves.lap = [ 1 ]; 
    end
end

%
% (ratl) Rational function of Laplacian; regularized Laplacian
% [a b] with f(x) = b / (1 + ax)
%
if data_decomposition.l
    if length(aa_first) > 1
        curves.ratl = lsqnonlin(@(y)(dd - y(2) * ((1 + y(1) * aa).^-1)), [50 6], [0,0], [+Inf,+Inf]);
    else
        curves.ratl = [1 1]; 
    end
end

%
% (like) Save learned eigenvalues 
% [l_1 l_2 ...] with f(lambda_i) = l_i, normalized such that l_1 = 1
%
curves.like = dd; 

%
% Save
%
save(sprintf('dat/fit.%s.%s.mat', decomposition, network), 'curves', 'Delta', 'a', 'd', 'pivot', '-v7.3'); 
