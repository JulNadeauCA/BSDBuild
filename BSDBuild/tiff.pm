# Public domain

my $testCode = << 'EOF';
#include <tiffio.h>

int main(int argc, char *argv[])
{
	TIFF *tif = TIFFOpen("foo.tiff", "r");
	TIFFClose(tif);
	return (0);
}
EOF

my $testCodeTiffXX = << 'EOF';
#include <tiffio.h>
#include <tiffio.hxx>
#include <sstream>

int main(int argc, char *argv[])
{
	std::ostringstream outputTIFF;
	TIFF *memTIFF = TIFFStreamOpen("MemTiff", &outputTIFF);
	TIFFClose(memTIFF);
	return (0);
}
EOF

sub TEST_tiff
{
	my ($ver, $pfx) = @_;

	MkExecPkgConfig($pfx, 'libtiff-4', '--modversion', 'TIFF_VERSION');
	MkExecPkgConfig($pfx, 'libtiff-4', '--cflags', 'TIFF_CFLAGS');
	MkExecPkgConfig($pfx, 'libtiff-4', '--libs', 'TIFF_LIBS');

	MkIfFound($pfx, $ver, 'TIFF_VERSION');
		MkPrintSN('checking whether libtiff works...');
		MkCompileC('HAVE_TIFF', '${TIFF_CFLAGS}', '${TIFF_LIBS}', $testCode);
		MkIfFalse('${HAVE_TIFF}');
			MkDisableFailed('tiff');
		MkEndif;

		MkPrintSN('checking whether libtiffxx works...');
		MkCompileCXX('HAVE_TIFFXX', '${TIFF_CFLAGS}', '${TIFF_LIBS} -ltiffxx', $testCodeTiffXX);
		MkIfTrue('${HAVE_TIFFXX}');
			MkDefine('TIFFXX_CFLAGS', '${TIFF_CFLAGS}');
			MkDefine('TIFFXX_LIBS', '${TIFF_LIBS} -ltiffxx');
			MkSaveDefine('HAVE_TIFFXX');
		MkElse;
			MkSaveUndef('HAVE_TIFFXX');
		MkEndif;
	MkElse;
		MkDisableNotFound('tiff');
	MkEndif;
	
	MkIfTrue('${HAVE_TIFF}');
		MkDefine('TIFF_PC', 'libtiff-4');
	MkEndif;
}

sub CMAKE_tiff
{
        return << 'EOF';
macro(Check_Tiff)
	set(TIFF_CFLAGS "")
	set(TIFF_LIBS "")

	include(FindTIFF)
	FindTIFF()
	if(TIFF_FOUND)
		set(HAVE_TIFF ON)
		BB_Save_Define(HAVE_TIFF)
		# TODO
		BB_Save_Define(HAVE_TIFFXX)
		if(${TIFF_INCLUDE_DIRS})
			set(TIFF_CFLAGS "-I${TIFF_INCLUDE_DIRS}")
		endif()
		set(TIFF_LIBS "${TIFF_LIBRARIES}")
	else()
		set(HAVE_TIFF OFF)
		BB_Save_Undef(HAVE_TIFF)
		BB_Save_Undef(HAVE_TIFFXX)
	endif()

	BB_Save_MakeVar(TIFF_CFLAGS "${TIFF_CFLAGS}")
	BB_Save_MakeVar(TIFF_LIBS "${TIFF_LIBS}")
endmacro()

macro(Disable_Tiff)
	set(HAVE_TIFF OFF)
	BB_Save_Undef(HAVE_TIFF)
	BB_Save_MakeVar(TIFF_CFLAGS "")
	BB_Save_MakeVar(TIFF_LIBS "")
endmacro()
EOF
}

sub DISABLE_tiff
{
	MkDefine('HAVE_TIFF', 'no') unless $TestFailed;
	MkDefine('HAVE_TIFFXX', 'no');
	MkDefine('TIFF_CFLAGS', '');
	MkDefine('TIFF_LIBS', '');
	MkDefine('TIFFXX_CFLAGS', '');
	MkDefine('TIFFXX_LIBS', '');
	MkSaveUndef('HAVE_TIFF', 'HAVE_TIFFXX');
}

BEGIN
{
	my $n = 'tiff';

	$DESCR{$n}   = 'tiff';
	$URL{$n}     = 'http://www.libtiff.org/';
	$TESTS{$n}   = \&TEST_tiff;
	$CMAKE{$n}   = \&CMAKE_tiff;
	$DISABLE{$n} = \&DISABLE_tiff;
	$DEPS{$n}    = 'cc,cxx';
	$SAVED{$n}   = 'TIFF_CFLAGS TIFF_LIBS TIFFXX_CFLAGS TIFFXX_LIBS';
}
;1
