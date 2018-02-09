%
% Perform sanity checks on a network.  This does exit(0) even when the
% tests fail -- the test results are only stored in the output files. 
%
% PARAMETERS 
%	$network	The network to check
%
% INPUT FILES 
%	uni/out.$network
%
% OUTPUT FILES
%	dat/check.$network		'1' or '0' depending on test result
%	dat/check_error.$network	Error message, if failed ; on success, the file is removed 
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

%
% Check correctness of the meta file
%

mandatory_fields = {'name', 'code', 'category'};
for i = 1 : length(mandatory_fields)
  f = mandatory_fields{i}; 
  if ~isfield(meta, f)
    check_failed(sprintf('*** Missing field "%s" in meta file', f)); 
  end
end

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

% If 'entity-names' is present and the network is bipartite, there must
% be two entity names given, i.e., a comma is present.
if isfield(meta, 'entity_names')
  if format == consts.BIP
    if sum(meta.entity_names == ',') ~= 1
      check_failed('*** Field entity-names must contain two entity names in bipartite network'); 
    end
  else
    if sum(meta.entity_names == ',') ~= 0
      check_failed('*** Field entity-names must contain only a single entity name'); 
    end
  end
end

%
% Load data
%

T = load(sprintf('uni/out.%s', network));
% T stays constant throughout the whole run, but A and similar matrices
% are computed for each test separately.

%
% Check that the category exists
%

category = meta.category;

[colors] = konect_data_category(); 

color = colors.(category);

if ~(length(color) == 3)
  check_failed(sprintf('*** Category %s does not exist', category));
end

%
% Check the presence and number range of the third column.
%

if weights == consts.UNWEIGHTED

  % Third column must be absent or constant ones.
  if size(T, 2) ~= 2
    i = find(T(:,3) ~= 1);
    if length(i) ~= 0
      check_failed(sprintf('*** UNWEIGHTED network must not have edge weight:  w(%u, %u) = %g', ...
			   T(i(1),1), T(i(1), 2), T(i(1), 3)));
    end
  end

elseif weights == consts.POSITIVE

    % Third column must be absent or positive integers
    if size(T, 2) ~= 2
        i = find(T(:,3) <= 0);
        if length(i) ~= 0
          check_failed(sprintf('*** POSITIVE network must not have negative edge weights: w(%u, %u) = %g', ...
			       T(i(1),1), T(i(1), 2), T(i(1), 3)));
        end
        i = find(T(:,3) ~= floor(T(:,3)));
        if length(i) ~= 0
          check_failed(sprintf('*** POSITIVE network must not have fractional edge weights: w(%u, %u) = %g', ...
			       T(i(1),1), T(i(1), 2), T(i(1), 3)));
        end
    end

elseif weights == consts.POSWEIGHTED

    % Third column must be positive
    if size(T, 2) <= 2
      check_failed('*** POSWEIGHTED network must have edge weights');
    end
    i = find(T(:,3) < 0);
    if length(i) ~= 0
      check_faild(sfprintf('*** POSWEIGHTED network must not have negative edge weights: w(%u, %u) = %g', ...
			   T(i(1),1), T(i(1), 2), T(i(1), 3)));
    end

elseif weights == consts.SIGNED | weights == consts.MULTISIGNED

    % Third column must be present, and at least one edge must have a negative weight
    if size(T, 2) <= 2
      check_failed('*** SIGNED or MULTISIGNED network must have edge weights');
    end
    i = find(T(:,3) < 0);
    if length(i) <= 0
        check_failed('*** SIGNED or MULTISIGNED network must have at least one negative edge'); 
    end

elseif weights == consts.WEIGHTED | weights == consts.MULTIWEIGHTED

    % Third column must be present, and must not consist of all-equal values
    if size(T, 2) <= 2
      check_failed('*** WEIGHTED/MULTIWEIGHTED network must have edge weights'); 
    end
    i = find(T(:,3) ~= mean(T(:,3)));
    if length(i) <= 0
      check_failed('*** WEIGHTED/MULTIWEIGHTED network must not have all-equal edge weights'); 
    end

elseif weights == consts.DYNAMIC

    % Third column must be present and consist of -1/+1
    if size(T, 2) <= 2
        check_failed('*** DYNAMIC network must have weights');
    end
    i = find(abs(T(:,3)) ~= 1);
    if length(i) ~= 0
        check_failed(sprintf('*** DYNAMIC network must have +1/-1 weights:  w(%u, %u) = %g', ...
			     T(i(1),1), T(i(1), 2), T(i(1), 3))); 
    end

else
    check_failed('*** Invalid format'); 
end

%
% Zero edge weights
%

if weights == consts.POSWEIGHTED | weights == consts.SIGNED | ...
            weights == consts.MULTISIGNED
    if tag_zeroweight
      if ~(size(T,2) >= 3)
	check_failed('*** Missing edge weights for POSWEIGHTED/SIGNED network');
      end
      if ~(sum(T(:,3) == 0) > 0)
	check_failed('*** #zeroweight network does not contain zero-weighted edge');
      end
    else
        if size(T,2) >= 3
            i = find(T(:,3) == 0);
            if length(i) ~= 0
                check_failed(sprintf('*** Network must not have zero edge weights when #zeroweight is not set: w(%u, %u) = %g', T(i(1),1), T(i(1),2), T(i(1),3))); 
            end
        end
    end
else
  if tag_zeroweight
    check_failed('*** #zeroweight used although network is not POSWEIGHTED/SIGNED/MULTISIGNED');
  end
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
        check_failed(sprintf('*** Duplicate entry (%d, %d) and (%d, %d) although network is SYM and should have no multiple edges', x(1), y(1), y(1), x(1))); 
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
        check_failed(sprintf('*** Invalid multiple edge (%u, %u); multiplicity = %u, number of multiply-connected node pairs = %u, max multiplicity = %u, although network should be without multiple edges', x(i(1)), y(i(1)), z(i(1)), nnz(i > 0), max(z))); 
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
        check_failed('*** SYM/ASYM network is actually bipartite'); 
    end
end

%
% In unipartite networks, loops are only allowed when the tag #loop
% is given.  If #loop is set, there must be at least one loop. 
%

if format == consts.BIP
  if tag_loop
    check_failed('*** Bipartite network must not be declared as #loop');
  end
else

    % Find loops
    loops = T(:,1) == T(:,2);
    count_loops = sum(loops); 

    if tag_loop
      if ~(count_loops > 0)
	check_failed('*** No loop found although #loop is set');
      end
    else
        if count_loops ~= 0
            i = find(loops); i = i(1); 
            check_failed(sprintf('*** Loop (%d,%d) detected although #loop is not set; total loop count = %u', i, i, count_loops)); 
        end
    end
end

%
% #acyclic and #loop must not be used together
%

if tag_acyclic & tag_loop
    check_failed('*** #acyclic and #loop must not be used together'); 
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
            check_failed(sprintf('*** Acyclic or network must not contain reciprocal edges, found %u <-> %u', ...
				 x(1), y(1))); 
        end

    else
        if ~(count_reciprocal > 0)
          check_failed('*** Non-acyclic and non-nonreciprocal directed network must contain at least one reciprocal edge, but does not'); 
	end
    end
else
  if tag_acyclic
    check_failed('*** Tag #acyclic must not be set for non-directed networks');
  end
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
      if ~(sum(cc) == 1)
	check_failed('*** Network contains directed cycle though declared as #acyclic');
      end
    else
      if ~(sum(cc) > 1)
	check_failed('*** Network does not contain cycle although #acyclic is not set');
      end
    end
else
  if tag_acyclic
    check_failed('*** Tag #acyclic can only be used for directed networks');
  end
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
      check_failed(sprintf('*** Network with multiple edges must have maximal multiplicity at least 3 (w = %u)', w)); 
    end
end

%
% Check that the network is connected
%

if tag_lcc
  if ~tag_incomplete
    check_failed('*** #incomplete is not set although #lcc is set');
  end
  A = sparse(T(:,1), T(:,2), 1, n1, n2);
  values = konect_statistic_coco(A, format, weights); 
  if format == consts.BIP
    if ~(values(1) == n1 + n2)
      check_failed('*** Network is not connected although #lcc is set');
    end
  else
    if ~(n1 == n2)
      check_failed('*** Matrix must be square');
    end
    if ~(values(1) == n1)
      check_failed('*** Network is not connected although #lcc is set');
    end
  end
  if ~(values(2) == 1.0)
    check_failed('*** Network must be connected');
  end
end

%
% If #tournament is defined, then the graph is directed
% #nonreciprocal is defined, #loop is not defined, and the graph is a tournament. 
%

if tag_tournament
  if ~(format == consts.ASYM)
    check_failed('*** Tournament must be ASYM');
  end
  if ~tag_nonreciprocal
    check_failed('*** Tournament must be nonreciprocal');
  end
  if tag_loop
    check_failed('*** Tournament must not have loops'); 
  end

  % Ignore edge weights 
  n = max(max(T(:,1:2))); 
  A = sparse(T(:,1), T(:,2), 1, n, n); 
  if ~(nnz(A) * 2 == n * (n - 1))
    check_failed('*** Tournament must be a complete graph');
  end
  A_sym = A | A';
  if ~(nnz(A_sym) == n * (n - 1))
    check_failed('*** Tournament must be a complete graph'); 
  end
end

%
% If the network is unipartite, there must be at least one triangle,
% except when #trianglefree is set, in which case the network must be
% triangle-free.  For bipartite networks, #trianglefree must not be
% used. 
%

if format == consts.BIP
  if tag_trianglefree
    check_failed('*** The tag #trianglefree must only be used with unipartite networks');
  end
else
  n = max(max(T(:,1:2))); 
  A = sparse(T(:,1), T(:,2), 1, n, n);
  % Note:  the konect_statistic_triangles() takes care of ignoring
  % multiple edges and loops. 
  values = konect_statistic_triangles(A, consts.SYM, consts.UNWEIGHTED);
  n_triangles = values(1);
  if tag_trianglefree
    if ~(n_triangles == 0)
      check_failed(sprintf('*** Network must not contain triangles because #trianglefree is set, number of triangles = %u', ...
			   n_triangles));
    end
  else
    if ~(n_triangles >= 1)
      check_failed('*** Unipartite network must have at least one triangle, except when #trianglefree is set');
    end
  end
end

check_successful();
