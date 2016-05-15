%
% Draw Zipf plots.  This is the transpose of the BIDD plot, i.e., of
% the cumulative degree distribution.  
% 
% PARAMETERS 
%	$network
%
% INPUT 
%	dat/data.$network.mat
%
% OUTPUT 
%	plot/zipf.[auv].$network.dat
%		a - total
%		u,v - Row/column based (only BIP and ASYM)
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
    
    zipf_one(T(:,1), q, 'u');
    konect_print(sprintf('plot/zipf.u.%s.eps', network)); 

    zipf_one(T(:,2), q, 'v'); 
    konect_print(sprintf('plot/zipf.v.%s.eps', network)); 
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

zipf_one(p, q, 'a'); 
konect_print(sprintf('plot/zipf.a.%s.eps', network)); 
