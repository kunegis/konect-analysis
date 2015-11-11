%
% Generate assortativity plots. 
%
% PARAMETERS 
%	$NETWORK	Name of the network
%
% INPUT 
%	dat/data.$NETWORK.mat
%	dat/info.$NETWORK
%
% OUTPUT 
%	plot/assortativity.[auv].$NETWORK.eps
%

consts = konect_consts(); 

network = getenv('NETWORK');

data = load(sprintf('dat/data.%s.mat', network)); 
info = read_info(network); 

if info.weights == consts.POSITIVE & size(data.T, 2) >= 3
    w = data.T(:,3);
else
    w = 1; 
end

d_1 = sparse(data.T(:,1), 1, w, info.n1, 1);
d_2 = sparse(data.T(:,2), 1, w, info.n2, 1); 

A = sparse(data.T(:,1), data.T(:,2), w, info.n1, info.n2); 

if info.format == consts.ASYM
        
    assortativity_one(d_1, d_2, A, 'u', 'outdegree');
    konect_print(sprintf('plot/assortativity.u.%s.eps', network)); 
    
    assortativity_one(d_2, d_1, A', 'v', 'indegree');
    konect_print(sprintf('plot/assortativity.v.%s.eps', network)); 

elseif info.format == consts.BIP

    assortativity_one(d_1, d_2, A, 'u', 'left degree');
    konect_print(sprintf('plot/assortativity.u.%s.eps', network)); 
    
    assortativity_one(d_2, d_1, A', 'v', 'right degree');
    konect_print(sprintf('plot/assortativity.v.%s.eps', network)); 

end

if info.format == consts.BIP

    dd = [ d_1 ; d_2 ];

    assortativity_one(dd, dd, ...
                      [ sparse(info.n1, info.n1) A ; A' sparse(info.n2, info.n2) ], ...
                      'a', 'degree');
    konect_print(sprintf('plot/assortativity.a.%s.eps', network)); 

else

    dd = d_1 + d_2; 
    assortativity_one(dd, dd, A + A', 'a', 'degree'); 
    konect_print(sprintf('plot/assortativity.a.%s.eps', network)); 

end
