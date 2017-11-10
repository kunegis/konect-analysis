%
% Make the X axis labels by correct for year numbers. 
%
% PARAMETERS 
%	t_min, t_max	Minimum and maximum values to be plotted, in
%			Unix times
%

function time_xaxis_unix(t_min, t_max)

assert(t_max > t_min); 
  
NUM = 7; % Maximum number of ticks to show on the date axis (X axis)
YEAR = 3600 * 24 * 365.2425; % Approximate length of year 

months = {'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', ...
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'}; 

if t_max - t_min < 1 / 6 * YEAR
  'by day'
  r = ceil(t_min / 24 / 3600) : floor(t_max / 24 / 3600);
  r = r - r(1) + 1; 
%%    r = (ceil(t_min / (24 * 60 * 60)) : floor(t_max / (24 * 60 * 60))) / 365.25 + 1970
  length_r = length(r)
  if length(r) > 0
    for i = 1 : length(r)
      l{i} = sprintf('Day %d', i);
    end
    l
    set(gca, 'XTick', r, 'XTickLabel', l); 
  end

elseif t_max - t_min < (1/12) * YEAR * NUM
  'by month'
  r = ceil(t_min / (3600 * 24 * YEAR / 12)) : ceil(t_max / (3600 * 24 * YEAR / 12));
  r_year = mod(r, 12) + 1970; 
  assert(length(r) > 0); 
%%  r = (ceil(t_min * 12) / 12):(1/12):(floor(t_max * 12) / 12); 
  set(gca, 'XTick', r);
%%  rr = ceil(t_min * 12) : floor(t_max * 12);
%%  assert(length(r) == length(rr));
  for i = 1 : length(r)
    if (mod(t(i),12) == 0)
      text = sprintf('%u', r_year(i)); 
    else
      month = mod(r(i),12);
      text = months{month + 1}; 
    end
    l{i} = text;
  end
  set(gca, 'XTickLabel', l); 

elseif t_max - t_min < (1/6) * NUM
  'by two month period'
  r = ceil(t_min / (3600 * 24 * YEAR / 12)) : 2 : ceil(t_max / (3600 * 24 * YEAR / 12));
  r_year = mod(r, 12) + 1970; 
  assert(length(r) > 0); 
%%  r = (ceil(t_min * 6) / 6):(1/6):(floor(t_max * 6) / 6); 
  set(gca, 'XTick', r);
%%  rr = ceil(t_min * 6) : floor(t_max * 6);
%%  assert(length(r) == length(rr));
  for i = 1 : length(r)
    if (mod(t(i),12) == 0)
      text = sprintf('%u', r_year(i)); 
    else
      month = mod(r(i),12);
      text = months{month + 1}; 
    end
    l{i} = text;
  end
  set(gca, 'XTickLabel', l); 

% By years     
elseif t_max - t_min < 1 * YEAR * NUM
    set(gca, 'XTick', ceil(t_min:floor(t_max)));
elseif t_max - t_min < 2 * YEAR * NUM
    set(gca, 'XTick', ceil(t_min:2:floor(t_max)));
elseif t_max - t_min < 5 * YEAR * NUM
    set(gca, 'XTick', ceil(t_min:5:floor(t_max)));
elseif t_max - t_min < 10 * YEAR * NUM
    set(gca, 'XTick', ceil(t_min:10:floor(t_max)));
elseif t_max - t_min < 20 * YEAR * NUM
    set(gca, 'XTick', ceil(t_min:20:floor(t_max)));
elseif t_max - t_min < 50 * YEAR * NUM
    set(gca, 'XTick', ceil(t_min:50:floor(t_max)));
elseif t_max - t_min < 100 * YEAR * NUM
    set(gca, 'XTick', ceil(t_min:100:floor(t_max)));
end

