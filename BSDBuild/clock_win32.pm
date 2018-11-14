# Public domain
# vim:ts=4

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

sub Test_Clock_Win32
{
	MkCompileC('HAVE_CLOCK_WIN32', '', '-lwinmm', $testCode);
	MkIfTrue('${HAVE_CLOCK_WIN32}');
		MkDefine('CLOCK_CFLAGS', '');
		MkDefine('CLOCK_LIBS', '-lwinmm');
		MkSaveDefine('HAVE_CLOCK_WIN32', 'CLOCK_CFLAGS', 'CLOCK_LIBS');
		MkSaveMK('CLOCK_CFLAGS', 'CLOCK_LIBS');
	MkElse;
		MkSaveUndef('HAVE_CLOCK_WIN32');
	MkEndif;
}

sub Disable_Clock_Win32
{
	MkDefine('HAVE_CLOCK_WIN32', 'no');
	MkDefine('CLOCK_CFLAGS', '');
	MkDefine('CLOCK_LIBS', '');
	MkSaveUndef('HAVE_CLOCK_WIN32', 'CLOCK_CFLAGS', 'CLOCK_LIBS');
}

sub Emul
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

	$DESCR{$n} = 'winmm time interface';
	$DEPS{$n}  = 'cc';

	$TESTS{$n}   = \&Test_Clock_Win32;
	$DISABLE{$n} = \&Disable_Clock_Win32;
	$EMUL{$n}    = \&Emul;
}

;1
