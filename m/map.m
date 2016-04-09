%
% Draw mappings, i.e., embeddings of all nodes of a network into the
% plane using the two eigenvectors of a given decomposition. 
%
% PARAMETERS 
%	$NETWORK 	
%	$DECOMPOSITION
%
% INPUT 
%	dat/decomposition_map.$DECOMPOSITION.$NETWORK.mat
%
% OUTPUT 
%	plot/map.[auv].$DECOMPOSITION.$NETWORK.eps 
%

size_plot = 30000;  % max number of points shown
size_x    = 2000;   % max number of points for drawing the line plots 
marker_size = 3;


network = getenv('NETWORK'); 
decomposition = getenv('DECOMPOSITION'); 

consts = konect_consts(); 
colors_letter = konect_colors_letter(); 

data_decomposition = konect_data_decomposition(decomposition); 
info = read_info(network);

n1 = info.n1
n2 = info.n2

decomposition_full = load(sprintf('dat/decomposition_map.%s.%s.mat', decomposition, network)); 

enable_v = (0 ~= length(decomposition_full.V))

r = size(decomposition_full.U, 2)

first = konect_first_index(decomposition, decomposition_full.D)

%
% Generate vectors
%

% When then vectors are real, use the two dominant vectors.  If they
% are complex, use the real and imaginary part of the dominant one. 

if isreal(decomposition_full.U(:,first))

    assert (r >= first + 1); 

    r_1 = first;
    r_2 = first + 1;

    u1 = decomposition_full.U(:, r_1); 
    u2 = decomposition_full.U(:, r_2); 

    if enable_v
        v1 = decomposition_full.V(:, r_1); 
        v2 = decomposition_full.V(:, r_2); 
    end

else % decomposition_full.U is complex

    r_1 = first;
    assert(r_1 <= r); 

    u1 = real(decomposition_full.U(:, r_1)); 
    u2 = imag(decomposition_full.U(:, r_1)); 

    if enable_v
        v1 = real(decomposition_full.V(:, r_1));
        v2 = imag(decomposition_full.V(:, r_1)); 
    end

end

% Everything is a column vector
assert(size(u1,2) == 1); 
assert(size(u2,2) == 1); 
if enable_v
    assert(size(v1,2) == 1); 
    assert(size(v2,2) == 1); 
end

assert(size(u1,1) == n1);
assert(size(u2,1) == n1); 
if enable_v
    assert(size(v1,1) == n2);
    assert(size(v2,1) == n2);
end

%
% Min / max
%

[min_u1 max_u1] = map_minmax(u1);  mid_u1 = 0.5 * (min_u1 + max_u1); rad_u1 = 0.5 * (max_u1 - min_u1); 
[min_u2 max_u2] = map_minmax(u2);  mid_u2 = 0.5 * (min_u2 + max_u2); rad_u2 = 0.5 * (max_u2 - min_u2); 
if rad_u1 ==  0, rad_u1= 1; end;
if rad_u2 ==  0, rad_u2= 1; end;
rad_u12 = max(rad_u1, rad_u2);

if enable_v
    [min_v1 max_v1] = map_minmax(v1);  mid_v1 = 0.5 * (min_v1 + max_v1); rad_v1 = 0.5 * (max_v1 - min_v1); 
    [min_v2 max_v2] = map_minmax(v2);  mid_v2 = 0.5 * (min_v2 + max_v2); rad_v2 = 0.5 * (max_v2 - min_v2); 
    if rad_v1 ==  0, rad_v1= 1; end;
    if rad_v2 ==  0, rad_v2= 1; end;
    rad_v12 = max(rad_v1, rad_v2);

    if info.format == consts.ASYM
        rad_uv1 = max(rad_u1, rad_v1);
    end

    if info.format == consts.BIP
        min_uv1 = min(min_u1, min_v1);  
        max_uv1 = max(max_u1, max_v1);
        mid_uv1 = 0.5 * (min_uv1 + max_uv1); rad_uv1 = 0.5 * (max_uv1 - min_uv1); 

        min_uv2 = min(min_u2, min_v2);
        max_uv2 = max(max_u2, max_v2);
        mid_uv2 = 0.5 * (min_uv2 + max_uv2); rad_uv2 = 0.5 * (max_uv2 - min_uv2); 
        
        rad_uv12 = max(rad_uv1, rad_uv2); 
    end
end


%
% Show at most MAX_I points to limit the size of the files
% 
if info.n > size_plot
    max_i = size_plot;
    u_i = find(rand(n1,1) < max_i / n1);
    u1 = u1(u_i);
    u2 = u2(u_i); 

    if enable_v
        if info.format ~= consts.BIP
            v_i = u_i; 
        else
            v_i = find(rand(n2,1) < max_i / n2);
        end
        v1 = v1(v_i);
        v2 = v2(v_i); 
    end
end

%
% Plot
%

enable_line = (info.n < size_x)

if enable_line
    % Plot with edges
    data = load(sprintf('dat/data.%s.mat', network)); 
    T = data.T(:, 1:2); 
    if info.format == consts.BIP
        T(:,2) = T(:,2) + n1; 
    end
end

if info.format ~= consts.BIP
    
    % U plot 
    plot(u1, u2, '.', 'Color', colors_letter.a, 'MarkerSize', marker_size);
    axis off square; 
    axis([(mid_u1 - rad_u12), (mid_u1 + rad_u12), (mid_u2 - rad_u12), (mid_u2 + rad_u12)]);
    konect_print(sprintf('plot/map.a.%s.%s.eps', decomposition, network)); 

    if enable_line
        % U line plot
        map_line(u1, u2, T, 1);
        konect_print(sprintf('plot/map.ax.%s.%s.eps', decomposition, network)); 
    end

    if enable_v

        % V plot
        plot(v1, v2, '.', 'Color', colors_letter.v, 'MarkerSize', marker_size);
        axis off square; 
        axis([(mid_v1 - rad_v12), (mid_v1 + rad_v12), (mid_v2 - rad_v12), (mid_v2 + rad_v12)]);
        konect_print(sprintf('plot/map.b.%s.%s.eps', decomposition, network)); 

        if enable_line
            % V line plot
            map_line(v1, v2, T, 1);
            konect_print(sprintf('plot/map.bx.%s.%s.eps', decomposition, network)); 
        end

        % UV plot 
        plot(u1, v1, '.', 'Color', colors_letter.a, 'MarkerSize', marker_size);
        axis off square; 
        axis([(mid_u1 - rad_uv1), (mid_u1 + rad_uv1), (mid_v1 - rad_uv1), (mid_v1 + rad_uv1)]);
        konect_print(sprintf('plot/map.c.%s.%s.eps', decomposition, network)); 

        if enable_line
            % UV line plot
            map_line(u1, v1, T, 1);
            konect_print(sprintf('plot/map.cx.%s.%s.eps', decomposition, network)); 
        end
    end

else % BIP

    % Normal plot 
    hold on; 
    plot(u1, u2, '.', 'Color', colors_letter.u, 'MarkerSize', marker_size);
    plot(v1, v2, '.', 'Color', colors_letter.v, 'MarkerSize', marker_size);
    axis off square; 
    axis([(mid_uv1 - rad_uv12), (mid_uv1 + rad_uv12), (mid_uv2 - rad_uv12), (mid_uv2 + rad_uv12)]); 
    konect_print(sprintf('plot/map.a.%s.%s.eps', decomposition, network)); 

    % Only left nodes
    plot(u1, u2, '.', 'Color', colors_letter.u, 'MarkerSize', marker_size);
    axis off square; 
    axis([(mid_u1 - rad_u12), (mid_u1 + rad_u12), (mid_u2 - rad_u12), (mid_u2 + rad_u12)]); 
    konect_print(sprintf('plot/map.u.%s.%s.eps', decomposition, network)); 

    % Only right nodes
    plot(v1, v2, '.', 'Color', colors_letter.v, 'MarkerSize', marker_size);
    axis off square; 
    axis([(mid_v1 - rad_v12), (mid_v1 + rad_v12), (mid_v2 - rad_v12), (mid_v2 + rad_v12)]); 
    konect_print(sprintf('plot/map.v.%s.%s.eps', decomposition, network)); 

    if enable_line
        % Line plot
        map_line([u1;v1], [u2;v2], T, 1);
        konect_print(sprintf('plot/map.ax.%s.%s.eps', decomposition, network)); 
    end

    if enable_line
        % Bipartite line plot 
        map_line([zeros(n1,1); (ones(n2,1) * 1.0 * mean(abs([u1;v1])))], [u1;v1], T, 1);
        konect_print(sprintf('plot/map.ay.%s.%s.eps', decomposition, network)); 
    end
end
