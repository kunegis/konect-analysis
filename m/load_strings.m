
%
% Load strings from a file.  The file should contain one string per
% line.  The function returns a cell array of strings, where each
% string is the content of one line.
%

function [strings] = load_strings(filename)

FILE = fopen(filename);

if FILE < 0,  error('fopen');  end;

strings = textscan(FILE, '%s');
% Returns a cell array of one element, which is a cell array with all
% the strings. 

strings = strings{1};

if 0 > fclose(FILE),  error('fclose');  end;
