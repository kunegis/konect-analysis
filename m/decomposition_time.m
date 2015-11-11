%
% Compute the matrix decomposition by time. 
%
% PARAMETERS 
% 	$NETWORK	
%	$DECOMPOSITION
%	$TYPE		The data to use, "full" or "split"
%
% INPUT 
%	dat/info.$NETWORK
%	dat/data.$NETWORK.mat (only full)
%	dat/split.$NETWORK.mat (only split)
%	dat/stepsi.$NETWORK (only full)
%	dat/steps.$NETWORK.mat (only split) 
%	dat/meansi.$NETWORK.mat (only full) 
%	dat/means.$NETWORK.mat (only split) 
%
% OUTPUT 
%	dat/decomposition_time.$TYPE.$DECOMPOSITION.$NETWORK.mat
%		.r			Rank
%		.decompositions(i)
%			.U	Eigenvectors or equivalent
%			.D	Eigenvalues / Singular value / Middle matrix
%			.V	Eigenvectors; may be []
%			.n	Number of nodes considered 
% 
%	dat/decomposition_time_runtime.$TYPE.$STATISTIC.$NETWORK
%		Column vector of runtimes in seconds (as floating
%		point numbers) 
% 

network = getenv('NETWORK');
decomposition = getenv('DECOMPOSITION');
type = getenv('TYPE');
is_split = strcmp(type, 'split'); 

info = read_info(network); 

r = get_rank_type(network, decomposition);

r = ceil(r / 2); 

if ~is_split
    data = load(sprintf('dat/data.%s.mat', network)); 
    T = data.T;
    means = load(sprintf('dat/meansi.%s.mat', network)); 
    T = konect_normalize_additively(T, means); 
    e_steps = load(sprintf('dat/stepsi.%s', network)); 
else 
    split = load(sprintf('dat/split.%s.mat', network)); 
    means = load(sprintf('dat/means.%s.mat', network)); 
    T = konect_normalize_additively([split.T_source; split.T_target; split.T_test], means); 
    steps = load(sprintf('dat/steps.%s.mat', network)); 
    e_steps = steps.e_steps; 
end

if ~has_timestamps(network)
    error('*** Network does not have timestamps'); 
end

times = [];

opts.disp = 2; 

% Assume that runtime is linear in K
t = konect_timer(0.5 * length(e_steps) * (1 + length(e_steps))); 

for k = 1 : length(e_steps)

    t = konect_timer_tick(t, 1 + 0.5 * (k - 1) * k); 

    Tk = T(1 : e_steps(k), :);
    Ak = konect_spconvert(Tk, info.n1, info.n2); 

    t0 = cputime; 
    [U D V d_u d_v n] = konect_decomposition(decomposition, Ak, r, info.format, info.weights, opts); 
    t1 = cputime;
    time = t1 - t0
    if sum(size(times)) > 0
        times = [times ; time];
    else
        times = time; 
    end

    decompositions(k).U = U;
    decompositions(k).D = D;
    decompositions(k).V = V; 
    decompositions(k).n = n; 
end

konect_timer_end(t); 

save(sprintf('dat/decomposition_time.%s.%s.%s.mat', type, decomposition, network), '-v7.3', 'decompositions', 'r');

save(sprintf('dat/decomposition_time_runtime.%s.%s.%s', type, decomposition, network), 'times', '-ascii'); 
