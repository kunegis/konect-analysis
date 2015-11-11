#ifndef ASXPRINTF_H
#define ASXPRINTF_H

#include <stdarg.h>

/* Format a string like printf, but return the formatted string as an
   allocated zero-terminated string that must be freed using free(). 
   On error, use perror() and exit(). 
 */
char *asxprintf(const char *fmt, ...)
	__attribute__ ((format(printf, 1, 2)));

char *asxprintf(const char *fmt, ...)
{
	va_list ap;

	va_start(ap, fmt); 

	char *ret;

	int r= vasprintf(&ret, fmt, ap);

	va_end(ap); 

	if (r < 0) {
		perror("vasprintf");
		exit(1); 
	}

	return ret;
}

#endif /* ! ASXPRINTF_H */
