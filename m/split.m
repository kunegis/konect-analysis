%
% Split a dataset into source, target and test sets.  
%
% Unconnected vertices are removed. 
%
% The source, target and test set are output as *×3 matrices,
% where the first two columns represented row and column indexes, and
% the third column the edge weight.  The zero test set only has row and
% column indexes. 
%
% The zero test set has approximately the same size as the test set and
% may contain a minimal amount of edges (instead of edges). 
%
% The test and zero test sets do not contain duplicates. 
%
% PARAMETERS 
% 	$network		Name of dataset, e.g. "advogato"
%
% INPUT 
%	uni/out.$network
%	dat/info.$network
%
% OUTPUT 
%	dat/split.$network.mat		Split matrices
%		n1,n2			Size of dataset 
%		T_source		(X*3) Source set
%		T_target		(X*3) Target set
%		T_test			(X*3) Test set
%		T_test_zero		(X*2) Zero test set, [] for
%			unweighted and positively weighted datasets  
%		u_ids,v_ids		IDs of entities in the reduced dataset 
%

network = getenv('network');

consts = konect_consts(); 

%
% Load file
%
fprintf(1, 'Loading...\n');
T = load(sprintf('uni/out.%s', network));

info = read_info(network); 
lines = info.lines; 
n1 = info.n1;
n2 = info.n2; 

%
% Timestamps
%
fprintf(1, 'Timestamps...\n'); 

if size(T,2) > 3
    % Sort by time
    [x,i] = sort(T(:,4));
    T = T(i, 1:3); 
else
    % If no timestamps are available, randomize the order of
    % relationships to remove effects of the initial order.  
    i = randperm(size(T,1));
    T = T(i, :); 
end;

%
% Split between training ( = source + target) and the rest
%
fprintf(1, 'Split training/test...\n'); 

testsize = .250;

split_b = 1 - testsize;
split_a = split_b^2;

lines_a = round(lines * split_a); 

T_source = T(1 : lines_a, :);
T_target_test = T(1+lines_a:end, :); 

%
% Connect (keep only the giant connect component of the training set) 
%

fprintf(1, 'Finding largest connected component...\n'); 

% In the next line, ignore edge weights (i.e. use only the first two
% columns of T_source) because otherwise zero-edges would be ignored.
% (They must be normalized otherwise.) 
A_source = konect_spconvert(T_source(:,1:2), n1, n2);

if info.format == consts.BIP
    [v,w] = konect_connect_bipartite(A_source);
else 
    v = konect_connect_square(A_source);
    w = v; 	     
end;

if sum(size(v)) == 0
    error '*** No largest connected component found'; 
end
		
i = v(T_source(:,1)) & w(T_source(:,2));  
T_source = T_source(i,:); 
i = v(T_target_test(:,1)) & w(T_target_test(:,2));  
T_target_test = T_target_test(i,:); 

u_ids = find(v); 
v_ids = find(w) ; 

n1_new = sum(v); 
n2_new = sum(w); 

u_ids_new = zeros(n1,1);
v_ids_new = zeros(n2,1);

u_ids_new(u_ids) = (1:n1_new)';
v_ids_new(v_ids) = (1:n2_new)'; 

T_source(:,1) = u_ids_new(T_source(:,1));
T_source(:,2) = v_ids_new(T_source(:,2));
T_target_test(:,1) = u_ids_new(T_target_test(:,1));
T_target_test(:,2) = v_ids_new(T_target_test(:,2));

n1 = n1_new; 
n2 = n2_new; 

%
% Split between target and test set
%

fprintf(1, 'Split target/test set...\n'); 
lines_b = round(size(T_source,1) * (sqrt(1 + size(T_target_test,1) / size(T_source,1)) - 1)); 
T_target = T_target_test(1:lines_b, : );
T_test = T_target_test(1+lines_b:end, : );

%
% Zero test set
%

if info.weights == consts.UNWEIGHTED | info.weights == consts.POSITIVE

    % Adjacency matrix of training set
    A_bin = konect_spconvert([ T_source(:,1:2) ; T_target(:,1:2) ; T_test(:,1:2) ] , n1, n2); 
    A_bin = A_bin ~= 0; 
    if info.format == consts.SYM, A_bin = A_bin + A_bin'; A_bin = konect_absx(A_bin); end; 

    T_test_zero = zeros(0, 2); 
    lines_test = size(T_test,1)

    while size(T_test_zero,1) < lines_test
        % Generate new random node pairs
        T_test_zero_new = [ floor(rand(lines_test - size(T_test_zero,1), 1)*n1+1) , floor(rand(lines_test - size(T_test_zero,1), 1)*n2+1) ]; 

        % For undirected networks, convert all edges to (i,j) such that i <= j
        if info.format == consts.SYM 
            i = find(T_test_zero_new(:,1) > T_test_zero_new(:,2));
            tmp = T_test_zero_new(i, 1); 
            T_test_zero_new(i, 1) = T_test_zero_new(i, 2);
            T_test_zero_new(i, 2) = tmp; 
        end

        % Remove loops
        if info.format ~= consts.BIP
            i = T_test_zero_new(:,1) ~= T_test_zero_new(:,2); 
            T_test_zero_new = T_test_zero_new(i, :); 
        end

        % Compute new adjacency matrix
        A_test_zero = konect_spconvert([ T_test_zero ; T_test_zero_new ], n1, n2); 
    
        % Remove duplicate edges
        A_test_zero = 0 ~= A_test_zero; 
     
        % Remove edges already in the dataset
        A_test_zero_new = (A_test_zero - A_bin) > 0;

        % Convert back to E*2 format
        [x y] = find(A_test_zero_new);
        if size(x,1) <= size(T_test_zero, 1) % No new zero test edge were found
            T_test_zero = [ x , y ]; 
            if size(T_test_zero,1) == 0, error('No zero test edges found'); end
            break; % Use a smaller zero test set
        end

        T_test_zero = [ x , y ]; 

        if size(T_test_zero,1) > lines_test, error; end;
    end

else
    T_test_zero = []; 
end

%
% Save
%
fprintf(1, 'Save...\n'); 
save(['dat/split.' network '.mat'], '-v7.3', ...
     'n1', 'n2', 'T_source', 'T_target', 'T_test', 'T_test_zero', 'u_ids', 'v_ids'); 
