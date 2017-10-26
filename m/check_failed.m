function check_failed(text)

FILE = fopen(sprintf('dat/check_error.%s', getenv('network')), 'w');
if FILE < 0,  error('fopen');  end
fprintf(FILE, '%s\n', text);
if fclose(FILE) < 0,  error('fclose');  end

data = 0; 
OUT = fopen(sprintf('dat/check.%s', getenv('network')), 'w');
if OUT < 0,  error('fopen');  end 
fprintf(OUT, '0\n');
if fclose(OUT) < 0,  error('fclose');  end

exit(0);
  
