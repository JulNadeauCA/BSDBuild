# $Csoft: opengl.pm,v 1.5 2004/03/10 16:33:36 vedge Exp $
# vim:ts=4
#
# Copyright (c) 2005 CubeSoft Communications, Inc.
# <http://www.csoft.org>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
# USE OF THIS SOFTWARE EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

my @include_dirs = (
	'/usr/include/pthreads',
	'/usr/local/include',
	'/usr/local/include/pthreads',
);

my @lib_dirs = (
	'/usr/local/lib',
);

my @lib_files = (
	'pthread',
	'pthreadGC1',
	'pthreadGC1d',
	'pthreadGCE1',
	'pthreadGCE1d',
	'pthreadGC2',
	'pthreadGC2d',
	'pthreadGCE2',
	'pthreadGCE2d',
);

my $test_std = << 'EOF';
#include <pthread.h>
#include <signal.h>

static void *start_routine(void *arg)
{
	return (NULL);
}
int main(int argc, char *argv[])
{
	pthread_mutex_t mutex;
	pthread_t thread;
	pthread_mutex_init(&mutex, NULL);
	pthread_mutex_lock(&mutex);
	pthread_mutex_unlock(&mutex);
	pthread_mutex_destroy(&mutex);
	pthread_create(&thread, NULL, start_routine, NULL);
	return (0);
}
EOF

my $test_xopen = << 'EOF';
#include <pthread.h>
#include <signal.h>

int main(int argc, char *argv[])
{
	pthread_mutex_t mutex;
	pthread_mutexattr_t mutexattr;
	pthread_mutexattr_settype(&mutexattr, PTHREAD_MUTEX_RECURSIVE);
	pthread_mutex_init(&mutex, &mutexattr);
	return (0);
}
EOF

sub SearchIncludes ($)
{
	my $def = shift;

	foreach my $dir (@include_dirs) {
		MkIf qq{-f "$dir/pthread.h"};
			MkDefine('PTHREADS_CFLAGS', "-I$dir");
		MkEndif;
	}
}

sub SearchLibs ($)
{
	my $def = shift;

	foreach my $dir (@lib_dirs) {
		foreach my $file (@lib_files) {
			MkIf qq{-f "$dir/lib$file.a"};
				MkDefine($def, "-L$dir -l$file");
			MkEndif;
		}
	}
}

sub TestPthreadsStd
{
	MkDefine('PTHREADS_CFLAGS', '');
	MkDefine('PTHREADS_LIBS', "-lpthread");

	# Try the standard -lpthread.
	MkCompileC('HAVE_PTHREADS',
	    '${PTHREADS_CFLAGS}', '${PTHREADS_LIBS}',
	    $test_std);
	MkIf('"${HAVE_PTHREADS}" = "yes"');
		MkDefine('CFLAGS', '${CFLAGS} ${PTHREADS_CFLAGS}');
		MkSaveMK('CFLAGS', 'PTHREADS_CFLAGS', 'PTHREADS_LIBS');
		MkSaveDefine('PTHREADS_CFLAGS', 'PTHREADS_LIBS');
	MkElse();
		# Fallback to -pthread.
		MkPrintN('checking for -pthread...');
		MkDefine('PTHREADS_LIBS', '-pthread');
		MkCompileC('HAVE_PTHREADS',
		    '${PTHREADS_CFLAGS}', '${PTHREADS_LIBS}',
			$test_std);
		MkIf('"${HAVE_PTHREADS}" = "yes"');
			MkDefine('CFLAGS', '${CFLAGS} ${PTHREADS_CFLAGS}');
			MkSaveMK('CFLAGS', 'PTHREADS_CFLAGS','PTHREADS_LIBS');
			MkSaveDefine('PTHREADS_CFLAGS','PTHREADS_LIBS');
		MkElse();
			# Fallback to scanning libs and include files.
			MkDefine('PTHREADS_CFLAGS', '');
			MkDefine('PTHREADS_LIBS', '');
			MkPrintN('checking for -pthread (common paths)...');
			SearchIncludes('PTHREADS_CFLAGS');
			SearchLibs('PTHREADS_LIBS');
			MkCompileC('HAVE_PTHREADS',
			    '${PTHREADS_CFLAGS}', '${PTHREADS_LIBS}',
				$test_std);
			MkIf('"${HAVE_PTHREADS}" = "yes"');
				MkDefine('CFLAGS', '${CFLAGS} ${PTHREADS_CFLAGS}');
				MkSaveMK('CFLAGS', 'PTHREADS_CFLAGS', 'PTHREADS_LIBS');
				MkSaveDefine('PTHREADS_CFLAGS', 'PTHREADS_LIBS');
			MkEndif();
		MkEndif();
	MkEndif();
	return (0);
}

sub TestPthreadMutexRecursive
{
	#
	# Look for the PTHREAD_MUTEX_RECURSIVE flag of the function
	# pthread_mutexattr_settype().
	#
	MkPrintN('checking for PTHREAD_MUTEX_RECURSIVE...');
	MkCompileC('HAVE_PTHREAD_MUTEX_RECURSIVE',
	    '${PTHREADS_CFLAGS}', '${PTHREADS_LIBS}', << 'EOF');
#include <pthread.h>
#include <signal.h>
int main(int argc, char *argv[])
{
	pthread_mutex_t mutex;
	pthread_mutexattr_t mutexattr;
	pthread_mutexattr_settype(&mutexattr, PTHREAD_MUTEX_RECURSIVE);
	pthread_mutex_init(&mutex, &mutexattr);
	return (0);
}
EOF
	MkIf('"${HAVE_PTHREAD_MUTEX_RECURSIVE}" = "yes"');
		MkSaveDefine('HAVE_PTHREAD_MUTEX_RECURSIVE');
	MkElse;
		MkSaveUndef('HAVE_PTHREAD_MUTEX_RECURSIVE');
	MkEndif;
	
	#
	# Look for the PTHREAD_MUTEX_RECURSIVE_NP flag of the function
	# pthread_mutexattr_settype().
	#
	MkPrintN('checking for PTHREAD_MUTEX_RECURSIVE_NP...');
	MkCompileC('HAVE_PTHREAD_MUTEX_RECURSIVE_NP',
	    '${PTHREADS_CFLAGS}', '${PTHREADS_LIBS}', << 'EOF');
#include <pthread.h>
#include <signal.h>
int main(int argc, char *argv[])
{
	pthread_mutex_t mutex;
	pthread_mutexattr_t mutexattr;
	pthread_mutexattr_settype(&mutexattr, PTHREAD_MUTEX_RECURSIVE_NP);
	pthread_mutex_init(&mutex, &mutexattr);
	return (0);
}
EOF
	MkIf('"${HAVE_PTHREAD_MUTEX_RECURSIVE_NP}" = "yes"');
		MkSaveDefine('HAVE_PTHREAD_MUTEX_RECURSIVE_NP');
	MkElse;
		MkSaveUndef('HAVE_PTHREAD_MUTEX_RECURSIVE_NP');
	MkEndif;
	return (0);
}

sub TestPthreadsXOpenExt
{
	MkPrintN('checking for the X/Open Threads Extension...');

	# Define _XOPEN_SOURCE=600 except under FreeBSD.
	MkIf('"${SYSTEM}" = "FreeBSD"');
		MkDefine('PTHREADS_XOPEN_CFLAGS', '');
	MkElse;
		MkDefine('PTHREADS_XOPEN_CFLAGS',
		         '-U_XOPEN_SOURCE -D_XOPEN_SOURCE=600');
	MkEndif;

	# Try the standard -lpthread
	MkDefine('PTHREADS_XOPEN_LIBS', "-lpthread");
	MkCompileC('HAVE_PTHREADS_XOPEN',
	    '${PTHREADS_XOPEN_CFLAGS}', '${PTHREADS_XOPEN_LIBS}',
		$test_xopen);
	MkIf('"${HAVE_PTHREADS_XOPEN}" = "yes"');
		MkSaveMK('PTHREADS_XOPEN_CFLAGS', 'PTHREADS_XOPEN_LIBS');
		MkSaveDefine('HAVE_PTHREADS_XOPEN');
		MkSaveDefine('PTHREADS_XOPEN_CFLAGS', 'PTHREADS_XOPEN_LIBS');
	MkElse;
		# Fallback to scanning libraries and includes.
		MkDefine('PTHREADS_XOPEN_LIBS', '');
		MkPrintN('checking for the X/Open Threads Extension (common paths)...');
		SearchLibs('PTHREADS_XOPEN_LIBS');
		SearchIncludes('PTHREADS_XOPEN_CFLAGS');
		MkCompileC('HAVE_PTHREADS_XOPEN',
		    '${PTHREADS_XOPEN_CFLAGS}', '${PTHREADS_XOPEN_LIBS}',
			$test_xopen);
		MkIf('"${HAVE_PTHREADS_XOPEN}" = "yes"');
			MkSaveMK('PTHREADS_XOPEN_CFLAGS', 'PTHREADS_XOPEN_LIBS');
			MkSaveDefine('HAVE_PTHREADS_XOPEN');
			MkSaveDefine('PTHREADS_XOPEN_CFLAGS', 'PTHREADS_XOPEN_LIBS');
		MkElse;
			MkSaveUndef('HAVE_PTHREADS_XOPEN');
		MkEndif;
	MkEndif;
	return (0);
}

sub TestPthreads
{
	TestPthreadsStd();
	TestPthreadsXOpenExt();
	TestPthreadMutexRecursive();
	return (0);
}

sub Emul
{
	my ($os, $osrel, $machine) = @_;

	if ($os eq 'linux') {
		MkDefine('HAVE_PTHREADS', 'yes');
		MkDefine('HAVE_PTHREADS_XOPEN', 'yes');

		MkDefine('PTHREADS_CFLAGS', '');
		MkDefine('PTHREADS_LIBS', '-lpthread');
		MkDefine('PTHREADS_XOPEN_CFLAGS', '-U_XOPEN_SOURCE '.
		                                  '-D_XOPEN_SOURCE=600');
		MkDefine('PTHREADS_XOPEN_LIBS', '-lpthread');
	
		MkSaveDefine('HAVE_PTHREADS', 'HAVE_PTHREADS_XOPEN', 'PTHREADS_CFLAGS',
		             'PTHREADS_LIBS', 'PTHREADS_XOPEN_CFLAGS',
					 'PTHREADS_XOPEN_LIBS');

		MkSaveUndef('HAVE_PTHREAD_MUTEX_RECURSIVE');
		MkSaveUndef('HAVE_PTHREAD_MUTEX_RECURSIVE_NP');
		return (1);
	}
	if ($os eq 'darwin') {
		MkDefine('HAVE_PTHREADS', 'yes');
		MkDefine('HAVE_PTHREADS_XOPEN', 'yes');
		MkDefine('HAVE_PTHREAD_MUTEX_RECURSIVE', 'yes');

		MkDefine('PTHREADS_CFLAGS', '');
		MkDefine('PTHREADS_LIBS', '-lpthread');
		MkDefine('PTHREADS_XOPEN_CFLAGS', '-U_XOPEN_SOURCE '.
		                                  '-D_XOPEN_SOURCE=600');
		MkDefine('PTHREADS_XOPEN_LIBS', '-lpthread');

		MkSaveDefine('HAVE_PTHREADS', 'HAVE_PTHREADS_XOPEN', 'PTHREADS_CFLAGS',
		             'PTHREADS_LIBS', 'HAVE_PTHREAD_MUTEX_RECURSIVE');

		MkSaveUndef('HAVE_PTHREAD_MUTEX_RECURSIVE_NP');
		return (1);
	}
	if ($os eq 'windows') {
		MkDefine('HAVE_PTHREADS', 'yes');
		MkDefine('HAVE_PTHREADS_XOPEN', 'yes');
		MkDefine('HAVE_PTHREAD_MUTEX_RECURSIVE', 'yes');

		MkDefine('PTHREADS_CFLAGS', '');
		MkDefine('PTHREADS_LIBS', 'pthreadVC2');
		MkDefine('PTHREADS_XOPEN_CFLAGS', '-U_XOPEN_SOURCE '.
		                                  '-D_XOPEN_SOURCE=600');
		MkDefine('PTHREADS_XOPEN_LIBS', 'pthreadVC2');

		MkSaveDefine('HAVE_PTHREADS', 'HAVE_PTHREADS_XOPEN', 'PTHREADS_CFLAGS',
		             'PTHREADS_LIBS', 'HAVE_PTHREAD_MUTEX_RECURSIVE');

		MkSaveUndef('HAVE_PTHREAD_MUTEX_RECURSIVE_NP');
		return (1);
	}
	if ($os =~ /^(net|open)bsd$/) {
		MkDefine('HAVE_PTHREADS', 'yes');
		MkDefine('HAVE_PTHREADS_XOPEN', 'yes');
		MkDefine('HAVE_PTHREAD_MUTEX_RECURSIVE', 'yes');

		MkDefine('PTHREADS_CFLAGS', '');
		MkDefine('PTHREADS_LIBS', '-lpthread');
		MkDefine('PTHREADS_XOPEN_CFLAGS', '-U_XOPEN_SOURCE '.
		                                  '-D_XOPEN_SOURCE=600');
		MkDefine('PTHREADS_XOPEN_LIBS', '-lpthread');

		MkSaveDefine('HAVE_PTHREADS', 'HAVE_PTHREADS_XOPEN', 'PTHREADS_CFLAGS',
		             'PTHREADS_LIBS', 'HAVE_PTHREAD_MUTEX_RECURSIVE');

		MkSaveUndef('HAVE_PTHREAD_MUTEX_RECURSIVE_NP');
		return (1);
	}
	if ($os eq 'freebsd') {
		MkDefine('HAVE_PTHREADS', 'yes');
		MkDefine('HAVE_PTHREADS_XOPEN', 'yes');
		MkDefine('HAVE_PTHREAD_MUTEX_RECURSIVE', 'yes');

		MkDefine('PTHREADS_CFLAGS', '');
		MkDefine('PTHREADS_LIBS', '-lpthread');
		MkDefine('PTHREADS_XOPEN_CFLAGS', '');
		MkDefine('PTHREADS_XOPEN_LIBS', '-lpthread');

		MkSaveDefine('HAVE_PTHREADS', 'HAVE_PTHREADS_XOPEN', 'PTHREADS_CFLAGS',
		             'PTHREADS_LIBS', 'HAVE_PTHREAD_MUTEX_RECURSIVE');

		MkSaveUndef('HAVE_PTHREAD_MUTEX_RECURSIVE_NP');
		return (1);
	}
	return (1);
}

sub Link
{
	my $lib = shift;

	if ($lib eq 'pthreads') {
			print << 'EOF';
if (hdefs["HAVE_PTHREADS"] ~= nil) then
	if (windows) then
		table.insert(package.links, { "pthreadVC2" })
	else
		table.insert(package.links, { "pthread" })
	end
end
EOF
		return (1);
	}
	return (0);
}

BEGIN
{
	$DESCR{'pthreads'} = 'POSIX threads';
	$TESTS{'pthreads'} = \&TestPthreads;
	$EMUL{'pthreads'} = \&Emul;
	$LINK{'pthreads'} = \&Link;
	$DEPS{'pthreads'} = 'cc';
}

;1
