# Public domain
# vim:ts=4

my $testCode = << 'EOF';
#include <agar/core.h>
#include <agar/gui.h>

int
main(int argc, char *argv[])
{
	AG_InitCore("conf-test", 0);
	AG_InitGraphics(NULL);
	AG_EventLoop();
	AG_Quit();
	return (0);
}
EOF

sub Test_Agar
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
		Disable_Agar();
	MkEndif;
	return (0);
}

sub Disable_Agar
{
	MkDefine('HAVE_AGAR', 'no');
	MkDefine('AGAR_CFLAGS', '');
	MkDefine('AGAR_LIBS', '');
	MkSaveUndef('HAVE_AGAR', 'AGAR_CFLAGS', 'AGAR_LIBS');
}

sub Emul
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

	$DESCR{$n} = 'Agar';
	$URL{$n}   = 'http://libagar.org';
	$DEPS{$n}  = 'cc';

	$TESTS{$n}   = \&Test_Agar;
	$DISABLE{$n} = \&Disable_Agar;
	$EMUL{$n}    = \&Emul;

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
