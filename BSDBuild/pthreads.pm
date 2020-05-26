# Public domain

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

	MkCompileC('HAVE_PTHREADS',
	           '${PTHREADS_CFLAGS}', '${PTHREADS_LIBS}',
	           $testCodeStd);
	MkIfTrue('${HAVE_PTHREADS}');
		MkDefine('CFLAGS', '${CFLAGS} ${PTHREADS_CFLAGS}');
	MkElse;
		MkPrintSN('checking for -pthread...');
		MkDefine('PTHREADS_LIBS', '-pthread');
		MkCompileC('HAVE_PTHREADS',
		           '${PTHREADS_CFLAGS}', '${PTHREADS_LIBS}',
			   $testCodeStd);
		MkIfTrue('${HAVE_PTHREADS}');
			MkDefine('CFLAGS', '${CFLAGS} ${PTHREADS_CFLAGS}');
		MkElse;
			MkDefine('PTHREADS_CFLAGS', '');
			MkDefine('PTHREADS_LIBS', '');

			MkPrintSN('checking for -pthread (common paths)...');
			SearchIncludes($pfx, 'PTHREADS_CFLAGS');
			SearchLibs($pfx, 'PTHREADS_LIBS');
			MkCompileC('HAVE_PTHREADS',
			           '${PTHREADS_CFLAGS}', '${PTHREADS_LIBS}',
			           $testCodeStd);
			MkIfTrue('${HAVE_PTHREADS}');
				MkDefine('CFLAGS', '${CFLAGS} ${PTHREADS_CFLAGS}');
			MkElse;
				MkDisableFailed('pthreads');
			MkEndif;
		MkEndif;
	MkEndif;
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
	           '${PTHREADS_CFLAGS}', '${PTHREADS_LIBS}',
		   $testIfMutexIsPointer);
	
	MkPrintSN('checking whether pthread_cond_t is a pointer...');
	MkCompileC('HAVE_PTHREAD_COND_T_POINTER',
	           '${PTHREADS_CFLAGS}', '${PTHREADS_LIBS}',
		   $testIfCondIsPointer);
	
	MkPrintSN('checking whether pthread_t is a pointer...');
	MkCompileC('HAVE_PTHREAD_T_POINTER',
	           '${PTHREADS_CFLAGS}', '${PTHREADS_LIBS}',
		   $testIfThreadIsPointer);
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

	MkCompileC('HAVE_PTHREADS_XOPEN',
	           '${PTHREADS_XOPEN_CFLAGS}', '${PTHREADS_XOPEN_LIBS}',
	           $testCodeXopen);
	MkIfTrue('${HAVE_PTHREADS_XOPEN}');
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
	MkDefine('HAVE_PTHREADS', 'no') unless $TestFailed;
	MkDefine('HAVE_PTHREADS_XOPEN', 'no');
	MkDefine('HAVE_PTHREAD_MUTEX_RECURSIVE', 'no');
	MkDefine('HAVE_PTHREAD_MUTEX_RECURSIVE_NP', 'no');
	MkDefine('HAVE_PTHREAD_MUTEX_T_POINTER', 'no');
	MkDefine('HAVE_PTHREAD_COND_T_POINTER', 'no');
	MkDefine('HAVE_PTHREAD_T_POINTER', 'no');

	MkDefine('PTHREADS_CFLAGS', '');
	MkDefine('PTHREADS_LIBS', '');
	MkDefine('PTHREADS_XOPEN_CFLAGS', '');
	MkDefine('PTHREADS_XOPEN_LIBS', '');

	MkSaveUndef('HAVE_PTHREADS', 'HAVE_PTHREADS_XOPEN',
	            'HAVE_PTHREAD_MUTEX_RECURSIVE',
	            'HAVE_PTHREAD_MUTEX_RECURSIVE_NP',
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
	} else {
		MkDisableNotFound('pthreads');
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
	$SAVED{$n}   = 'CFLAGS PTHREADS_CFLAGS PTHREADS_LIBS ' .
	               'PTHREADS_XOPEN_CFLAGS PTHREADS_XOPEN_LIBS';
}
;1
