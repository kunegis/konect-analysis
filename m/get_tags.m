%
% Extract the tags from the metadata of a network. 
%
% RESULT 
%	ret	A struct contain a field for every tag 
%
% PARAMETERS 
%	meta	The metadata, as returned by read_meta() 
%

function ret = get_tags(meta)

ret = struct(); 

if ~ isfield(meta, 'tags')
    return; 
end

tags = meta.tags;

match = regexp(tags, '#[a-z]+', 'match')

for i = 1 : length(match)
    tag = match{i}
    tag = tag(2:end) 
    ret.(tag) = 1; 
end
