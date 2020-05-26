# Public domain

sub TEST_sdl_ttf
{
	my ($ver, $pfx) = @_;
	
	MkExecPkgConfig($pfx, 'SDL_ttf', '--modversion', 'SDL_TTF_VERSION');
	MkExecPkgConfig($pfx, 'SDL_ttf', '--cflags', 'SDL_TTF_CFLAGS');
	MkExecPkgConfig($pfx, 'SDL_ttf', '--libs', 'SDL_TTF_LIBS');
	MkIfNE('${SDL_TTF_VERSION}', '');
		MkCompileC('HAVE_SDL_TTF',
		           '${SDL_TTF_CFLAGS}', '${SDL_TTF_LIBS}', << 'EOF');
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <SDL.h>
#include <SDL_ttf.h>
int
main(int argc, char *argv[])
{
	TTF_Font *fn;

	SDL_Init(0);
	fn = TTF_OpenFont(NULL, 10);
	SDL_Quit();
	return (fn == NULL);
}
EOF
		MkIfFalse('${HAVE_SDL_TTF}');
			MkDisableFailed('sdl_ttf');
		MkEndif;
	MkElse;
		MkPrintS('no');
		MkDisableNotFound('sdl_ttf');
	MkEndif;
}

sub DISABLE_sdl_ttf
{
	MkDefine('HAVE_SDL_TTF', 'no') unless $TestFailed;
	MkDefine('SDL_TTF_CFLAGS', '');
	MkDefine('SDL_TTF_LIBS', '');
	MkSaveUndef('HAVE_SDL_TTF');
}

BEGIN
{
	my $n = 'sdl_ttf';

	$DESCR{$n}   = 'SDL_ttf';
	$URL{$n}     = 'http://libsdl.org/projects/SDL_ttf';
	$TESTS{$n}   = \&TEST_sdl_ttf;
	$DISABLE{$n} = \&DISABLE_sdl_ttf;
	$DEPS{$n}    = 'cc,sdl';
	$SAVED{$n}   = 'SDL_TTF_CFLAGS SDL_TTF_LIBS';
}
;1
