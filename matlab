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

# We have to use <<EOF or else Matlab will read its standard input and hang.
"$MATLAB" -logfile "$LOGFILE" -r "$MATLAB_NAME" $MATLAB_OPTIONS  \
	>"$TMP_BASE".out 2>&1 <<EOF  ||
EOF
{ 
	# Note: Matlab normally always exists with exit code 0 on a
	# syntax or other "normal" error, so if we are here Matlab
	# probably crashed or was killed by a signal. 

	exitstatus=$?
	echo >&2 "*** error in $TMP_BASE.log"
	echo >&6 "*** error in $TMP_BASE.log"
	if [ "$exitstatus" = 0 ] ; then
		echo >&2 "*** error:  exit status of Matlab was 0"
		exit 1
	fi
	exit "$exitstatus"
}


# Matlab does not exit(!=0) on error but prints an assortment of unformatted
# error messages.  
grep -qE '(\?\?\?|^\*\*\* |^Error (in|using) |Java exception occurred:)' $TMP_BASE.log && 
{
	echo "*** error in $TMP_BASE.log"
	echo >&6 "*** error in $TMP_BASE.log"
	<$TMP_BASE.log >&2 sed -E -e '
		# Matlab output actually contains { and } sequences. 
		s,.,,g
		/\?\?\?|\*\*\*|[Ee]rror/!d
		s,^(|\?\?\? )Error (in|using) ==> ([^ ]+) at ([0-9]+)$,\3.m:\4: ,
		T
		N
		s,\n,,
	'
	exit 1
}

echo >>"$TMP_BASE".log '=== FINISHED SUCCESSFULLY ==='

exit 0
