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
	$DISABLE{$n} = \&DISABLE_clock_win32;
	$EMUL{$n}    = \&EMUL_clock_win32;
	$DEPS{$n}    = 'cc';
	$SAVED{$n}   = 'CLOCK_CFLAGS CLOCK_LIBS';
}
;1
