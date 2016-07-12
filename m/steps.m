%
% Compute steps for time-dependent analysis of a split dataset.  
%
% The time steps are not exactly all over the same number of edges.
% Instead, they are fudged so as to put steps on the moment the two
% splits happen. 
%
% PARAMETERS 
%	$network		Network
%
% INPUT 
%	dat/split.$network.mat	
%
% OUTPUT 
%	dat/steps.$network.mat 		Steps
%		steps_all		Total number of steps ( = size(e_steps, 1))
%		steps_source		Number of source steps
%		steps_target 		Number of target steps
%		e_steps			(count×1) Edge count at each step
%

network = getenv('network'); 

count = 100; 

split = load(sprintf('dat/split.%s.mat', network)); 
means = load(sprintf('dat/means.%s.mat', network)); 

% Edge counts
e_source = size(split.T_source, 1)
e_target = size(split.T_target, 1)
e_test   = size(split.T_test  , 1) 

% Last index in the source and target set
index_source = floor(e_source * count / (e_source + e_target + e_test))
index_target = floor((e_source + e_target) * count / (e_source + e_target + e_test))

e_steps = [ floor((1 : index_source) * e_source / index_source)  ...
            (e_source + floor((1 : index_target - index_source) * e_target / (index_target - index_source)))  ...
            (e_source + e_target + floor(( 1 : count - index_target) * e_test / (count - index_target))) ]'

steps_all = count
steps_source = index_source
steps_target = index_target - index_source

save(sprintf('dat/steps.%s.mat', network), '-v7.3', ...
  'steps_all', 'steps_source', 'steps_target', ...
  'e_steps'); 
