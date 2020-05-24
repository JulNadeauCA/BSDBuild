# Public domain
# vim:ts=4

my $testCode = << 'EOF';
#include <agar/core.h>
#include <agar/gui.h>

int
main(int argc, char *argv[])
{
	AG_InitCore("conf-test", 0);
	AG_InitGraphics(AG_NULL);
#ifdef AG_EVENT_LOOP
	AG_EventLoop();
#endif
	AG_Quit();
	return (0);
}
EOF

sub TEST_agar
{
	my ($ver, $pfx) = @_;
	
	MkExecOutputPfx($pfx, 'agar-config', '--version', 'AGAR_VERSION');
	MkIfFound($pfx, $ver, 'AGAR_VERSION');
		MkPrintSN('checking whether Agar works...');
		MkExecOutputPfx($pfx, 'agar-config', '--cflags', 'AGAR_CFLAGS');
		MkExecOutputPfx($pfx, 'agar-config', '--libs', 'AGAR_LIBS');
		MkCompileC('HAVE_AGAR',
		           '${AGAR_CFLAGS}', '${AGAR_LIBS}',
				   $testCode);
		MkSaveIfTrue('${HAVE_AGAR}', 'AGAR_CFLAGS', 'AGAR_LIBS');
	MkElse;
		DISABLE_agar();
	MkEndif;
}

sub DISABLE_agar
{
	MkDefine('HAVE_AGAR', 'no');
	MkDefine('AGAR_CFLAGS', '');
	MkDefine('AGAR_LIBS', '');
	MkSaveUndef('HAVE_AGAR');
}

sub EMUL_agar
{
	my ($os, $osrel, $machine) = @_;

	if ($os =~ /^windows/) {
		MkEmulWindows('AGAR', 'ag_core ag_gui');
	} else {
		MkEmulUnavail('AGAR');
	}
	return (1);
}

BEGIN
{
	my $n = 'agar';

	$DESCR{$n}   = 'Agar';
	$URL{$n}     = 'http://libagar.org';

	$TESTS{$n}   = \&TEST_agar;
	$DISABLE{$n} = \&DISABLE_agar;
	$EMUL{$n}    = \&EMUL_agar;

	$DEPS{$n}    = 'cc';

	@{$EMULDEPS{$n}} = qw(
		clock_win32
		sdl
		opengl
		wgl
		freetype
		jpeg
		png
		winsock
		db4
		mysql
		pthreads
		iconv
		gettext
		sndfile
		portaudio
	);
}
;1
