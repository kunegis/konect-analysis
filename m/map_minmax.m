
%
% Minimal and maximal numbers, cutting the extreme points. 
%
function [min_w, max_w] = map_minmax(ww)
  
    % cut ALPHA points from each side
    enable_cut = 1;

    % use the L1 deviation instead of the standard deviation
    enable_l1 = 0;  

    % amount of points to cut
    alpha = .06;   

    % number of std. devs. to show 
    k = 2.5;

    w = ww;

    if enable_cut
        n = size(w,1);
        w = sort(w);
        start = round(alpha * n)
        endin = round((1-alpha) * n)
        if start > 0
            w = w(start:endin);
        end
    end;

    mean_w = mean(w);

    if enable_l1
        std_w  = mean(abs(w - mean_w));
    else
        std_w  = std(w,1);
    end;

    min_w = mean_w - k * std_w;
    max_w = mean_w + k * std_w;

end
