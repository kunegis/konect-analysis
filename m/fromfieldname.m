%
% Convert a field name back to a string.  Used in conjunction with
% tofieldname(). 
%
%

function ret = fromfieldname(s)

ret = regexprep(s, '_', '-'); 
