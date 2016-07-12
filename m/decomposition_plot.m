%
% Plot spectrum.  
% 
% PARAMETERS 
%	$network
%	$decomposition
%
% INPUT 
%	dat/decomposition.$decomposition.$network.mat
%
% OUTPUT 
%	plot/decomposition.{...}.$decomposition.$network.eps 
%

color_neutral =  [0 0 1];
color_positive = [0 1 0];
color_negative = [1 0 0];

linestyle = '-*'; 

font_size = 22; 
line_width = 3;

network = getenv('network');
decomposition = getenv('decomposition'); 

data_decomposition = konect_data_decomposition(decomposition); 

info = read_info(network); 

decomposition_full = load(sprintf('dat/decomposition.%s.%s.mat', decomposition, network));

U = decomposition_full.U;
D = decomposition_full.D; 
V = decomposition_full.V; 
r = size(U,2); 

is_asymmetric = size(V) ~= 0; 

range = 1:r;

% The spectrum itself, not mapped to real numbers or sorted 
spectrum_raw = diag(decomposition_full.D);

% The spectrum mapped to real numbers, in a decomposition-dependent
% way 
spectrum = spectrum_visualize(spectrum_raw, decomposition)


% Eigenvectors normalized to norm 1
U_norm = (U * diag(sum(conj(U) .* U, 1) .^ -0.5)); 
if is_asymmetric
    V_norm = (V * diag(sum(conj(V) .* V, 1) .^ -0.5)); 
end

first = konect_first_index(decomposition, D); 

% The sorted spectrum
if ~data_decomposition.l
    % In this case the eigenvalues are sorted by decreasing absolute
    % value.  Sort them by decreasing real part for this plot. 
    [x i] = sort(-real(spectrum)); 
    spectrum_sorted = spectrum(i)
else
    spectrum_sorted = spectrum
end

%
% (b) - Absolute values
%

ipos = find(spectrum_sorted >= 0);
ineg = find(spectrum_sorted <  0);
r_pos = length(ipos)
r_neg = length(ineg) 

is_negative = r_neg > 0; 

if is_negative

    hold on;
    plot(1:r_pos, abs(spectrum_sorted(ipos)), ...
         linestyle, 'Color', color_positive, 'LineWidth', line_width);
    plot((r_pos+1):(r_pos+r_neg), abs(spectrum_sorted(ineg)), ...
         linestyle, 'Color', color_negative, 'LineWidth', line_width); 

    xlabel('Rank (k)', 'FontSize', font_size);
    ylabel('Absolute eigenvalues (|\lambda_k|)', 'FontSize', font_size); 

    set(gca, 'FontSize', font_size); 

    if data_decomposition.n
        gridxy([], [+1], 'LineStyle', '--'); 
    end

    konect_print(sprintf('plot/decomposition.b.%s.%s.eps', decomposition, network)); 

end

%
% (d) - Diff plot
%

enable_d = 1; 

if ~is_negative
    semilogy(1:r-1, log(spectrum(1:r-1) ./ spectrum(2:r)), '-+k');  
else
    spectrum_pos = spectrum_sorted(ipos); 
    spectrum_neg = spectrum_sorted(ineg);
    valp =  log(spectrum_pos(1:r_pos-1) ./ spectrum_pos(2:r_pos)) 
    valn =  log(spectrum_neg(1:r_neg-1) ./ spectrum_neg(2:r_neg))
    if r_pos <= 1, valp = []; end
    if r_neg <= 1, valn = []; end		  
    if prod(size(valp))
        semilogy(1 : r_pos-1, valp, '-+', 'Color', color_positive);   
    end
    hold on ;
    y_min = min([valp; valn])
    y_max = max([valp; valn])
    y_from = y_min - max(1e-2, 0.05 * (y_max - y_min)); 
    y_to = y_max + max(1e-2, 0.05 * (y_max - y_min))
    x_max = (r_pos+r_neg-1)
    axis([0 x_max y_from y_to]);
    if prod(size(valn))
        semilogy((r_pos+r_neg-2):-1:r_pos, valn, '-+', 'Color', color_negative);
    else
        enable_d = 0; 
    end
end

set(gca, 'FontSize', font_size); 

if enable_d
    konect_print(sprintf('plot/decomposition.d.%s.%s.eps', decomposition, network)); 
end

%
% (complex) Complex eigenvalue plot
%

if ~isreal(D)
    close all; 
    plot(real(spectrum_raw), imag(spectrum_raw), '.', 'MarkerSize', 15, 'Color', [.87 .52 0]); 
    pbaspect([1 1 1]); 
    ax = axis(); 
    diff = max(max(real(spectrum_raw)) - min(real(spectrum_raw)), max(imag(spectrum_raw)) - min(imag(spectrum_raw))); 
    diff = 1.15 * diff;
    mid_x = 0.5 * (max(real(spectrum_raw)) + min(real(spectrum_raw)));
    mid_y = 0.5 * (max(imag(spectrum_raw)) + min(imag(spectrum_raw)));
    ax(1) = mid_x - 0.5 * diff;
    ax(2) = mid_x + 0.5 * diff;
    ax(3) = mid_y - 0.5 * diff;
    ax(4) = mid_y + 0.5 * diff;
    axis(ax); 
    gridxy([0], [0], 'LineStyle', '--', 'Color', 0.7 * [1 1 1]); 
    xlabel('Re(\lambda_i)', 'FontSize', font_size); 
    ylabel('Im(\lambda_i)', 'FontSize', font_size); 
    set(gca, 'FontSize', font_size); 
    set(gca, 'XMinorTick', 'on');
    set(gca, 'YMinorTick', 'on'); 
    set(gca, 'TickLength', [0.05 0.05]); 
    konect_print(sprintf('plot/decomposition.complex.%s.%s.eps', decomposition, network)); 
end

%
% (dedicom) Nondiagonal central matrix
%

if 0 ~= sum(sum(D - diag(diag(D))))
    konect_imageubu(D);
    konect_print(sprintf('plot/decomposition.dedicom.%s.%s.eps', decomposition, network)); 
end

%
% (log) - Like (b), but on a logarithmic Y axis, and also drawn if their are no negative eigenvalues. 
%
% Used to inspect eigenvalue power-law exponents visually. 
%

semilogy(1:length(spectrum_sorted), abs(spectrum_sorted), linestyle, 'Color', color_neutral, 'LineWidth', line_width);

xlabel('Rank (k)', 'FontSize', font_size);
ylabel('Absolute eigenvalues (|\lambda_k|)', 'FontSize', font_size); 

set(gca, 'FontSize', font_size); 

if data_decomposition.n
    gridxy([], [+1], 'LineStyle', '--'); 
end

konect_print(sprintf('plot/decomposition.log.%s.%s.eps', decomposition, network)); 

%
% (cumul) - Cumulative distribution
%
% Used to inspect eigenvalue power-law exponents visually. 
%

konect_power_law_plot(abs(spectrum_sorted), [], 0, color_neutral, 1); 

matrix = data_decomposition.matrix 

xlabel(sprintf('Absolute eigenvalues (|\\lambda[%s]|)', matrix), 'FontSize', font_size); 
ylabel(sprintf('P(|x| \\geq |\\lambda[%s]|)', matrix), 'FontSize', font_size);

konect_print(sprintf('plot/decomposition.cumul.%s.%s.eps', decomposition, network)); 

%
% (a) - Real spectrum
%

plot(1:length(spectrum_sorted), spectrum_sorted, linestyle, 'Color', color_neutral, 'LineWidth', line_width); 

xlabel('Rank (k)', 'FontSize', font_size);
ylabel(sprintf('%ss (%s_k)', data_decomposition.value_name, data_decomposition.value_symbol), 'FontSize', font_size); 

set(gca, 'FontSize', font_size); 

ax = axis();
if ax(3) < 0
    gridxy([], [0], 'LineStyle', '-'); 
end

if data_decomposition.n
    gridxy([], [-1 +1], 'LineStyle', '-'); 
end

konect_print(sprintf('plot/decomposition.a.%s.%s.eps', decomposition, network)); 
