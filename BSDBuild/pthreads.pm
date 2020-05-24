# vim:ts=4
#
# Copyright (c) 2005-2018 Julien Nadeau Carriere <vedge@csoft.net>
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

my @autoIncludeDirs = (
	'/usr/include/pthreads',
	'/usr/local/include',
	'/usr/local/include/pthreads',
);
my @autoLibDirs = (
	'/usr/local/lib',
);
my @autoLibFiles = (
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

my $testCodeStd = << 'EOF';
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

my $testCodeXopen = << 'EOF';
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

my $testIfMutexIsPointer = << 'EOF';
#include <pthread.h>

int main(int argc, char *argv[])
{
	pthread_mutex_t mutex = NULL;
	pthread_mutex_init(&mutex, NULL);
	return (mutex != NULL);
}
EOF

my $testIfCondIsPointer = << 'EOF';
#include <pthread.h>

int main(int argc, char *argv[])
{
	pthread_cond_t cond = NULL;
	pthread_cond_init(&cond, NULL);
	return (cond != NULL);
}
EOF

my $testIfThreadIsPointer = << 'EOF';
#include <pthread.h>
static void *start_routine(void *arg) { return (NULL); }
int main(int argc, char *argv[])
{
	pthread_t th = NULL;
	return pthread_create(&th, NULL, start_routine, NULL);
}
EOF

sub SearchIncludes ($$)
{
	my ($pfx, $def) = @_;

	foreach my $dir ("$pfx/lib", @autoIncludeDirs) {
		MkIfExists("$dir/pthread.h");
			MkDefine('PTHREADS_CFLAGS', "-I$dir");
		MkEndif;
	}
}

sub SearchLibs ($$)
{
	my ($pfx, $def) = @_;

	foreach my $dir ("$pfx/lib", @autoLibDirs) {
		foreach my $file (@autoLibFiles) {
			MkIfExists("$dir/lib$file.a");
				MkDefine($def, "-L$dir -l$file");
			MkEndif;
		}
	}
}

sub TEST_pthreads_std
{
	my ($ver, $pfx) = @_;

	MkIfNE($pfx, '');
		MkDefine('PTHREADS_CFLAGS', "-I$pfx/include");
		MkDefine('PTHREADS_LIBS', "-L$pfx/lib -lpthread");
	MkElse;
		MkDefine('PTHREADS_CFLAGS', '');
		MkDefine('PTHREADS_LIBS', "-lpthread");
	MkEndif;

	# Try the standard -lpthread.
	MkCompileC('HAVE_PTHREADS', '${PTHREADS_CFLAGS}', '${PTHREADS_LIBS}', $testCodeStd);
	MkIfTrue('${HAVE_PTHREADS}');
		MkDefine('CFLAGS', '${CFLAGS} ${PTHREADS_CFLAGS}');
		MkSaveMK('CFLAGS', 'PTHREADS_CFLAGS', 'PTHREADS_LIBS');
	MkElse();
		# Fallback to -pthread.
		MkPrintSN('checking for -pthread...');
		MkDefine('PTHREADS_LIBS', '-pthread');
		MkCompileC('HAVE_PTHREADS', '${PTHREADS_CFLAGS}', '${PTHREADS_LIBS}', $testCodeStd);
		MkIf('"${HAVE_PTHREADS}" = "yes"');
			MkDefine('CFLAGS', '${CFLAGS} ${PTHREADS_CFLAGS}');
			MkSaveMK('CFLAGS', 'PTHREADS_CFLAGS','PTHREADS_LIBS');
		MkElse();
			# Fallback to scanning libs and include files.
			MkDefine('PTHREADS_CFLAGS', '');
			MkDefine('PTHREADS_LIBS', '');
			MkPrintSN('checking for -pthread (common paths)...');
			SearchIncludes($pfx, 'PTHREADS_CFLAGS');
			SearchLibs($pfx, 'PTHREADS_LIBS');
			MkCompileC('HAVE_PTHREADS',
			    '${PTHREADS_CFLAGS}', '${PTHREADS_LIBS}',
				$testCodeStd);
			MkIf('"${HAVE_PTHREADS}" = "yes"');
				MkDefine('CFLAGS', '${CFLAGS} ${PTHREADS_CFLAGS}');
				MkSaveMK('CFLAGS', 'PTHREADS_CFLAGS', 'PTHREADS_LIBS');
			MkEndif();
		MkEndif();
	MkEndif();
}

sub TEST_pthreads_recursive_mutex
{
	#
	# Look for the PTHREAD_MUTEX_RECURSIVE flag of the function
	# pthread_mutexattr_settype().
	#
	MkPrintSN('checking for PTHREAD_MUTEX_RECURSIVE...');
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
	MkIfTrue('${HAVE_PTHREAD_MUTEX_RECURSIVE}');
		MkSaveDefine('HAVE_PTHREAD_MUTEX_RECURSIVE');
	MkElse;
		MkSaveUndef('HAVE_PTHREAD_MUTEX_RECURSIVE');
	MkEndif;
	
	#
	# Look for the PTHREAD_MUTEX_RECURSIVE_NP flag of the function
	# pthread_mutexattr_settype().
	#
	MkPrintSN('checking for PTHREAD_MUTEX_RECURSIVE_NP...');
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
	MkIfTrue('${HAVE_PTHREAD_MUTEX_RECURSIVE_NP}');
		MkSaveDefine('HAVE_PTHREAD_MUTEX_RECURSIVE_NP');
	MkElse;
		MkSaveUndef('HAVE_PTHREAD_MUTEX_RECURSIVE_NP');
	MkEndif;
}

sub TEST_pthreads_pointerness
{
	MkPrintSN('checking whether pthread_mutex_t is a pointer...');
	MkCompileC('HAVE_PTHREAD_MUTEX_T_POINTER',
	    '${PTHREADS_CFLAGS}', '${PTHREADS_LIBS}', $testIfMutexIsPointer);
	
	MkPrintSN('checking whether pthread_cond_t is a pointer...');
	MkCompileC('HAVE_PTHREAD_COND_T_POINTER',
	    '${PTHREADS_CFLAGS}', '${PTHREADS_LIBS}', $testIfCondIsPointer);
	
	MkPrintSN('checking whether pthread_t is a pointer...');
	MkCompileC('HAVE_PTHREAD_T_POINTER',
	    '${PTHREADS_CFLAGS}', '${PTHREADS_LIBS}', $testIfThreadIsPointer);
}

sub TEST_pthreads_xopen
{
	my ($ver, $pfx) = @_;

	MkPrintSN('checking for the X/Open Threads Extension...');

	MkCaseIn('${host}');
	MkCaseBegin('*-*-freebsd* | *-*-dragonfly*');
		MkDefine('PTHREADS_XOPEN_CFLAGS', '');
		MkCaseEnd;
	MkCaseBegin('*');
		MkDefine('PTHREADS_XOPEN_CFLAGS', '-U_XOPEN_SOURCE -D_XOPEN_SOURCE=600');
		MkCaseEnd;
	MkEsac;

	# Try the standard -lpthread
	MkIfNE($pfx, '');
		MkDefine('PTHREADS_XOPEN_LIBS', "-L$pfx/lib -lpthread");
	MkElse;
		MkDefine('PTHREADS_XOPEN_LIBS', "-lpthread");
	MkEndif;

	MkCompileC('HAVE_PTHREADS_XOPEN', '${PTHREADS_XOPEN_CFLAGS}', '${PTHREADS_XOPEN_LIBS}', $testCodeXopen);
	MkIfTrue('${HAVE_PTHREADS_XOPEN}');
		MkSaveMK('PTHREADS_XOPEN_CFLAGS', 'PTHREADS_XOPEN_LIBS');
		MkSaveDefine('HAVE_PTHREADS_XOPEN');
	MkElse;
		# Fallback to scanning libraries and includes.
		MkDefine('PTHREADS_XOPEN_LIBS', '');
		MkPrintSN('checking for the X/Open Threads Extension (common paths)...');
		SearchLibs($pfx, 'PTHREADS_XOPEN_LIBS');
		SearchIncludes($pfx, 'PTHREADS_XOPEN_CFLAGS');
		MkCompileC('HAVE_PTHREADS_XOPEN',
		    '${PTHREADS_XOPEN_CFLAGS}', '${PTHREADS_XOPEN_LIBS}',
			$testCodeXopen);
		MkIfTrue('${HAVE_PTHREADS_XOPEN}');
			MkSaveMK('PTHREADS_XOPEN_CFLAGS', 'PTHREADS_XOPEN_LIBS');
			MkSaveDefine('HAVE_PTHREADS_XOPEN');
		MkElse;
			MkSaveUndef('HAVE_PTHREADS_XOPEN');
		MkEndif;
	MkEndif;
}

sub TEST_pthreads
{
	TEST_pthreads_std(@_);
	TEST_pthreads_xopen(@_);
	TEST_pthreads_recursive_mutex();
	TEST_pthreads_pointerness();
}

sub DISABLE_pthreads
{
	MkDefine('HAVE_PTHREADS', 'no');
	MkDefine('HAVE_PTHREAD_MUTEX_RECURSIVE', 'no');
	MkDefine('HAVE_PTHREAD_MUTEX_RECURSIVE_NP', 'no');
	MkDefine('HAVE_PTHREADS_XOPEN', 'no');

	MkDefine('PTHREADS_CFLAGS', '');
	MkDefine('PTHREADS_LIBS', '');
	MkDefine('PTHREADS_XOPEN_CFLAGS', '');
	MkDefine('PTHREADS_XOPEN_LIBS', '');

	MkSaveUndef('HAVE_PTHREADS',
                'HAVE_PTHREAD_MUTEX_RECURSIVE',
                'HAVE_PTHREAD_MUTEX_RECURSIVE_NP',
	            'HAVE_PTHREADS_XOPEN',
	            'HAVE_PTHREAD_MUTEX_T_POINTER',
	            'HAVE_PTHREAD_COND_T_POINTER',
	            'HAVE_PTHREAD_T_POINTER');
}

sub EMUL_pthreads
{
	my ($os, $osrel, $machine) = @_;

	if ($os =~ /^windows/) {
		MkEmulWindows('PTHREADS', 'pthreadVC2');
		MkEmulWindows('PTHREADS_XOPEN', 'pthreadVC2');
		MkEmulWindowsSYS('PTHREAD_MUTEX_RECURSIVE');
		MkEmulUnavailSYS('PTHREAD_MUTEX_RECURSIVE_NP');

		MkDefine('PTHREADS_XOPEN_CFLAGS', '-U_XOPEN_SOURCE '.
		                                  '-D_XOPEN_SOURCE=600');
		MkSaveMK('PTHREADS_XOPEN_CFLAGS');
	} else {
		DISABLE_pthreads();
	}
	return (1);
}

BEGIN
{
	my $n = 'pthreads';

	$DESCR{$n}   = 'POSIX threads';
	$TESTS{$n}   = \&TEST_pthreads;
	$DISABLE{$n} = \&DISABLE_pthreads;
	$EMUL{$n}    = \&EMUL_pthreads;
	$DEPS{$n}    = 'cc';
}
;1
