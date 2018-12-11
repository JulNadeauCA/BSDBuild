# vim:ts=4
# Public domain

my $testCode = << 'EOF';
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <wand/MagickWand.h>

int
main(int argc, char *argv[])
{
	MagickWandGenesis();
	MagickWandTerminus();
	return (0);
}
EOF

sub TEST_imagemagick
{
	my ($ver, $pfx) = @_;
	
	MkExecOutputPfx($pfx, 'MagickWand-config', '--version', 'IMAGEMAGICK_VERSION');
	MkIfFound($pfx, $ver, 'IMAGEMAGICK_VERSION');
		MkPrintSN('checking whether ImageMagick works...');
		MkExecOutputPfx($pfx, 'MagickWand-config', '--cflags', 'IMAGEMAGICK_CFLAGS');
		MkExecOutputPfx($pfx, 'MagickWand-config', '--libs', 'IMAGEMAGICK_LIBS');
		MkCompileC('HAVE_IMAGEMAGICK',
		           '${IMAGEMAGICK_CFLAGS}', '${IMAGEMAGICK_LIBS}',
				   $testCode);
		MkSaveIfTrue('${HAVE_IMAGEMAGICK}', 'IMAGEMAGICK_CFLAGS', 'IMAGEMAGICK_LIBS');
	MkElse;
		MkSaveUndef('IMAGEMAGICK_CFLAGS', 'IMAGEMAGICK_LIBS');
	MkEndif;
}

sub DISABLE_imagemagick
{
	MkDefine('HAVE_IMAGEMAGICK', 'no');
	MkSaveUndef('HAVE_IMAGEMAGICK', 'IMAGEMAGICK_CFLAGS', 'IMAGEMAGICK_LIBS');
}

sub EMUL_imagemagick
{
	my ($os, $osrel, $machine) = @_;

	if ($os =~ /^windows/) {
		MkEmulWindows('IMAGEMAGICK', 'MagickCore-6 MagickWand-6');
	} else {
		MkEmulUnavail('IMAGEMAGICK');
	}
	return (1);
}

BEGIN
{
	my $n = 'imagemagick';

	$DESCR{$n}   = 'ImageMagick';
	$URL{$n}     = 'http://www.ImageMagick.org';
	$TESTS{$n}   = \&TEST_imagemagick;
	$DISABLE{$n} = \&DISABLE_imagemagick;
	$EMUL{$n}    = \&EMUL_imagemagick;
	$DEPS{$n}    = 'cc';
}
;1
