# Public domain

my $testCode = << 'EOF';
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
		MkCompileC('HAVE_JPEG', '${JPEG_CFLAGS}', '${JPEG_LIBS}', $testCode);
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

sub CMAKE_jpeg
{
        return << 'EOF';
macro(Check_Jpeg)
	set(JPEG_CFLAGS "")
	set(JPEG_LIBS "")

	include(FindJPEG)
	if(JPEG_FOUND)
		set(HAVE_JPEG ON)

		foreach(jpegincdir ${JPEG_INCLUDE_DIRS})
			list(APPEND JPEG_CFLAGS "-I${jpegincdir}")
		endforeach()
		foreach(jpeglib ${JPEG_LIBRARIES})
			list(APPEND JPEG_LIBS "${jpeglib}")
		endforeach()
		BB_Save_Define(HAVE_JPEG)
	else()
		set(HAVE_JPEG OFF)
		BB_Save_Undef(HAVE_JPEG)
	endif()

	BB_Save_MakeVar(JPEG_CFLAGS "${JPEG_CFLAGS}")
	BB_Save_MakeVar(JPEG_LIBS "${JPEG_LIBS}")
endmacro()

macro(Disable_Jpeg)
	set(HAVE_JPEG OFF)
	BB_Save_Undef(HAVE_JPEG)
	BB_Save_MakeVar(JPEG_CFLAGS "")
	BB_Save_MakeVar(JPEG_LIBS "")
endmacro()
EOF
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
	$CMAKE{$n}   = \&CMAKE_jpeg;
	$DISABLE{$n} = \&DISABLE_jpeg;
	$DEPS{$n}    = 'cc';
	$SAVED{$n}   = 'JPEG_CFLAGS JPEG_LIBS JPEG_PC';
}
;1
