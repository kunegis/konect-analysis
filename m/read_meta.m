%
% Read metadata from a data file.
%
% RESULT 
%	A struct where field names are the keys and the values are
%	strings. In key names, '-' is replaced with '_'. 
%
% PARAMETERS 
%	network		Network name
%

function ret = read_meta(network)

filename = sprintf('uni/meta.%s', network); 

FILE = fopen(filename, 'r'); 

if FILE < 0, error('*** open'); end; 

ret = {};  

while 1

    line = fgetl(FILE);

    if line == -1; break; end; 

    tokens = regexp(line, '\s*([a-zA-Z0-9-]+)\s*:\s*(\S.*\S|\S)\s*', 'tokens', 'once'); 

    if length(tokens) < 2
        continue;
    end

    key   = tokens{1}; 
    value = tokens{2};

    key = regexprep(key, '-', '_'); 

    ret.(key) = value;   

end;

if fclose(FILE) < 0, error('fclose'); end; 

