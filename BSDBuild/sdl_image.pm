# Public domain

sub TEST_sdl_image
{
	my ($ver, $pfx) = @_;
	
	MkExecPkgConfig($pfx, 'SDL_image', '--modversion', 'SDL_IMAGE_VERSION');
	MkExecPkgConfig($pfx, 'SDL_image', '--cflags', 'SDL_IMAGE_CFLAGS');
	MkExecPkgConfig($pfx, 'SDL_image', '--libs', 'SDL_IMAGE_LIBS');
	MkIfNE('${SDL_IMAGE_VERSION}', '');
		MkCompileC('HAVE_SDL_IMAGE',
		           '${SDL_IMAGE_CFLAGS}', '${SDL_IMAGE_LIBS}', << 'EOF');
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <SDL.h>
#include <SDL_image.h>
int
main(int argc, char *argv[])
{
	SDL_Surface *image;
	SDL_Init(0);
	image = IMG_Load(NULL);
	SDL_Quit();
	return (0);
}
EOF
		MkIfFalse('${HAVE_SDL_IMAGE}');
			MkDisableFailed('sdl_image');
		MkEndif;
	MkElse;
		MkPrintS('no');
		MkDisableNotFound('sdl_image');
	MkEndif;
}

sub DISABLE_sdl_image
{
	MkDefine('HAVE_SDL_IMAGE', 'no') unless $TestFailed;
	MkDefine('SDL_IMAGE_CFLAGS', '');
	MkDefine('SDL_IMAGE_LIBS', '');
	MkSaveUndef('HAVE_SDL_IMAGE');
}

BEGIN
{
	my $n = 'sdl_image';

	$DESCR{$n}   = 'SDL_image';
	$URL{$n}     = 'http://libsdl.org/projects/SDL_image';
	$TESTS{$n}   = \&TEST_sdl_image;
	$DISABLE{$n} = \&DISABLE_sdl_image;
	$DEPS{$n}    = 'cc,sdl';
	$SAVED{$n}   = 'SDL_IMAGE_CFLAGS SDL_IMAGE_LIBS';
}
;1
