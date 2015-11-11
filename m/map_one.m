UNUSED

%
% Draw and print one map plot.  
%
% If only U1 and U2 are given, the plot is drawn in normal fashion.  If
% the variables V1 and V2 are also given, two point colors are used.  
%
% PARAMETERS 
%	info 		Network info from read_info() 
%	letter		Letter to determine color and filename
%	decomposition	Used only to determine the filename
%	network		Used only to determine the filename 
%	u1,u2,v1,v2	(n*1) X and Y coordinates of points
%

function [] =  map_one(letter, decomposition, network, u1, u2, v1, v2)

consts = konect_consts(); 

% number of std. devs. to show 
k = 2.5;

% amount of points to cut
alpha = .06;   

% use the L1 deviation instead of the standard deviation
ENABLE_L1 = 0;  

% cut ALPHA points from each side
ENABLE_CUT = 1;

markerSize = 3;

colors_letter = konect_colors_letter(); 

[min_u1 max_u1] = minmax(u1)
[min_u2 max_u2] = minmax(u2)

if letter == 'B'
    [min_v1 max_v1] = minmax(v1)
    [min_v2 max_v2] = minmax(v2)
end


% if ~enable_v
  
if min_u1 >= max_u1
    min_u1 = min_u1 - 1
    max_u1 = max_u1 + 1
end
if min_u2 >= max_u2
    min_u2 = min_u2 - 1
    max_u2 = max_u2 + 1
end

if letter ~= 'B'

    % Normal plot 
    plot(u1, u2, '.', 'Color', colors_letter.(letter), 'MarkerSize', markerSize);
    axis([min_u1 max_u1 min_u2 max_u2]);
    axis off; 
    konect_print(sprintf('plot/map.%s.%s.%s.eps', letter, decomposition, network)); 

else % BIP

    % Normal plot 
    hold on; 
    plot(u1, u2, '.', 'Color', colors_letter.u, 'MarkerSize', markerSize);
    plot(v1, v2, '.', 'Color', colors_letter.v, 'MarkerSize', markerSize);
    axis([min_uv1 max_uv1 min_uv2 max_uv2]);
    axis off; 
    konect_print(sprintf('plot/map.%s.%s.%s.eps', letter, decomposition, network)); 

    % Only left nodes
    plot(u1, u2, '.', 'Color', colors_letter.u, 'MarkerSize', markerSize);
    axis([min_uv1 max_uv1 min_uv2 max_uv2]);
    axis off; 
    konect_print(sprintf('plot/map.u.%s.%s.eps', letter, decomposition, network)); 

    % Only right nodes
    plot(v1, v2, '.', 'Color', colors_letter.v, 'MarkerSize', markerSize);
    axis([min_uv1 max_uv1 min_uv2 max_uv2]);
    axis off; 
    konect_print(sprintf('plot/map.v.%s.%s.eps', letter, decomposition, network)); 

end

if length(u1) < 600

    % Plot with edges
    data = load(sprintf('dat/data.%s.mat', network)); 
    T = data.T(:, 1:2); 
    T(:,1:2);
    if info.format == consts.BIP
        T(:,2) = T(:,2) + n1; 
    end
    map_line(x, y, T);
    konect_print(sprintf('plot/map.%sx.%s.%s.eps', letter, decomposition, network)); 

    if info.format == consts.BIP 
        % Bipartite plot with edges
        assert(letter == 'a'); 
        map_line([zeros(n1,1); (ones(n2,1) * 1.0 * mean(abs(x)))], x, T);
        konect_print(sprintf('plot/map.%sy.%s.%s.eps', letter, decomposition, network)); 
    end
end

% else

%     hold on; 
%     plot(U1, U2, '.', 'Color', colors_letter.u, 'MarkerSize', markerSize);  
%     plot(V1, V2, '.', 'Color', colors_letter.v, 'MarkerSize', markerSize);

%     if min_UV1 >= max_UV1
%         min_UV1 = min_UV1 - 1
%         max_UV1 = max_UV1 + 1
%     end
%     if min_UV2 >= max_UV2
%         min_UV2 = min_UV2 - 1
%         max_UV2 = max_UV2 + 1
%     end

%     axis([min_UV1 max_UV1 min_UV2 max_UV2]);

% end;

% set(gca, 'FontSize', font_size); 



%
% Minimal and maximal numbers, cutting the extreme points. 
%
function [min_w, max_w] = minmax(ww)
  
    w = ww;

    if ENABLE_CUT
        n = size(w,1);
        w = sort(w);
        start = round(alpha * n)
        endin = round((1-alpha) * n)
        if start > 0
            w = w(start:endin);
        end
    end;

    mean_w = mean(w);

    if ENABLE_L1
        std_w  = mean(abs(w - mean_w));
    else
        std_w  = std(w,1);
    end;

    min_w = mean_w - k * std_w;
    max_w = mean_w + k * std_w;

end

end
