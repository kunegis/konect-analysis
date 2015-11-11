%
% Goodness of fit of all matrix decompositions in function of rank. 
%
% This test uses full matrices, so will only work for very small networks. 
%
% PARAMETERS 
%	$NETWORK
%
% OUTPUT 
%	dat/approximation.$NETWORK.mat
%		functions		Cell array of function names
%		prec			RMSE values
%			.(function).values(i_decomposition, r)
%		decompositions
%		names_decompositions
%
% INPUT 
%	dat/data.$NETWORK.mat
%	dat/info.$NETWORK
%	dat/meansi.$NETWORK.mat
%

r_max = 25; % Maximal rank
opts.disp = 2; 

decompositions = { 'svd', 'diag', 'dedicom1u', 'dedicom1v', 'dedicom2', 'dedicom3' }; 
functions = { 'e1', 'e2', 'a' }; 

network = getenv('NETWORK'); 

consts = konect_consts(); 

info = read_info(network); 
data = load(sprintf('dat/data.%s.mat', network)); 
means = load(sprintf('dat/meansi.%s.mat', network)); 

T = konct_normalize_additively(data.T, means); 
a = konect_spconvert(T, info.m, info.n); 

fprintf(1, 'Computing exponential 1...\n'); 
a_1 = expm(0.1 * a); 
fprintf(1, 'Computing exponential 2...\n'); 
a_2 = expm(0.03 * a); 
fprintf(1, 'Done.\n'); 

names_decompositions = []; 

labels_method = get_labels_method(); 

prec = struct(); 

a1 = T(:,1);
a2 = T(:,2);
if size(T,2) >= 3
  a3 = T(:,3);
else
  a3 = ones(size(T,1), 1); 
end

for i = 1 : length(decompositions)

  decomposition = decompositions{i}

  names_decompositions = [ names_decompositions ; cellstr(labels_method.(regexprep(decomposition, '-', '_'))) ]; 

  for r = 1 : r_max

    r

    [u d v] = konect_decomposition(decomposition, a, r, info.format, info.weights, opts); 

    for j = 1 : length(functions)
      f = functions{j};
      
      if strcmp(f, 'a')
        value = rmse_latent(a1, a2, a3, u, d, v); 
      elseif strcmp(f, 'e1')          
        value = rmse_full(a_1, u, expm(0.1 * d), v); 
      elseif strcmp(f, 'e2')          
        value = rmse_full(a_2, u, expm(0.2 * d), v); 
      end     
   
      prec.(f).values(i,r) = value; 
    end
  end

end

save(sprintf('dat/approximation.%s.mat', network), '-v7.3', 'functions', 'prec', 'decompositions', 'names_decompositions'); 
