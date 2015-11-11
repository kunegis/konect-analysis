function ret = format_number(number)

fprintf(1, 'format %d\n', number); 

if number < 1000
    ret = sprintf('%d', number); 
elseif number < 1000000
    ret = sprintf('%d,%03d', floor(number/1000), mod(number,1000)); 
elseif number < 1000000000
    ret = sprintf('%d,%03d,%03d', floor(number/1000000), mod(floor(number/1000), 1000), ...
                  mod(number,1000)); 
else
    ret = sprintf('%d,%03d,%03d,%03d', floor(number/1000000000), mod(floor(number/1000000),1000), ...
                  mod(floor(number/1000), 1000), ...
                  mod(number,1000)); 
end

fprintf(1, '  ret=%s\n', ret); 
