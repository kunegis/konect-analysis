package TexToHtml::Converter;
sub to_text{
	shift();
	my $string=shift();

	#dash
	$string=~s/--/&ndash;/g;
	
	#remove curly braces
	$string=~s/\{\\[^{]+\{(.*)\}\}/$1/g;
	
	$string=~s/[{}]//g;
	$string=~s/``([^']*)''''/"$1"/g;
	return $string;

}
sub convert{
	shift();
	my $string=shift();
	#generate links
	$string=~s/\\url\{([^}]*)\}/<a href="$1">$1<\/a>/gi;

	#dash
	$string=~s/--/&ndash;/g;
	
	
	#remove curly braces
	$string=~s/\{\\[^{]+\{(.*)\}\}/$1/g;
	
	$string=~s/[{}]//g;
	return $string;

}


return 1;
