%
% Compute link predictions using decompositions.
%
% PARAMETERS 
%	$NETWORK
%	$DECOMPOSITION 
%
% INPUT 
%	dat/info.$NETWORK
%	dat/fit.$DECOMPOSITION.$NETWORK.mat
%	dat/split.$NETWORK.mat
%	dat/decomposition_split.source.$DECOMPOSITION.$NETWORK.mat 
%	dat/decomposition_split.training.$DECOMPOSITION.$NETWORK.mat 
%
% OUTPUT 
%	dat/prediction.$DECOMPOSITION.$NETWORK.mat
%		predictions{curve}	Struct by curve name, and "euclidean", "sne"
%			prediction
%			prediction_zero 
%

network = getenv('NETWORK');
decomposition = getenv('DECOMPOSITION');

info = read_info(network); 
fit = load(sprintf('dat/fit.%s.%s.mat', decomposition, network)); 
split = load(sprintf('dat/split.%s.mat', network)); 
decomposition_source = load(sprintf('dat/decomposition_split.source.%s.%s.mat', decomposition, network)); 
decomposition_training = load(sprintf('dat/decomposition_split.training.%s.%s.mat', decomposition, network)); 

data_decomposition = konect_data_decomposition(decomposition); 

consts = konect_consts(); 

enable_zero = size(split.T_test_zero) 

first = 1; 

u_red = decomposition_training.U(:,first:end); 
d_red = decomposition_training.D(first:end,first:end); 
if length(decomposition_training.V)
    v_red = decomposition_training.V(:, first:end); 
else
    v_red = []; 
end

predictions = struct(); 

%
% Curves
%
curves = fieldnames(fit.curves) 
for i = 1 : length(curves)
    curve = curves{i}
    values = fit.curves.(curve)

    d_new = curve_apply(d_red, curve, values, data_decomposition); 

    [pR pI] = predict_spectral(u_red, d_new, v_red, split.T_test(:,1:2), decomposition); 
    if data_decomposition.imag 
        predictions.(curve).prediction = pI;
    else
        predictions.(curve).prediction = pR;
    end
    if enable_zero
        [pR pI]  = predict_spectral(u_red, d_new, v_red, split.T_test_zero(:,1:2), decomposition); 
        if data_decomposition.imag
            predictions.(curve).prediction_zero = pI;
        else
            predictions.(curve).prediction_zero = pR;
        end
    else
        predictions.(curve).prediction_zero = []; 
    end
end

%
% Low-rank variants
%

for r = 1:(min(3,size(decomposition_training.U, 2)))

    submethod = sprintf('rank%u', r)

    u_red_r = decomposition_training.U(:,first:(first+r-1)); 
    d_red_r = decomposition_training.D(first:(first+r-1),first:(first+r-1)); 
    if length(decomposition_training.V)
        v_red_r = decomposition_training.V(:, first:(first+r-1)); 
    else
        v_red_r = []; 
    end

    [pR pI] = predict_spectral(u_red_r, d_red_r, v_red_r, split.T_test(:,1:2), decomposition); 
    predictions.(submethod).prediction = pR;
    iscomplex = length(pI)
    if iscomplex
        predictions.([submethod 'i']).prediction = pI; 
    end

    if enable_zero
        [pR pI] = predict_spectral(u_red_r, d_red_r, v_red_r, split.T_test_zero(:,1:2), decomposition); 
        predictions.(submethod).prediction_zero = pR;
        if iscomplex
            if length(pI) == 0, pI = zeros(length(pR),1); end; 
            predictions.([submethod 'i']).prediction_zero = pI; 
        end
    else
        predictions.(submethod).prediction_zero = []; 
        if iscomplex
            predictions.([submethod 'i']).prediction_zero = []; 
        end
    end
end

% 
% Euclidean prediction
% 

D_euclidean = decomposition_training.D;
if data_decomposition.l
    D_euclidean = pinv(D_euclidean); 
elseif data_decomposition.n
    D_euclidean = pinv(eye(size(D_euclidean,1)) - D_euclidean); 
end

predictions.euclidean.prediction = predict_euclidean(...
    decomposition_training.U, D_euclidean, decomposition_training.V, split.T_test(:,1:2)); 
if enable_zero
    predictions.euclidean.prediction_zero = predict_euclidean(...
        decomposition_training.U, D_euclidean, decomposition_training.V, split.T_test_zero(:,1:2)); 
else
    predictions.euclidean.prediction_zero = []; 
end

%
% Spectral extrapolation 
%

dd_new = sne(decomposition_source.U, diag(decomposition_source.D), decomposition_source.V, ...
             decomposition_training.U, diag(decomposition_training.D), decomposition_training.V); 

predictions.sne.prediction = predict_spectral(decomposition_training.U, diag(dd_new), ...
                                              decomposition_training.V, split.T_test(:,1:2), decomposition); 
if enable_zero
    predictions.sne.prediction_zero = predict_spectral(decomposition_training.U, diag(dd_new), ...
                                                      decomposition_training.V, split.T_test_zero(:,1:2), decomposition); 
else
    predictions.sne.prediction_zero = []; 
end

%
% Cosine similarity
%
if info.format ~= consts.BIP
    if length(decomposition_training.V)
        predictions.cosine.prediction = konect_predict_cosine([ decomposition_training.U, decomposition_training.V ], split.T_test(:,1:2), consts.BIP); 
    else
        predictions.cosine.prediction = konect_predict_cosine(decomposition_training.U, split.T_test(:,1:2), consts.BIP); 
    end
    if enable_zero
        if length(decomposition_training.V)
            predictions.cosine.prediction_zero = konect_predict_cosine([ decomposition_training.U, decomposition_training.V ], ...
                                                              split.T_test_zero(:,1:2), consts.BIP);
        else
            predictions.cosine.prediction_zero = konect_predict_cosine(decomposition_training.U, split.T_test_zero(:,1:2), consts.BIP);
        end
    else
        predictions.cosine.prediction_zero = []; 
    end
end

save(sprintf('dat/prediction.%s.%s.mat', decomposition, network), '-v7.3', 'predictions'); 
