%
% Draw a graph layout of one network.
%
% PARAMETERS 
%	$network
%
% INPUT FILES 
%	dat/data.$network.mat
%
% OUTPUT FILES 
%	plot/layout.tmp.a.$network.png
%

network = getenv('network'); 

consts = konect_consts(); 

info = read_info(network); 

data = load(sprintf('dat/data.%s.mat', network));

A = sparse(data.T(:,1), data.T(:,2), 1, info.n1, info.n2);

if info.format == consts.SYM | info.format == consts.ASYM

    A = A | A';

elseif info.format == consts.BIP

    A = [sparse(info.n1, info.n1), A; A', sparse(info.n2, info.n2)];

else
    error('*** Invalid format');
end
'aaa'
X = fruchterman_reingold_force_directed_layout(A);
'bbb'
gplot2(A, X, 'o-', ...
       'MarkerFaceColor', [0 0 0], 'MarkerEdgeColor', [0 0 0]);
'ccc'
axis off; 
'ddd'
konect_print_bitmap(sprintf('plot/layout.tmp.a.%s.png', network));
'eee'
