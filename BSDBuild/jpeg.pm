# Public domain

my @autoPrefixDirs = (
	'/usr/local',
	'/usr/X11R6',
	'/usr',
	'/usr/pkg',
	'/opt/local',
	'/opt'
);

sub TEST_jpeg
{
	my ($ver, $pfx) = @_;

	MkDefine('JPEG_CFLAGS', '');
	MkIfNE($pfx, '');
		MkIfExists("$pfx/include/jpeglib.h");
			MkDefine('JPEG_CFLAGS', "-I$pfx/include");
			MkDefine('JPEG_LIBS', "-L$pfx/lib -ljpeg");
		MkEndif;
	MkElse;
		foreach my $dir (@autoPrefixDirs) {
			MkIfExists("$dir/include/jpeglib.h");
				MkDefine('JPEG_CFLAGS', "-I$dir/include");
				MkDefine('JPEG_LIBS', "-L$dir/lib -ljpeg");
			MkEndif;
		}
	MkEndif;

	MkIfNE('${JPEG_LIBS}', '');
		MkPrintS('yes');
		MkPrintSN('checking whether libjpeg works...');
		MkCompileC('HAVE_JPEG', '${JPEG_CFLAGS}', '${JPEG_LIBS}', << 'EOF');
#include <stdio.h>
#include <jpeglib.h>

struct jpeg_error_mgr		jerr;
struct jpeg_compress_struct	jcomp;

int
main(int argc, char *argv[])
{
	jcomp.err = jpeg_std_error(&jerr);

	jpeg_create_compress(&jcomp);
	jcomp.image_width = 32;
	jcomp.image_height = 32;
	jcomp.input_components = 3;
	jcomp.in_color_space = JCS_RGB;

	jpeg_set_defaults(&jcomp);
	jpeg_set_quality(&jcomp, 75, TRUE);

	jpeg_destroy_compress(&jcomp);
	return (0);
}
EOF
		MkIfFalse('${HAVE_JPEG}');
			MkDisableFailed('jpeg');
		MkEndif;
	MkElse;
		MkPrintS('no');
		MkDisableNotFound('jpeg');
	MkEndif;
	
	MkIfTrue('${HAVE_JPEG}');
		MkDefine('JPEG_PC', 'libjpeg');
	MkEndif;
}

sub DISABLE_jpeg
{
	MkDefine('HAVE_JPEG', 'no') unless $TestFailed;
	MkDefine('JPEG_CFLAGS', '');
	MkDefine('JPEG_LIBS', '');
	MkSaveUndef('HAVE_JPEG');
}

BEGIN
{
	my $n = 'jpeg';

	$DESCR{$n}   = 'libjpeg';
	$URL{$n}     = 'ftp://ftp.uu.net/graphics/jpeg';
	$TESTS{$n}   = \&TEST_jpeg;
	$DISABLE{$n} = \&DISABLE_jpeg;
	$DEPS{$n}    = 'cc';
	$SAVED{$n}   = 'JPEG_CFLAGS JPEG_LIBS JPEG_PC';
}
;1
