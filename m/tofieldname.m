%
% Convert a string to a valid field name.  This is used whenever
% structs are used in a dynamic way, using generic strings as keys,
% for instance for methods, submethods, decompositions, etc. 
%
%

function ret = tofieldname(s)

ret = regexprep(s, '-', '_'); 
