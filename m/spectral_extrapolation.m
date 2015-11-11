%
% Visualization of the spectral extrapolation method.
%
% PARAMETERS 
%	$NETWORK
%	$DECOMPOSITION
% 
% INPUT 
%	dat/decomposition_time.split.$DECOMPOSITION.$NETWORK.mat
%	dat/steps.$NETWORK.mat
% 
% OUTPUT 
%	plot/spectral_extrapolation.$DECOMPOSITION.$NETWORK.eps 
%

marker_size = 10; 

network = getenv('NETWORK');
decomposition = getenv('DECOMPOSITION'); 

data_decomposition = load(sprintf('dat/decomposition_time.split.%s.%s.mat', decomposition, network)); 
steps_data = load(sprintf('dat/steps.%s.mat', network)); 

decompositions = data_decomposition.decompositions; 
r = data_decomposition.r; 

steps_source = steps_data.steps_source; 
steps_training = steps_data.steps_source + steps_data.steps_target; 
steps_all = steps_data.steps_all; 
e_steps = steps_data.e_steps; 

is_asymmetric = size(decompositions(end).V); 


%
% Spectrum over time
%

hold on;

for k = 1 : r
    spectrum = zeros(prod(size(e_steps)),1); 
    
    for l = 1 : prod(size(decompositions))
        % Each decomposition may have a different size.  
        if k <= size(decompositions(l).D, 1)
            spectrum(l) = decompositions(l).D(k,k);
        else
            spectrum(l) = NaN; % No k'th eigenvalue at this timepoint
        end
    end

    spectrum = spectrum_visualize(spectrum, decomposition); 

    plot(e_steps, spectrum, '.b', 'MarkerSize', marker_size); 
end


%
% Extrapolation lines 
%
D_source = decompositions(steps_source).D;
U_source = decompositions(steps_source).U; 
V_source = decompositions(steps_source).V; 

D_target = decompositions(steps_training).D; 
U_target = decompositions(steps_training).U;
V_target = decompositions(steps_training).V; 

dd_diff_squ = sne(U_source, diag(D_source), V_source, U_target, diag(D_target), V_target, @(x)(x)); 

dd_new_squ = dd_diff_squ + diag(D_target) 

dd_old_squ = - dd_diff_squ + diag(D_target)

for k = 1 : r
    if size(D_target, 1) >= k
        plot(steps_data.e_steps([steps_source steps_training steps_all]), ...
             real([dd_old_squ(k) D_target(k,k) dd_new_squ(k)]), 'o--', 'Color', [0 0 0], 'LineWidth', 2); 
    end
end

konect_print(sprintf('plot/spectral_extrapolation.%s.%s.eps', decomposition, network));
