# Public domain

my $testCode = << 'EOF';
#ifdef _XBOX
#include <xtl.h>
#else
#include <windows.h>
#include <mmsystem.h>
#endif

int
main(int argc, char *argv[])
{
	DWORD t0;
#ifndef _XBOX
	timeBeginPeriod(1);
#endif
	t0 = timeGetTime();
	Sleep(1);
	return (t0 != 0) ? 0 : 1;
}
EOF

sub TEST_clock_win32
{
	MkCompileC('HAVE_CLOCK_WIN32', '', '-lwinmm', $testCode);
	MkIfTrue('${HAVE_CLOCK_WIN32}');
		MkDefine('CLOCK_CFLAGS', '');
		MkDefine('CLOCK_LIBS', '-lwinmm');
		MkSaveDefine('HAVE_CLOCK_WIN32');
	MkElse;
		MkDisableFailed('clock_win32');
	MkEndif;
}

sub CMAKE_clock_win32
{
	my $code = MkCodeCMAKE($testCode);

	return << "EOF";
macro(Check_Clock_win32)
	set(ORIG_CMAKE_REQUIRED_LIBRARIES \${CMAKE_REQUIRED_LIBRARIES})

	set(CLOCK_CFLAGS "")
	set(CLOCK_LIBS "")

	set(CMAKE_REQUIRED_LIBRARIES "\${CMAKE_REQUIRED_LIBRARIES} -lwinmm")
	check_c_source_compiles("
$code" HAVE_CLOCK_WIN32)
	if(HAVE_CLOCK_WIN32)
		BB_Save_Define(HAVE_CLOCK_WIN32)
		set(CLOCK_LIBS "-lwinmm")
	else()
		BB_Save_Undef(HAVE_CLOCK_WIN32)
	endif()

	BB_Save_MakeVar(CLOCK_CFLAGS "\${CLOCK_CFLAGS}")
	BB_Save_MakeVar(CLOCK_LIBS "\${CLOCK_LIBS}")

	set(CMAKE_REQUIRED_LIBRARIES \${ORIG_CMAKE_REQUIRED_LIBRARIES})
endmacro()

macro(Disable_Clock_win32)
	BB_Save_Undef(HAVE_CLOCK_WIN32)
endmacro()
EOF
}

sub DISABLE_clock_win32
{
	MkDefine('HAVE_CLOCK_WIN32', 'no') unless $TestFailed;
	MkDefine('CLOCK_CFLAGS', '');
	MkDefine('CLOCK_LIBS', '');
	MkSaveUndef('HAVE_CLOCK_WIN32');
}

sub EMUL_clock_win32
{
	my ($os, $osrel, $machine) = @_;

	if ($os =~ /^windows/) {
		MkEmulWindows('CLOCK_WIN32', 'winmm');
		MkEmulWindows('CLOCK', 'winmm');
	} else {
		MkEmulUnavail('CLOCK_WIN32');
		MkEmulUnavail('CLOCK');
	}
	return (1);
}

BEGIN
{
	my $n = 'clock_win32';

	$DESCR{$n}   = 'winmm time interface';
	$TESTS{$n}   = \&TEST_clock_win32;
	$CMAKE{$n}   = \&CMAKE_clock_win32;
	$DISABLE{$n} = \&DISABLE_clock_win32;
	$EMUL{$n}    = \&EMUL_clock_win32;
	$DEPS{$n}    = 'cc';
	$SAVED{$n}   = 'CLOCK_CFLAGS CLOCK_LIBS';
}
;1
