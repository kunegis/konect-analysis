%
% Diagonality plots.
%
% PARAMETERS 
%	$NETWORK
%	$DECOMPOSITION
%
% INPUT 
%	dat/decomposition_split.{source,training}.$DECOMPOSITION.$NETWORK.mat
%	dat/decomposition_split.training.sym.$NETWORK.mat 	
%	dat/split.$NETWORK.mat
%	dat/means.$NETWORK.mat
%	dat/info.$NETWORK
%
% OUTPUT 
%	plot/diagonality.{self,base}.[a].$DECOMPOSITION.$NETWORK.eps
%		a - Spectral diagonality test
%		b - Complex variant 
%	plot/permutation.{self,base}.[auv].$DECOMPOSITION.$NETWORK.eps 
%		self	Between the two same decompositions 
%		base 	Between this decomposition and SYM  (only A in this case)
%		a	full comparison
%		u	Left/outlinks (BIP/ASYM)
%		v	Right/inlinks (BIP/ASYM)
%

consts = konect_consts(); 

network = getenv('NETWORK');
decomposition = getenv('DECOMPOSITION'); 

info = read_info(network); 

decomposition_source = load(sprintf('dat/decomposition_split.source.%s.%s.mat', decomposition, network));
decomposition_training = load(sprintf('dat/decomposition_split.training.%s.%s.mat', decomposition, network));

decomposition_base = load(sprintf('dat/decomposition_split.training.sym.%s.mat', network)); 

split = load(sprintf('dat/split.%s.mat', network)); 

means = load(sprintf('dat/means.%s.mat', network)); 

T_target = konect_normalize_additively(split.T_target, means); 

A_target = konect_spconvert(T_target, split.n1, split.n2); 


%
% (permutation.self) - Permutation plot between the same decomposition type
%

if prod(size(decomposition_source.V)) == 0

    evol_permutation(decomposition_source.U, decomposition_training.U); 
    konect_print(sprintf('plot/permutation.self.a.%s.%s.eps', decomposition, network)); 

else

    evol_permutation([decomposition_source.U ; decomposition_source.V], ...
                     [decomposition_training.U ; decomposition_training.V]); 
    konect_print(sprintf('plot/permutation.self.a.%s.%s.eps', decomposition, network)); 

    evol_permutation(decomposition_source.U, decomposition_training.U); 
    konect_print(sprintf('plot/permutation.self.u.%s.%s.eps', decomposition, network)); 
  
    evol_permutation(decomposition_source.V, decomposition_training.V); 
    konect_print(sprintf('plot/permutation.self.v.%s.%s.eps', decomposition, network)); 

end

%
% (permutation.base) - Permutation plot between this and the base decomposition at training time
%

size_source_u = size(decomposition_source.U)
size_source_v = size(decomposition_source.V)
size_base_u = size(decomposition_base.U)
size_base_v = size(decomposition_base.V)

if prod(size(decomposition_source.V)) == 0
    evol_permutation(decomposition_source.U, decomposition_base.U); 
else
    if prod(size(decomposition_base.V))
        evol_permutation([decomposition_source.U ; decomposition_source.V], ...
                         [decomposition_base.U ; decomposition_base.V]);
    else
        evol_permutation([decomposition_source.U ; decomposition_source.V], ...
                         [decomposition_base.U ; decomposition_base.U]);
    end
end

konect_print(sprintf('plot/permutation.base.a.%s.%s.eps', decomposition, network)); 


%
% (a.self) - Spectral diagonality test with own prepared matrix 
%

Delta = spectral_diagonality_test(decomposition, decomposition_source, A_target, info.format, 1); 

konect_imageubu(Delta);
konect_print(sprintf('plot/diagonality.self.a.%s.%s.eps', decomposition, network)); 

konect_imageubu_complex(Delta);
konect_print(sprintf('plot/diagonality.self.b.%s.%s.eps', decomposition, network)); 



%
% (a.base) - Spectral diagonality test
%

Delta = spectral_diagonality_test(decomposition, decomposition_source, A_target, info.format, 0); 

konect_imageubu(Delta);
konect_print(sprintf('plot/diagonality.base.a.%s.%s.eps', decomposition, network)); 

konect_imageubu_complex(Delta);
konect_print(sprintf('plot/diagonality.base.b.%s.%s.eps', decomposition, network)); 
