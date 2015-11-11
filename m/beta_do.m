%
% Draw the binormalized degree distributions. 
%
% This file is not called beta.m because of the builtin function
% beta(). 
%
% PARAMETERS 
%	$NETWORK
%
% INPUT 
%	dat/data.$NETWORK.mat
%
% OUTPUT 
%	plot/beta.[auv]{,x}.$NETWORK.dat
%		a/u/v - All / left / right
%		"" / "x" - Normalized / non-normalized
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

    beta_one(T(:,1), q, 'u');
    konect_print(sprintf('plot/beta.u.%s.eps', network)); 

    beta_one(T(:,2), q, 'v'); 
    konect_print(sprintf('plot/beta.v.%s.eps', network)); 

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

beta_one(p, q, 'a'); 
konect_print(sprintf('plot/beta.a.%s.eps', network)); 
