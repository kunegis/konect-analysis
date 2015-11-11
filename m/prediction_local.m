%
% Compute predictions using a local method.
%
% PARAMETERS 
%	$NETWORK	Name of network 
%	$METHOD		Name pf local link prediction method
%
% INPUT 
%	dat/split.$NETWORK.mat
%	dat/meanst.$NETWORK.mat
%	dat/info.$NETWORK
%
% OUTPUT 
%	dat/prediction.$METHOD.$NETWORK.mat
%		predictions{submethod}		Struct by name of submethod containing struct of
%			prediction		Column vector of prediction values, following SPLIT.at_test
%			prediction_zero		Column vector of prediction values, following SPLIT.at_test_zero; [] if not used 
%

network = getenv('NETWORK');
method = getenv('METHOD'); 

split = load(sprintf('dat/split.%s.mat', network));
meanst = load(sprintf('dat/meanst.%s.mat', network));
info = read_info(network); 

enable_zero = size(split.T_test_zero) 

T_training = [ split.T_source ; split.T_target ]; 

T_training = konect_normalize_additively(T_training, meanst);

A_training = konect_spconvert(T_training, split.n1, split.n2); 

T_test_all = split.T_test(:,1:2);
if enable_zero
    T_test_all = [ T_test_all ; split.T_test_zero ]; 
end

ps = prediction_local_compute(method, A_training, T_test_all, info.format, info.weights);

submethods = fieldnames(ps); 

predictions = struct(); 

for i = 1 : length(submethods) 
    submethod = submethods{i};

    prediction = konect_denormalize_additively(T_test_all, ps.(submethod), meanst); 

    if enable_zero
        prediction_zero = prediction((size(split.T_test,1)+1) : end); 
        prediction = prediction(1 : size(split.T_test,1)); 
    else
        prediction_zero = []; 
    end

    predictions.(submethod).prediction = prediction; 
    predictions.(submethod).prediction_zero = prediction_zero; 

end

save(sprintf('dat/prediction.%s.%s.mat', method, network), '-v7.3', 'predictions'); 
