%
% Style info by methods.
%
% RESULT 
%	colors			Struct by method
%		.(method)	(1*3) Color
%	line_styles		Struct by method
%		.(method)	(string) line style
%	markers			Struct by method
%		.(method)	(string) marker 
%

function [colors line_styles markers] = styles_method()

colors = struct();
line_styles = struct();
markers = struct(); 

colors.svd		= [1  0  0 ];    line_styles.svd	= '-';   markers.svd		= 'o';
colors.diag		= [0  1  0 ];    line_styles.diag	= '--';  markers.diag		= 's';
colors.takane		= [0  0  1 ];    line_styles.takane	= ':';   markers.takane		= '*';
colors.dedicom1u	= [1  0  1 ];	 line_styles.dedicom1u	= '-';   markers.dedicom1u	= '+';
colors.dedicom1v	= [0  1  1 ];    line_styles.dedicom1v	= '--';  markers.dedicom1v	= 'x';
colors.dedicom2		= [.7 0  0 ];    line_styles.dedicom2	= ':';   markers.dedicom2	= 'd';
colors.dedicom2s	= [0  .7 0 ];    line_styles.dedicom2s	= '-';   markers.dedicom2s	= 'h';
colors.dedicom3		= [0  0  .7];    line_styles.dedicom3	= '--';  markers.dedicom3	= 'p';
colors.sym		= [.7 .7 0 ]; 
colors.pref		= [.7 0  .7];
colors.neib		= [0  .7 .7];
