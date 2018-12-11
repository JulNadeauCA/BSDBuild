# vim:ts=4
# Public domain

use BSDBuild::Core;

my $testCode = << 'EOF';
#ifdef _USE_SDL_FRAMEWORK
# include <SDL/SDL.h>
# ifdef main
#  undef main
# endif
#else
# include <SDL.h>
#endif
int main(int argc, char *argv[]) {
	SDL_Surface *su;

	if (SDL_Init(SDL_INIT_TIMER|SDL_INIT_NOPARACHUTE) != 0) {
		return (1);
	}
	su = SDL_CreateRGBSurface(0, 16, 16, 32, 0, 0, 0, 0);
	SDL_FreeSurface(su);
	SDL_Quit();
	return (0);
}
EOF

sub TEST_sdl
{
	my ($ver, $pfx) = @_;

	MkIfNE($pfx, '');
		MkExecOutputPfx($pfx, 'sdl-config', '--prefix', 'SDL_PREFIX');
		MkExecOutputPfx($pfx, 'sdl-config', '--version', 'SDL_VERSION');
		MkExecOutputPfx($pfx, 'sdl-config', '--cflags', 'SDL_CFLAGS');
		MkExecOutputPfx($pfx, 'sdl-config', '--libs', 'SDL_LIBS');
	MkElse;
		MkCaseIn('${host}');
		MkCaseBegin('*-*-darwin*');
			MkExecOutput('sdl-config', '--version', 'SDL_VERSION');
			MkIfNE('${SDL_VERSION}', '');
				MkExecOutput('sdl-config', '--prefix', 'SDL_PREFIX');
				MkExecOutput('sdl-config', '--cflags', 'SDL_CFLAGS');
				MkExecOutput('sdl-config', '--libs', 'SDL_LIBS');
			MkElse;
				MkPrintSN('framework...');
				MkDefine('SDL_VERSION', '1.2.15');
				MkDefine('SDL_CFLAGS', '-D_USE_SDL_FRAMEWORK');
				MkDefine('SDL_LIBS', '-framework SDL');
			MkEndif;
			MkCaseEnd;
		MkCaseBegin('*-*-freebsd*');
			MkExecOutput('sdl11-config', '--version', 'SDL_VERSION');
			MkIfNE('${SDL_VERSION}', '');
				MkExecOutput('sdl11-config', '--prefix', 'SDL_PREFIX');
				MkExecOutput('sdl11-config', '--cflags', 'SDL_CFLAGS');
				MkExecOutput('sdl11-config', '--libs', 'SDL_LIBS');
			MkElse;
				MkExecOutput('sdl-config', '--prefix', 'SDL_PREFIX');
				MkExecOutput('sdl-config', '--version', 'SDL_VERSION');
				MkExecOutput('sdl-config', '--cflags', 'SDL_CFLAGS');
				MkExecOutput('sdl-config', '--libs', 'SDL_LIBS');
			MkEndif;
			MkCaseEnd;
		MkCaseBegin('*');
			MkExecOutput('sdl-config', '--prefix', 'SDL_PREFIX');
			MkExecOutput('sdl-config', '--version', 'SDL_VERSION');
			MkExecOutput('sdl-config', '--cflags', 'SDL_CFLAGS');
			MkExecOutput('sdl-config', '--libs', 'SDL_LIBS');
			MkCaseEnd;
		MkEsac;
	MkEndif;
		
	MkIfFound($pfx, $ver, 'SDL_VERSION');
		MkPrintSN('checking whether SDL works...');
		MkCompileC('HAVE_SDL', '${SDL_CFLAGS}', '${SDL_LIBS}', $testCode);
		MkIfTrue('${HAVE_SDL}');
			MkCaseIn('${host}');
			MkCaseBegin('*-*-cygwin* | *-*-mingw32*');
				#
				# On Cygwin/MinGW, linking against -lSDL.dll is preferable 
				# to the output of `sdl-config`; use it if available.
				#
				MkIfExists('${SDL_PREFIX}/include/SDL');
					MkDefine('SDL_CFLAGS', '-I${SDL_PREFIX}/include/SDL -D_GNU_SOURCE=1');
				MkEndif;
				MkIfExists('${SDL_PREFIX}/lib/libSDL.dll.a');
					MkDefine('SDL_LIBS', '-L${SDL_PREFIX}/lib -lSDL.dll');
				MkEndif;
				MkCaseEnd;
			MkEsac;
			MkSave('SDL_CFLAGS', 'SDL_LIBS');
		MkElse;
			MkPrintSN('checking whether SDL works (with X11 libs)...');
			MkAppend('SDL_LIBS', '-L/usr/X11R6/lib -lX11 -lXext -lXrandr '.
			                     '-lXrender');
			MkCompileC('HAVE_SDL', '${SDL_CFLAGS}', '${SDL_LIBS}', $testCode);
			MkSaveIfTrue('${HAVE_SDL}', 'SDL_CFLAGS', 'SDL_LIBS');
		MkEndif;
	MkElse;
		DISABLE_sdl();
	MkEndif;

	MkIfTrue('${HAVE_SDL}');
		MkDefine('SDL_PC', 'sdl');
	MkElse;
		MkDefine('SDL_PC', '');
	MkEndif;
}

sub DISABLE_sdl
{
	MkDefine('HAVE_SDL', 'no');
	MkDefine('SDL_CFLAGS', '');
	MkDefine('SDL_LIBS', '');
	MkDefine('SDL_PC', '');
	MkSaveUndef('HAVE_SDL', 'SDL_CFLAGS', 'SDL_LIBS');
}

sub EMUL_sdl
{
	my ($os, $osrel, $machine) = @_;

	if ($os =~ /^windows/) {
		MkEmulWindows('SDL', 'SDL');
	} else {
		MkEmulUnavail('SDL');
	}
	return (1);
}

BEGIN
{
	my $n = 'sdl';

	$DESCR{$n}   = 'SDL 1.2';
	$URL{$n}     = 'http://www.libsdl.org';
	$TESTS{$n}   = \&TEST_sdl;
	$DISABLE{$n} = \&DISABLE_sdl;
	$EMUL{$n}    = \&EMUL_sdl;
	$DEPS{$n}    = 'cc';
}
;1
