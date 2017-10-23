%
% Draw the cumulated degree distributions.
%
% The name "bidd" is historical and refers to "binormalized degree
% distribution".  Normalization is just one aspect of it now. 
%
% PARAMETERS 
%	$network	Internal name of the network 
%
% INPUT FILES 
%	dat/data.$network.mat
%
% OUTPUT FILES 
%	plot/bidd.{a,u,v,uv}{,x}.$network.eps
%		a/u/v/uv - All / left / right / overlay left and right
%		"" / "x" - Normalized / non-normalized
%

network = getenv('network');

data = load(sprintf('dat/data.%s.mat', network)); 

T = data.T; 

consts = konect_consts(); 

info = read_info(network); 

if info.weights ~= consts.POSITIVE & size(T,2) >= 3
    T(:,3:end) = []; 
end

%
% U, V
%
if info.format ~= consts.SYM

    if size(T,2) >= 3
        q = T(:,3);
    else
        q = []; 
    end

    if info.format == consts.ASYM
        name_u = 'Outdegree';
        name_v = 'Indegree';
        symbol_u = 'd^+';
        symbol_v = 'd^-';
    elseif info.format == consts.BIP
        name_u = 'Left degree';
        name_v = 'Right degree';
        symbol_u = 'd';
        symbol_v = 'd';
    end

    bidd_one(T(:,1), q, 1, 'u', name_u, symbol_u, 1);
    konect_print(sprintf('plot/bidd.u.%s.eps', network)); 

    bidd_one(T(:,2), q, 1, 'v', name_v, symbol_v, 1); 
    konect_print(sprintf('plot/bidd.v.%s.eps', network)); 

    bidd_one(T(:,1), q, 0, 'u', name_u, symbol_u, 1);
    konect_print(sprintf('plot/bidd.ux.%s.eps', network)); 

    bidd_one(T(:,2), q, 0, 'v', name_v, symbol_v, 1); 
    konect_print(sprintf('plot/bidd.vx.%s.eps', network)); 

    hold on; 

    if info.format == consts.ASYM
      bidd_one(T(:,1), q, 1, 'u', 'Degree', 'd^{\pm}', 1);
      bidd_one(T(:,2), q, 1, 'v', 'Degree', 'd^{\pm}', 2);
    elseif info.format == consts.BIP
      bidd_one(T(:,1), q, 1, 'u', 'Degree', 'd', 1);
      bidd_one(T(:,2), q, 1, 'v', 'Degree', 'd', 2);
    end

    if info.format == consts.ASYM
        legend('Outdegree', 'Indegree', 'Location', 'SouthWest'); 
    elseif info.format == consts.BIP
        legend('Left vertices', 'Right vertices', 'Location', 'SouthWest'); 
    end
    konect_print(sprintf('plot/bidd.uv.%s.eps', network)); 

    hold on; 

    bidd_one(T(:,1), q, 0, 'u', 'Degree', 'd^{\pm}', 1);
    bidd_one(T(:,2), q, 0, 'v', 'Degree', 'd^{\pm}', 2); 

    if info.format == consts.ASYM
        legend('Outdegree', 'Indegree', 'Location', 'SouthWest'); 
    elseif info.format == consts.BIP
        legend('Left vertices', 'Right vertices', 'Location', 'SouthWest'); 
    end
    konect_print(sprintf('plot/bidd.uvx.%s.eps', network)); 
end


%
% A
%

p = [ T(:,1) ; T(:,2) ]; 
if size(T,2) >= 3
    q = [ T(:,3) ; T(:,3) ]; 
else  
    q = []; 
end

bidd_one(p, q, 1, 'a', 'Degree', 'd', 1); 
konect_print(sprintf('plot/bidd.a.%s.eps', network)); 

bidd_one(p, q, 0, 'a', 'Degree', 'd', 1); 
konect_print(sprintf('plot/bidd.ax.%s.eps', network)); 
