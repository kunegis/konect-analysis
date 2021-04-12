#! /bin/sh
#
# Execute a Matlab script.  This is a wrapper around Matlab that makes
# it easier to run Matlab in batch mode and log the output of scripts.
# Used with Matlab 2009B and 2016b.
#
# This wrapper is necessary because Matlab misbehaves.  It does not set
# a nonzero exit status on error, and tries to execute GUI code by
# default. 
#
# PARAMETERS
# 	$1	    	The Matlab program (with or without .m; may contain directory) 
# 	$jvm_enable	Ignored -- the JVM must now always be enabled
#			due to the new Matlab version's failure.  (was:
#			Enable the JVM; the JVM is disabled by default) 
#	$verbose	When set, enable verbose mode (mainly for debugging)
#	$MATLAB_PARAMS	Space-separated list of environment variables
#			that are passed to the Matlab script, and
#			whose values should be integrated into the
#			logfile name, such that multiple instances can
#			run in parallel. 
# 
# FILES
#	error.log	Errors from all runs of this script are appended
#			to this file  
#
# EXAMPLE
#
#	to run m/map.m, use ./matlab m/map.m 
#
# Matlab scripts run using this method usually don't use command line
# arguments.  Instead, environment variables are passed.  
#
# If multiple runs are done in parallel with the same network/type
# arguments, their logfiles may overwrite each other.  In that case,
# users must set a different $TMPDIR. 
#

#
# Setup files 
#

# Verbose output
[ $verbose ] && exec 4>&2 || exec 4>/dev/null 

# Error log
exec 6>>error.log

#
# Matlab configuration
#

# The command to use
MATLAB=matlab

# Always set to '1' because it breaks the new Matlab version 
jvm_enable=1

# The options to use for Matlab 
MATLAB_OPTIONS="-nodesktop -nosplash"
if [ -z "$jvm_enable" ] ; then
	MATLAB_OPTIONS="$MATLAB_OPTIONS -nojvm"
fi

# Perl regular expression that matches all errors in the log or output
# of Matlab.  When these are encountered, the Matlab process is ended. 
pre_error='/\?\?\?|^\*\*\*[^*]|^Error (in|using) |Java exception occurred:|std::exception|Unexpected error|failed to map segment|Segmentation violation|Abnormal termination|cannot allocate memory|Out of memory|^Can'\''t reload '\''/'

# Prefix
[ "$PREFIX" ] && PREFIX=.$PREFIX
export PREFIX

# The name of script within Matlab
SCRIPT=$1
export MATLAB_NAME="$(basename $SCRIPT | sed -E -e 's,\.m$,,')"
echo >&4 "MATLAB_NAME=«$MATLAB_NAME»"

# Check that the file exists
FILENAME=$SCRIPT
if echo "$FILENAME" | grep -qvE '\.m$' ; then
	FILENAME=$FILENAME.m
	if ! [ -r "$FILENAME" ] ; then
		echo >&2 "*** No such file:  $FILENAME"
		exit 1
	fi
fi

#
# Logging
#

LOGNAME=$MATLAB_NAME
# This is a list of variable we want to be used in the log filename to
# make it unique.
[ "$type"    ]     	&& LOGNAME=$LOGNAME.$type
[ "$name"   ]      	&& LOGNAME=$LOGNAME.$name
[ "$decomposition" ]	&& LOGNAME=$LOGNAME.$decomposition
[ "$statistic" ]	&& LOGNAME=$LOGNAME.$statistic
[ "$method" ]		&& LOGNAME=$LOGNAME.$method
[ "$kind"   ]      	&& LOGNAME=$LOGNAME.$kind
[ "$class"   ]      	&& LOGNAME=$LOGNAME.$class
[ "$group"   ]      	&& LOGNAME=$LOGNAME.$group
[ "$year"   ]      	&& LOGNAME=$LOGNAME.$year
[ "$network" ]		&& LOGNAME=$LOGNAME.$(basename "$network")

for PARAM in $MATLAB_PARAMS
do
	eval [ "\$$PARAM"   ]   	&& eval LOGNAME=\$LOGNAME.\$$PARAM
done

echo >&4 "LOGNAME='$LOGNAME'"

export LOGNAME

export TMP_BASE="${TMPDIR-/tmp}"/m."$LOGNAME$PREFIX"
export LOGFILE="$TMP_BASE".log
export OUTFILE="$TMP_BASE".out
rm -f -- "$LOGFILE" "$OUTFILE" || { echo >&2 "*** error: rm" ; exit 1 ; }
printf >&2 '\t%s\n' "$LOGFILE"

#
# Other configurations
#

DISPLAY=

# By default, glibc errors are written to the terminal directly.  This
# will send them to stderr.  (Matlab has been known to trigger such errors.)  
export LIBC_FATAL_STDERR_=1

DIR_SCRIPT=$(dirname "$SCRIPT")
if echo "$DIR_SCRIPT" | grep -vq '^/' ; then
	DIR_SCRIPT=$PWD/$DIR_SCRIPT
fi
export MATLABPATH="$DIR_SCRIPT:$MATLABPATH"
echo >&4 MATLABPATH=«$MATLABPATH»

tailpidfile=$TMP_BASE.tpf
matlabpidfile=$TMP_BASE.mpf
export tailpidfile matlabpidfile
echo >&4 matlabpidfile=«$matlabpidfile»

{
	# We have to use <<EOF or else Matlab will read its standard input and hang.
	"$MATLAB" -logfile "$LOGFILE" -r "$MATLAB_NAME" $MATLAB_OPTIONS >"$OUTFILE" 2>&1 & <<EOF
EOF
	matlabpid=$!
	echo $matlabpid >"$matlabpidfile"
	wait $matlabpid
	matlab_status=$?
	if [ "$matlab_status" != 0 ] ; then
		echo >>"$LOGFILE" "*** Error:  Matlab failed with exit status $matlab_status"
	fi
	# MATLAB_TERMINATED is needed in case Matlab terminates but perl does not:  in
	# that case perl would continue to run, hanging this script. 
	echo >>"$LOGFILE" MATLAB_TERMINATED
	echo >&4 END OF MATLAB
	exit $matlab_status
} &
id_matlab=$!

# We don't use grep -q here because it doesn't work on the KONECT server.  It
# did work on newer installs, so maybe this is just a consequence of the KONECT
# server's config. 
{
	{
		tail -q -F "$LOGFILE" "$OUTFILE" 2>/dev/null &
		tailpid=$!
		echo $tailpid >"$tailpidfile"
	} | {
		perl 2>>"$LOGFILE" -e '
			while (<>) {
				if ('"$pre_error"') { 
					print STDERR "*** Found error in matlab output:$_\n"; 
					exit 1; 
				}
				if (/MATLAB_TERMINATED/) { 
##					print STDERR "Found MATLAB_TERMINATED\n"; 
					exit 0; 
				}
			}
	        ' 
		perl_status=$?
		echo >&4 perl_status=$perl_status
		kill $(echo $(cat $tailpidfile)) 2>/dev/null
		kill $(echo $(cat $matlabpidfile)) 2>/dev/null 
		if [ $perl_status != 0 ] ; then
			kill $id_matlab 2>/dev/null
			wait $id_matlab
			echo >&2 "*** Error in $TMP_BASE.log"
			echo >&6 "*** Error in $TMP_BASE.log"
			exit 1
		fi
	}
} 

echo >&4 "WAIT(id=$id_matlab)..."
wait $id_matlab
matlab_status=$?
echo >&4 "DONE WAITING.  matlab_status=$matlab_status"
if [ "$matlab_status" != 0 ] ; then
##	echo >&2 "*** Error in $TMP_BASE.log"
##	echo >&6 "*** Error in $TMP_BASE.log"
	exit 1
fi

echo >>"$TMP_BASE".log '=== FINISHED SUCCESSFULLY ==='

exit 0
