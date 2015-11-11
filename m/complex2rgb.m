%
% Convert a complex number to a RGB value for visualization. 
%

function [rgb] = complex2rgb(value)

h = angle(value) / (2*pi) + 0.5;
s = 1;
v = 1 - 1 / (abs(value) + 1);

rgb = hsv2rgb([h s v]);
