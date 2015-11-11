
function ret = corr(a, b)

if nargin == 2

    ret = corrcoef(a, b);
    
elseif nargin == 4

    ret = corrcoef(a, b, c, d);
    
else

    error('*** unsupported case'); 
    
end

