%
% Make the X axis labels by correct for year numbers. 
%
% PARAMETERS 
%	t_min, t_max	Minimum and maximum values to be plotted, in
%			Unix times
%

function time_xaxis_unix(t_min, t_max)

t_min
t_max
  
assert(t_max > t_min); 
  
NUM = 7; % Maximum number of ticks to show on the date axis (X axis)
YEAR = 3600 * 24 * 365.2425; % Approximate length of year 

months = {'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', ...
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'}; 

if t_max - t_min < 1 / 6 * YEAR
  'by day'
  r = ceil(t_min / 24 / 3600) : floor(t_max / 24 / 3600)
  length_r = length(r)
  if length(r) > 0
    r = r - r(1) + 1; 
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
  set(gca, 'XTick', r);
  for i = 1 : length(r)
    if (mod(r(i),12) == 0)
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
  set(gca, 'XTick', r);
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
  'case A'
  set(gca, 'XTick', ceil(t_min/YEAR:floor(t_max/YEAR)));
elseif t_max - t_min < 2 * YEAR * NUM
  'case B'
  set(gca, 'XTick', ceil(t_min/YEAR:2:floor(t_max/YEAR)));
  'B done'
elseif t_max - t_min < 5 * YEAR * NUM
  'case C'
  set(gca, 'XTick', ceil(t_min/YEAR:5:floor(t_max/YEAR)));
elseif t_max - t_min < 10 * YEAR * NUM
  'case D'
  set(gca, 'XTick', ceil(t_min/YEAR:10:floor(t_max/YEAR)));
elseif t_max - t_min < 20 * YEAR * NUM
  'case E'
  set(gca, 'XTick', ceil(t_min/YEAR:20:floor(t_max/YEAR)));
elseif t_max - t_min < 50 * YEAR * NUM
  'case F'
  set(gca, 'XTick', ceil(t_min/YEAR:50:floor(t_max/YEAR)));
elseif t_max - t_min < 100 * YEAR * NUM
  'case G'
  set(gca, 'XTick', ceil(t_min/YEAR:100:floor(t_max/YEAR)));
end

