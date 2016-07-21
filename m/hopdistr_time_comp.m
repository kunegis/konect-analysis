%
% Compute the hop distribution over time.
%
% PARAMETERS 
%	$network
%	$type		The data to use, "full" or "split"
%
% INPUT FILES 
%	dat/info.$network
%	dat/data.$network.mat (only full)
%	dat/split.$network.mat (only split)
%	dat/stepsi.$network (only full)
%	dat/steps.$network.mat (only split) 
%	
% OUTPUT FILES 
%	dat/hopdistr_time.$type.$network
%		(T*D) One timepoint per line; extra numbers at the end of each line filled with zeroes 
%	dat/hopdistr_time_runtime.$type.$network 
%		Column vector of runtimes in seconds (as floating point numbers) 
%

network = getenv('network'); 
type = getenv('type');
is_split = strcmp(type, 'split'); 

consts = konect_consts(); 

info = read_info(network); 

if ~is_split
    data = load(sprintf('dat/data.%s.mat', network)); 
    T = data.T(:,1:2);
    e_steps = load(sprintf('dat/stepsi.%s', network)); 
else 
    split = load(sprintf('dat/split.%s.mat', network)); 
    T = [split.T_source(:,1:2); split.T_target(:,1:2); split.T_test(:,1:2)]; 
    steps = load(sprintf('dat/steps.%s.mat', network)); 
    e_steps = steps.e_steps; 
end

ret = []; 

times = []; 

% Assume that runtime is linear in K
t = konect_timer(0.5 * length(e_steps) * (1 + length(e_steps))); 

for k = 1 : prod(size(e_steps))

    t = konect_timer_tick(t, 1 + 0.5 * (k - 1) * k); 

    Tk = T(1:e_steps(k), :);
    Ak = konect_spconvert(Tk, info.n1, info.n2); 
    t0 = cputime; 

    % Make undirected and keep largest connected component
    if info.format == consts.ASYM
        Ak = Ak + Ak'; 
        Ak = konect_connect_matrix_square(Ak); 
    elseif info.format == consts.SYM
        Ak = konect_connect_matrix_square(Ak); 
    elseif info.format == consts.BIP
        Ak = konect_connect_matrix_bipartite(Ak); 
    end

    d = konect_hopdistr(Ak, info.format); 

    t1 = cputime;
    time = t1 - t0
    if sum(size(times)) > 0
        times = [times ; time];
    else
        times = time; 
    end

    % Pad with zeroes
    if size(ret,1) > 0 
        if size(ret,2) < length(d)
            ret = [ ret , zeros(size(ret,1), length(d) - size(ret,2)) ]; 
        elseif size(ret,2) > length(d)
            d = [ d , zeros(1, size(ret,2) - length(d)) ]; 
        end
    end

    ret = [ ret ; d ];

end

konect_timer_end(t); 

OUT = fopen(sprintf('dat/hopdistr_time.%s.%s', type, network), 'w'); 
if OUT < 0, error; end
for i = 1 : size(ret,1)
    fprintf(OUT, '%u ', ret(i, :));
    fprintf(OUT, '\n');   
end
if fclose(OUT) < 0, error; end

save(sprintf('dat/hopdistr_time_runtime.%s.%s', type, network), 'times', '-ascii'); 
