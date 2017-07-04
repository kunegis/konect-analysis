%
% Perform sanity checks on a network.
%
% PARAMETERS 
%	$network	The network to check
%
% INPUT 
%	uni/out.$network
%

network = getenv('network');

consts = konect_consts(); 

meta = read_meta(network); 

tags = get_tags(meta); 

tag_acyclic         = isfield(tags, 'acyclic')
tag_incomplete      = isfield(tags, 'incomplete')
tag_lcc             = isfield(tags, 'lcc')
tag_loop            = isfield(tags, 'loop')
tag_lowmultiplicity = isfield(tags, 'lowmultiplicity')
tag_nonreciprocal   = isfield(tags, 'nonreciprocal')
tag_tournament      = isfield(tags, 'tournament') 
tag_trianglefree    = isfield(tags, 'trianglefree'); 
tag_zeroweight      = isfield(tags, 'zeroweight')


format = load(sprintf('dat/statistic.format.%s', network));
weights = load(sprintf('dat/statistic.weights.%s', network));

n_values = load(sprintf('dat/statistic.size.%s', network));
lines = load(sprintf('dat/statistic.lines.%s', network));

if format == consts.SYM || format == consts.ASYM
    n1 = n_values(1);
    n2 = n_values(1); 
else
    n1 = n_values(2);
    n2 = n_values(3); 
end

T = load(sprintf('uni/out.%s', network));
% T stays constant throughout the whole run, but A and similar matrices
% are computed for each test separately.

%
% Check that the category exists
%

category = meta.category;

[colors] = konect_data_category(); 

color = colors.(category);
assert(length(color) == 3, '*** Category %s does not exist', category); 

%
% Check the presence and number range of the third column.
%

if weights == consts.UNWEIGHTED

    % Third column must be absent or constant ones.
    if size(T, 2) ~= 2
        i = find(T(:,3) ~= 1);
        if length(i) ~= 0
            error(sprintf('*** UNWEIGHTED network must not have edge weight:  w(%u, %u) = %g', ...
                          T(i(1),1), T(i(1), 2), T(i(1), 3))); 
        end
    end

elseif weights == consts.POSITIVE

    % Third column must be absent or positive integers
    if size(T, 2) ~= 2
        i = find(T(:,3) <= 0);
        if length(i) ~= 0
            error(sprintf('*** POSITIVE network must not have negative edge weights: w(%u, %u) = %g', ...
                          T(i(1),1), T(i(1), 2), T(i(1), 3)));
        end
        i = find(T(:,3) ~= floor(T(:,3)));
        if length(i) ~= 0
            error(sprintf('*** POSITIVE network must not have fractional edge weights: w(%u, %u) = %g', ...
                          T(i(1),1), T(i(1), 2), T(i(1), 3))); 
        end
    end

elseif weights == consts.POSWEIGHTED

    % Third column must be positive
    if size(T, 2) <= 2
        error('*** POSWEIGHTED network must have edge weights'); 
    end
    i = find(T(:,3) < 0);
    if length(i) ~= 0
        error(sprintf('*** POSWEIGHTED network must not have negative edge weights: w(%u, %u) = %g', ...
                      T(i(1),1), T(i(1), 2), T(i(1), 3))); 
    end

elseif weights == consts.SIGNED | weights == consts.MULTISIGNED

    % Third column must be present, and at least one edge must have a negative weight
    if size(T, 2) <= 2
        error('*** SIGNED or MULTISIGNED network must have edge weights'); 
    end
    i = find(T(:,3) < 0);
    if length(i) <= 0
        error('*** SIGNED or MULTISIGNED network must have at least one negative edge'); 
    end

elseif weights == consts.WEIGHTED | weights == consts.MULTIWEIGHTED

    % Third column must be present, and must not consist of all-equal values
    if size(T, 2) <= 2
        error('*** WEIGHTED/MULTIWEIGHTED network must have edge weights'); 
    end
    i = find(T(:,3) ~= mean(T(:,3)));
    if length(i) <= 0
        error('*** WEIGHTED/MULTIWEIGHTED network must not have all-equal edge weights'); 
    end

elseif weights == consts.DYNAMIC

    % Third column must be present and consist of -1/+1
    if size(T, 2) <= 2
        error('*** DYNAMIC network must have weights');
    end
    i = find(abs(T(:,3)) ~= 1);
    if length(i) ~= 0
        error(sprintf('*** DYNAMIC network must have +1/-1 weights:  w(%u, %u) = %g', ...
                      T(i(1),1), T(i(1), 2), T(i(1), 3))); 
    end

else
    error('*** Invalid format'); 
end

%
% Zero edge weights
%

if weights == consts.POSWEIGHTED | weights == consts.SIGNED | ...
            weights == consts.MULTISIGNED
    if tag_zeroweight
        assert(size(T,2) >= 3, '*** Missing edge weights for POSWEIGHTED/SIGNED network'); 
        assert(sum(T(:,3) == 0) > 0, '*** #zeroweight network does not contain zero-weighted edge');
    else
        if size(T,2) >= 3
            i = find(T(:,3) == 0);
            if length(i) ~= 0
                error(sprintf('*** Network must not have zero edge weights when #zeroweight is not set: w(%u, %u) = %g', T(i(1),1), T(i(1),2), T(i(1),3))); 
            end
        end
    end
else
    assert(~tag_zeroweight, '*** #zeroweight used although network is not POSWEIGHTED/SIGNED/MULTISIGNED'); 
end

%
% In undirected networks without multiple edges, no edge must be
% included twice in different orientations. 
%
if format == consts.SYM & (weights == consts.UNWEIGHTED | ...
                                weights == consts.SIGNED | ...
                                weights == consts.WEIGHTED | ...
                                weights == consts.POSWEIGHTED)

    T12 = T(:,1:2);

    n = max(max(T12));

    A = sparse(T12(:,1), T12(:,2), 1, n, n);

    A_sym = A & A';
    A_sym_noloop = A_sym - (A_sym & speye(n)); 

    if nnz(A_sym_noloop) ~= 0
        [x y z] = find(A_sym_noloop, 1);
        error(sprintf('*** Duplicate entry (%d, %d) and (%d, %d) although network is SYM and should have no multiple edges', x(1), y(1), y(1), x(1))); 
    end

end

%
% In unipartite networks without multiple edges, no edge must be
% included twice. 
%
if weights == consts.UNWEIGHTED | ...
        weights == consts.SIGNED | ...
        weights == consts.WEIGHTED | ...
        weights == consts.POSWEIGHTED

    T12 = T(:,1:2);

    n = max(max(T12));

    A = sparse(T12(:,1), T12(:,2), 1, n, n);

    [x y z] = find(A);
    i = find(z ~= 1);
    if length(i > 0)
        error(sprintf('*** Invalid multiple edge (%u, %u); multiplicity = %u, number of multiply-connected node pairs = %u, max multiplicity = %u, although network should be without multiple edges', x(i(1)), y(i(1)), z(i(1)), nnz(i > 0), max(z))); 
    end

end

%
% In unipartite networks, at least one node must be present in the
% left AND right column.  If this is not the case, the network is
% actually bipartite. 
%

if format == consts.SYM | format == consts.ASYM

    n = max(max(T(:,1:2))); 

    v1 = sparse(T(:,1), 1, 1, n, 1);
    v2 = sparse(T(:,2), 1, 1, n, 1);

    v1 = (v1 ~= 0);
    v2 = (v2 ~= 0); 

    v = v1 & v2;

    if sum(v) <= 0
        error('*** SYM/ASYM network is actually bipartite'); 
    end

end

%
% In unipartite networks, loops are only allowed when the tag #loop
% is given.  If #loop is set, there must be at least one loop. 
%

if format == consts.BIP
    assert(~tag_loop, '*** Bipartite network must not be declared as #loop'); 
else

    % Find loops
    loops = T(:,1) == T(:,2);
    count_loops = sum(loops); 

    if tag_loop
        assert(count_loops > 0, '*** No loop found although #loop is set'); 
    else
        if count_loops ~= 0
            i = find(loops); i = i(1); 
            error('*** Loop (%d,%d) detected although #loop is not set', i, i); 
        end
    end
end

%
% #acyclic and #loop must not be used together
%

if tag_acyclic & tag_loop
    error('*** #acyclic and #loop must not be used together'); 
end

%
% If a network is ASYM, it must contain at least one pair of
% reciprocal edges, except when #acyclic or #nonreciprocal is
% defined. 
%

if format == consts.ASYM 
    
    n = n_values(1); 

    A = sparse(T(:,1), T(:,2), 1, n, n); 

    A_reciprocal= A .* A';

    count_reciprocal= nnz(A_reciprocal)
    
    if tag_acyclic | tag_nonreciprocal

        if count_reciprocal ~= 0
            
            [x y z] = find(A_reciprocal); 
            error(sprintf('*** Acyclic or network must not contain reciprocal edges, found %u <-> %u', ...
                          x(1), y(1))); 
        end

    else

        assert(count_reciprocal > 0, ...
               '*** Non-acyclic and non-nonreciprocal directed network must contain at least one reciprocal edge, but does not'); 

    end
else
    assert(~tag_acyclic, '*** Tag #acyclic must not be set for non-directed networks'); 
end

%
% If a directed network is declared as #acyclic, it must not
% contain cycles.  If #acyclic is not set, there must be a cycle. 
%

if format == consts.ASYM

    %    n = info.n_; 
    n = n_values(1);
    A = sparse(T(:,1), T(:,2), 1, n, n); 

    % Find the largest strongly connected component. 
    cc = konect_connect_strong(A);
    assert(sum(cc) >= 1); 

    if tag_acyclic
        % Size of largest strongly connected component must be one. 
        assert(sum(cc) == 1, '*** Network contains directed cycle though declared as #acyclic'); 
    else
        assert(sum(cc) > 1, '*** Network does not contain cycle although #acyclic is not set'); 
    end

else
    
    assert(~tag_acyclic, '*** Tag #acyclic can only be used for directed networks'); 

end

%
% Networks in which multiple edges should have edges with
% multiplicity > 2.  A maximal multiplicity of two is an indication
% of an erroneous extraction.  
%

if weights == consts.POSITIVE | weights == consts.MULTIWEIGHTED ...
        | weights == consts.DYNAMIC

    if weights == consts.POSITIVE & size(T,2) == 3
        A = sparse(T(:,1), T(:,2), T(:,3), n1, n2); 
    else
        A = sparse(T(:,1), T(:,2), 1, n1, n2); 
    end

    if format == consts.SYM
        A = A + A';
    end

    % Exclude loops from that calculation
    if format == consts.SYM || format == consts.ASYM
        A = A - spdiags(diag(A), [0], n1, n1);
    end

    w = full(max(max(A)))

    if w < 3 & tag_lowmultiplicity == 0
        if w == 2
            % Number of times the maximum of 2 appears
            c = sum(sum(A == 2));
            fprintf(2, '\tMaximum of 2 appears %u times\n', c); 
        end
        fprintf(2, '*** Network with multiple edges must have maximal multiplicity at least 3 (w = %u)\n', w); 
        exit(1); 
        assert(false); 
    end
end

%
% Check that the network is connected
%

if tag_lcc
    assert(tag_incomplete, '*** #incomplete is not set although #lcc is set'); 
    A = sparse(T(:,1), T(:,2), 1, n1, n2);
    values = konect_statistic_coco(A, format, weights); 
    if format == consts.BIP
        assert(values(1) == n1 + n2, ...
               '*** Network is not connected although #lcc is set');
    else
        assert(n1 == n2); 
        assert(values(1) == n1, ...
               '*** Network is not connected although #lcc is set');
    end
    assert(values(2) == 1.0); 
end

%
% If #tournament is defined, then the graph is directed
% #nonreciprocal is defined, #loop is not defined, and the graph is a tournament. 
%

if tag_tournament
    assert(format == consts.ASYM); 
    assert(tag_nonreciprocal);
    assert(! tag_loop); 

    % Ignore edge weights 
    n = max(max(T(:,1:2))); 
    A = sparse(T(:,1), T(:,2), 1, n, n); 
    assert(nnz(A) * 2 == n * (n - 1));
    A_sym = A | A';
    assert(nnz(A_sym) == n * (n - 1)); 
end

%
% If the network is unipartite, there must be at least one triangle.  
%

if format ~= consts.BIP
  if ~tag_trianglefree
    n = max(max(T(:,1:2))); 
    A = sparse(T(:,1), T(:,2), 1, n, n);
    % Note:  the konect_statistic_triangles() takes care of ignoring
    % multiple edges and loops. 
    values = konect_statistic_triangles(A, consts.SYM, consts.UNWEIGHTED);
    assert(values(1) >= 1, '*** Unipartite network must have at least one triangle, except when #trianglefree is set');
  end
else
  if tag_trianglefree
    assert(0, '*** The tag #trianglefree must only be used with unipartite networks'); 
  end
end
