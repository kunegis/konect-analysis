%
% Draw the Lorenz curve for a network's degree distribution.
%
% PARAMETERS 
%	$NETWORK
%
% INPUT 
%	dat/data.$NETWORK.mat
%
% OUTPUT 
%	plot/lorenz.[uva]{,b}.$NETWORK.dat
%		a - total 
%		u,v - Row/column-based (only BIP and ASYM)
%		b - Bare, i.e. without the P value
%

network = getenv('NETWORK'); 

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

    lorenz_one(T(:,1), q, 0, 'u');
    konect_print(sprintf('plot/lorenz.u.%s.eps', network)); 
    lorenz_one(T(:,1), q, 1, 'u');
    konect_print(sprintf('plot/lorenz.ub.%s.eps', network)); 
    
    lorenz_one(T(:,2), q, 0, 'v'); 
    konect_print(sprintf('plot/lorenz.v.%s.eps', network)); 
    lorenz_one(T(:,2), q, 1, 'v'); 
    konect_print(sprintf('plot/lorenz.vb.%s.eps', network)); 
end


%
% A
%

if info.format == consts.BIP
    m = max(T(:,1)); 
    
    p = [ T(:,1) ; T(:,2)+m ]; 
    if size(T,2) >= 3
        q = [ T(:,3) ; T(:,3) ]; 
    else  
        q = []; 
    end
else
    p = [ T(:,1) ; T(:,2) ]; 
    if size(T,2) >= 3
        q = [ T(:,3) ; T(:,3) ]; 
    else  
        q = []; 
    end
end

lorenz_one(p, q, 0, 'a'); 
konect_print(sprintf('plot/lorenz.a.%s.eps', network)); 
lorenz_one(p, q, 1, 'a'); 
konect_print(sprintf('plot/lorenz.ab.%s.eps', network)); 
