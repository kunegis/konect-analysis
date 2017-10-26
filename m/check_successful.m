function check_successful()

delete(sprintf('dat/check_error.%s', getenv('network'))); 
  
data = 0; 
OUT = fopen(sprintf('dat/check.%s', getenv('network')), 'w');
if OUT < 0,  error('fopen');  end 
fprintf(OUT, '1\n');
if fclose(OUT) < 0,  error('fclose');  end

exit(0);
  
