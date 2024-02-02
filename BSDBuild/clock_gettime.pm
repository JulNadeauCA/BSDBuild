# Public domain

my $testCode = << 'EOF';
#include <time.h>
int
main(int argc, char *argv[])
{
	struct timespec ts;
	clock_gettime(CLOCK_REALTIME, &ts);
#ifdef __FreeBSD__
	clock_gettime(CLOCK_SECOND, &ts);
#endif
	return (0);
}
EOF

sub TEST_clock_gettime
{
	MkDefine('CLOCK_CFLAGS', '');
	MkDefine('CLOCK_LIBS', '');

	MkCompileC('HAVE_CLOCK_GETTIME',
	           '${CLOCK_CFLAGS}', '${CLOCK_LIBS}',
	           $testCode);
	MkIfTrue('${HAVE_CLOCK_GETTIME}');
		MkSaveDefine('HAVE_CLOCK_GETTIME');
	MkElse;
		MkPrintSN('checking for clock_gettime() interface (with -lrt)...');
		MkCompileC('HAVE_CLOCK_GETTIME',
		           '${CLOCK_CFLAGS}', '-lrt',
		           $testCode);
		MkIfTrue('${HAVE_CLOCK_GETTIME}');
			MkDefine('CLOCK_LIBS', '-lrt');
			MkSaveDefine('HAVE_CLOCK_GETTIME');
		MkElse;
			MkDisableFailed('clock_gettime');
		MkEndif;
	MkEndif;
}

sub CMAKE_clock_gettime
{
	my $code = MkCodeCMAKE($testCode);

	return << "EOF";
macro(Check_Clock_gettime)
	set(CLOCK_CFLAGS "")
	set(CLOCK_LIBS "")

	set(ORIG_CMAKE_REQUIRED_LIBRARIES \${CMAKE_REQUIRED_LIBRARIES})

	check_c_source_compiles("
$code" HAVE_CLOCK_GETTIME)
	if(HAVE_CLOCK_GETTIME)
		BB_Save_Define(HAVE_CLOCK_GETTIME)
	else()
		check_library_exists(rt clock_gettime "" HAVE_LIBRT_CLOCK_GETTIME)
		if(HAVE_LIBRT_CLOCK_GETTIME)
			set(CMAKE_REQUIRED_LIBRARIES "\${CMAKE_REQUIRED_LIBRARIES} -lrt")
			check_c_source_compiles("
$code" HAVE_CLOCK_GETTIME_IN_LIBRT)
			if(HAVE_CLOCK_GETTIME_IN_LIBRT)
				BB_Save_Define(HAVE_CLOCK_GETTIME)
				set(CLOCK_LIBS "-lrt")
			else()
				BB_Save_Undef(HAVE_CLOCK_GETTIME)
			endif()
		else()
			BB_Save_Undef(HAVE_CLOCK_GETTIME)
		endif()
	endif()

	BB_Save_MakeVar(CLOCK_CFLAGS "\${CLOCK_CFLAGS}")
	BB_Save_MakeVar(CLOCK_LIBS "\${CLOCK_LIBS}")

	set(CMAKE_REQUIRED_LIBRARIES \${ORIG_CMAKE_REQUIRED_LIBRARIES})
endmacro()

macro(Disable_Clock_gettime)
	BB_Save_Undef(HAVE_CLOCK_GETTIME)
endmacro()
EOF
}

sub DISABLE_clock_gettime
{
	MkDefine('HAVE_CLOCK_GETTIME', 'no') unless $TestFailed;
	MkDefine('CLOCK_CFLAGS', '');
	MkDefine('CLOCK_LIBS', '');
	MkSaveUndef('HAVE_CLOCK_GETTIME');
}

BEGIN
{
	my $n = 'clock_gettime';

	$DESCR{$n}   = 'clock_gettime() interface (w/o -lrt)';
	$TESTS{$n}   = \&TEST_clock_gettime;
	$CMAKE{$n}   = \&CMAKE_clock_gettime;
	$DISABLE{$n} = \&DISABLE_clock_gettime;
	$DEPS{$n}    = 'cc';
	$SAVED{$n}   = 'CLOCK_CFLAGS CLOCK_LIBS';
}
;1
