
UNUSED

%
% Convert timestamps to year numbers.
%

function years = timestamp_year(timestamps)

years = timestamps / (365.25 * 24 * 60 * 60) + 1970; 

 