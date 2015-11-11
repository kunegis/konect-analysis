%
% Make the X axis labels by correct for year numbers. 
%
% PARAMETERS 
%	t_min, t_max	Minimum and maximum values to be plotted, in
%			year numbers 
%

function time_xaxis(t_min, t_max)

NUM = 7; % Maximum number of ticks to show on the date axis (X axis)

months = {'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', ...
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'}; 

if t_max - t_min < 1 / 6
    r = (ceil(t_min / (24 * 60 * 60)) : floor(t_max / (24 * 60 * 60))) / 365.25 + 1970
    length_r = length(r)
    if length(r) > 0
        'aaa'
        for i = 1 : length(r)
            l{i} = sprintf('Day %d', i);
        end
        l
        set(gca, 'XTick', r, 'XTickLabel', l); 
    end

elseif t_max - t_min < (1/12) * NUM
    r = (ceil(t_min * 12) / 12):(1/12):(floor(t_max * 12) / 12); 
    set(gca, 'XTick', r);
    rr = ceil(t_min * 12) : floor(t_max * 12);
    assert(length(r) == length(rr));
    assert(length(r) > 0); 
    for i = 1 : length(r)
        if (mod(i,12) == 0)
            text = round(r(i));
        else
            month = mod(i,12);
            text = months{month + 1}; 
        end
        l{i} = text;
    end
    set(gca, 'XTickLabel', l); 

elseif t_max - t_min < (1/6) * NUM
    r = (ceil(t_min * 6) / 6):(1/6):(floor(t_max * 6) / 6); 
    set(gca, 'XTick', r);
    rr = ceil(t_min * 6) : floor(t_max * 6);
    assert(length(r) == length(rr));
    assert(length(r) > 0); 
    for i = 1 : length(r)
        if (mod(i,6) == 0)
            text = round(r(i));
        else
            month = 2 * mod(i,6);
            text = months{month + 1}; 
        end
        l{i} = text;
    end
    set(gca, 'XTickLabel', l); 

elseif t_max - t_min < 1 * NUM
    set(gca, 'XTick', ceil(t_min:floor(t_max)));
elseif t_max - t_min < 2 * NUM
    set(gca, 'XTick', ceil(t_min:2:floor(t_max)));
elseif t_max - t_min < 5 * NUM
    set(gca, 'XTick', ceil(t_min:5:floor(t_max)));
elseif t_max - t_min < 10 * NUM
    set(gca, 'XTick', ceil(t_min:10:floor(t_max)));
elseif t_max - t_min < 20 * NUM
    set(gca, 'XTick', ceil(t_min:20:floor(t_max)));
elseif t_max - t_min < 50 * NUM
    set(gca, 'XTick', ceil(t_min:50:floor(t_max)));
elseif t_max - t_min < 100 * NUM
    set(gca, 'XTick', ceil(t_min:100:floor(t_max)));
end

