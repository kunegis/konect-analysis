%
% Format the value of a statistic. 
%

function [text] = format_statistic(statistic, value)

[l i] = konect_data_statistic();

if i.(statistic)

  text = format_number(value);

else

  text = sprintf('%.3f', value);

end


