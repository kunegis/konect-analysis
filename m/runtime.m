%
% Analyse runtime.
%
% OUTPUT 
% 	dat/runtime
% 	plot/runtime.eps
%
% INPUT 
%       tmp.runtime
%

a = load('tmp.runtime')

% regression
c = [-log(a(:,1))]
d = [ones(size(a,1),1)  log(a(:,2) + a(:,3)) log(a(:,4)) log(a(:,2) .* a(:,3))]
x = pinv(d) * c
kp = exp(- d * x);

[a(:,1) kp]

% curve fitting
b = [a(:,1) ((a(:,2) + a(:,3)).^x(2) .* a(:,4).^x(3) .* (a(:,2).*a(:,3)).^x(4))]

i_squ = find(((a(:,2) - a(:,3)) ./ a(:,2)) <  .002)
i_rec = find(((a(:,2) - a(:,3)) ./ a(:,2)) >= .002)

loglog(b(i_squ,2), b(i_squ,1), 'ob');
hold;
loglog(b(i_rec,2), b(i_rec,1), 'or');
print('-depsc', 'plot/runtime.eps');  close all;

save -ascii 'dat/runtime' x;
