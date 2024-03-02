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

my $testCodeMutexRecursive = << 'EOF';
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

my $testCodeMutexRecursiveNP = << 'EOF';
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
	MkCompileC('HAVE_PTHREAD_MUTEX_RECURSIVE', '${PTHREADS_CFLAGS}', '${PTHREADS_LIBS}',
	    $testCodeMutexRecursive);
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
	    '${PTHREADS_CFLAGS}', '${PTHREADS_LIBS}', $testCodeMutexRecursiveNP);
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

sub CMAKE_pthreads
{
	my $codeStd = MkCodeCMAKE($testCodeStd);
	my $codeMutexRecursive = MkCodeCMAKE($testCodeMutexRecursive);
	my $codeMutexRecursiveNP = MkCodeCMAKE($testCodeMutexRecursiveNP);
	my $codeXopen = MkCodeCMAKE($testCodeXopen);
	my $codeMutexIsPointer = MkCodeCMAKE($testIfMutexIsPointer);
	my $codeCondIsPointer = MkCodeCMAKE($testIfCondIsPointer);
	my $codeThreadIsPointer = MkCodeCMAKE($testIfThreadIsPointer);

	return << "EOF";
macro(Check_Pthreads)
	set(ORIG_CMAKE_REQUIRED_FLAGS \${CMAKE_REQUIRED_FLAGS})
	set(ORIG_CMAKE_REQUIRED_LIBRARIES \${CMAKE_REQUIRED_LIBRARIES})

	set(PTHREADS_CFLAGS "")

	find_library(PTHREADS_LIBS NAMES "pthread")

	set(CMAKE_REQUIRED_LIBRARIES "\${CMAKE_REQUIRED_LIBRARIES} \${PTHREADS_LIBS}")
	check_c_source_compiles("
$codeStd" HAVE_PTHREADS)
	if (HAVE_PTHREADS)
		BB_Save_Define(HAVE_PTHREADS)
	else()
		#
		# Check for the -pthread flag (older OpenBSD, etc.)
		#
		set(CMAKE_REQUIRED_FLAGS "\${ORIG_CMAKE_REQUIRED_FLAGS} -pthread")
		check_c_source_compiles("
$codeStd" HAVE_PTHREADS_PTHREAD_FLAG)
		if (HAVE_PTHREADS_PTHREAD_FLAG)
			set(PTHREADS_CFLAGS "-pthread")
			set(PTHREADS_LIBS "")
			set(HAVE_PTHREADS ON)
			BB_Save_Define(HAVE_PTHREADS)
		else()
			BB_Save_Undef(HAVE_PTHREADS)
		endif()
		set(CMAKE_REQUIRED_FLAGS \${ORIG_CMAKE_REQUIRED_FLAGS})
	endif()

	check_c_source_compiles("
$codeMutexRecursive" HAVE_PTHREAD_MUTEX_RECURSIVE)
	if(HAVE_PTHREAD_MUTEX_RECURSIVE)
		BB_Save_Define(HAVE_PTHREAD_MUTEX_RECURSIVE)
	else()
		BB_Save_Undef(HAVE_PTHREAD_MUTEX_RECURSIVE)
	endif()

	check_c_source_compiles("
$codeMutexRecursiveNP" HAVE_PTHREAD_MUTEX_RECURSIVE_NP)
	if(HAVE_PTHREAD_MUTEX_RECURSIVE_NP)
		BB_Save_Define(HAVE_PTHREAD_MUTEX_RECURSIVE_NP)
	else()
		BB_Save_Undef(HAVE_PTHREAD_MUTEX_RECURSIVE_NP)
	endif()

	check_c_source_compiles("
$codeMutexIsPointer" HAVE_PTHREAD_MUTEX_T_POINTER)
	if(HAVE_PTHREAD_MUTEX_T_POINTER)
		BB_Save_Define(HAVE_PTHREAD_MUTEX_T_POINTER)
	else()
		BB_Save_Undef(HAVE_PTHREAD_MUTEX_T_POINTER)
	endif()

	check_c_source_compiles("
$codeCondIsPointer" HAVE_PTHREAD_COND_T_POINTER)
	if(HAVE_PTHREAD_COND_T_POINTER)
		BB_Save_Define(HAVE_PTHREAD_COND_T_POINTER)
	else()
		BB_Save_Undef(HAVE_PTHREAD_COND_T_POINTER)
	endif()

	check_c_source_compiles("
$codeThreadIsPointer" HAVE_PTHREAD_T_POINTER)
	if(HAVE_PTHREAD_T_POINTER)
		BB_Save_Define(HAVE_PTHREAD_T_POINTER)
	else()
		BB_Save_Undef(HAVE_PTHREAD_T_POINTER)
	endif()

	if(NOT FREEBSD)
		set(CMAKE_REQUIRED_FLAGS "\${CMAKE_REQUIRED_FLAGS} -U_XOPEN_SOURCE -D_XOPEN_SOURCE=600")
	endif()
	check_c_source_compiles("
$codeXopen" HAVE_PTHREADS_XOPEN)
	if(HAVE_PTHREADS_XOPEN)
		if(NOT FREEBSD)
			set(PTHREADS_XOPEN_CFLAGS "-U_XOPEN_SOURCE -D_XOPEN_SOURCE=600")
		endif()
		BB_Save_Define(HAVE_PTHREADS_XOPEN)
	else()
		BB_Save_Undef(HAVE_PTHREADS_XOPEN)
	endif()

	BB_Save_MakeVar(PTHREADS_CFLAGS "\${PTHREADS_CFLAGS}")
	BB_Save_MakeVar(PTHREADS_LIBS "\${PTHREADS_LIBS}")
	BB_Save_MakeVar(PTHREADS_XOPEN_CFLAGS "\${PTHREADS_XOPEN_CFLAGS}")
	BB_Save_MakeVar(PTHREADS_XOPEN_LIBS "")

	set(CMAKE_REQUIRED_FLAGS \${ORIG_CMAKE_REQUIRED_FLAGS})
	set(CMAKE_REQUIRED_LIBRARIES \${ORIG_CMAKE_REQUIRED_LIBRARIES})
endmacro()

macro(Disable_Pthreads)
	BB_Save_MakeVar(PTHREADS_CFLAGS "")
	BB_Save_MakeVar(PTHREADS_LIBS "")
	BB_Save_MakeVar(PTHREADS_XOPEN_CFLAGS "")
	BB_Save_MakeVar(PTHREADS_XOPEN_LIBS "")

	BB_Save_Undef(HAVE_PTHREADS)
	BB_Save_Undef(HAVE_PTHREADS_XOPEN)
	BB_Save_Undef(HAVE_PTHREAD_MUTEX_RECURSIVE)
	BB_Save_Undef(HAVE_PTHREAD_MUTEX_RECURSIVE_NP)
	BB_Save_Undef(HAVE_PTHREAD_MUTEX_T_POINTER)
	BB_Save_Undef(HAVE_PTHREAD_COND_T_POINTER)
	BB_Save_Undef(HAVE_PTHREAD_T_POINTER)
endmacro()
EOF
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

BEGIN
{
	my $n = 'pthreads';

	$DESCR{$n}   = 'POSIX threads';
	$TESTS{$n}   = \&TEST_pthreads;
	$CMAKE{$n}   = \&CMAKE_pthreads;
	$DISABLE{$n} = \&DISABLE_pthreads;
	$DEPS{$n}    = 'cc';
	$SAVED{$n}   = 'CFLAGS PTHREADS_CFLAGS PTHREADS_LIBS ' .
	               'PTHREADS_XOPEN_CFLAGS PTHREADS_XOPEN_LIBS';
}
;1
