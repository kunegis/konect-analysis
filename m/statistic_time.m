%
% Compute a network statistic over time on the full data (i.e. not split). 
%
% PARAMETERS 
%	$network	The network; must have timestamps
%	$statistic	The statistic
%	$type		The data to use, "full" or "split"
%
% INPUT 
%	dat/info.$network
%	dat/data.$network.mat (only full)
%	dat/split.$network.mat (only split)
%	dat/stepsi.$network (only full)
%	dat/steps.$network.mat (only split) 
%	dat/meansi.$network.mat (only full) 
%	dat/means.$network.mat (only split) 
%
% OUTPUT 
%	dat/statistic_time.$type.$statistic.$network	
%		All statistics as text.  One timepoint per line.  Each
%		line contains the statistics, with the first number
%		being the main statistic. 
%	dat/statistic_time_runtime.$type.$statistic.$network
%		Column vector of runtimes in seconds (as floating point numbers) 
%

network = getenv('network'); 
statistic = getenv('statistic'); 
type = getenv('type');

is_split = strcmp(type, 'split'); 

consts = konect_consts(); 

info = read_info(network); 

if ~is_split
    data = load(sprintf('dat/data.%s.mat', network)); 
    T = data.T;
    means = load(sprintf('dat/meansi.%s.mat', network)); 
    T = konect_normalize_additively(T, means); 
    e_steps = load(sprintf('dat/stepsi.%s', network)); 
else 
    split = load(sprintf('dat/split.%s.mat', network)); 
    means = load(sprintf('dat/means.%s.mat', network)); 
    T = konect_normalize_additively([split.T_source; split.T_target; split.T_test], ...
                              means); 
    steps = load(sprintf('dat/steps.%s.mat', network)); 
    e_steps = steps.e_steps; 
end

ret = []; 

times = []; 

% Assume that runtime is linear in K
t = konect_timer(0.5 * length(e_steps) * (1 + length(e_steps))); 

for k = 1 : length(e_steps)

    t = konect_timer_tick(t, 1 + 0.5 * (k - 1) * k); 

    T_k = T(1:e_steps(k), :);
    A_k = konect_spconvert(T_k, info.n1, info.n2); 

    A_k_abs = konect_absx(A_k); 

    % Remove empty columns and lines
    if info.format == consts.BIP
        ii = sum(A_k_abs,2) ~= 0;
        jj = sum(A_k_abs,1) ~= 0;
        A_k = A_k(ii,jj);
    else
        ii = sum(A_k_abs,2) + sum(A_k_abs,1)' ~= 0;
        A_k = A_k(ii,ii); 
    end

    t0 = cputime; 
    values = konect_statistic(statistic, A_k, info.format, info.weights) 
    t1 = cputime;

    values = full(values); 

    time = t1 - t0;

    if sum(size(times)) > 0
        times = [times ; time];
    else
        times = time; 
    end

    if sum(size(ret)) ~= 0
        ret = [ret zeros(1, size(values,1) - size(ret, 2))];
    end
    
    ret = [ret ; values'];
end

konect_timer_end(t); 

save(sprintf('dat/statistic_time.%s.%s.%s', type, statistic, network), 'ret', '-ascii');

save(sprintf('dat/statistic_time_runtime.%s.%s.%s', type, statistic, network), 'times', '-ascii'); 
