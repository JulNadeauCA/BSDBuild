# Public domain

my $testCode = << 'EOF';
#include <stdio.h>
#include <string.h>
#include <zlib.h>
int main(int argc, char *argv[])
{
	z_stream strm;
	strm.zalloc = Z_NULL;
	strm.zfree = Z_NULL;
	strm.opaque = Z_NULL;
	return deflateInit(&strm, 0);
}
EOF

my @autoPrefixDirs = (
	'/usr/local',
	'/usr'
);

sub TEST_zlib
{
	my ($ver, $pfx) = @_;

	MkDefine('ZLIB_CFLAGS', '');
	MkDefine('ZLIB_LIBS', '');

	MkIfNE($pfx, '');
		MkDefine('ZLIB_CFLAGS', "-I$pfx/include");
		MkDefine('ZLIB_LIBS', "-L$pfx/lib -lz");
	MkElse;
		foreach my $dir (@autoPrefixDirs) {
			MkIf("-f \"$dir/include/zlib.h\"");
				MkDefine('ZLIB_CFLAGS', "-I$dir/include");
				MkDefine('ZLIB_LIBS', "-L$dir/lib -lz");
			MkEndif;
		}
	MkEndif;
		
	MkIfNE('${ZLIB_LIBS}', '');
		MkPrintS('ok');
		MkPrintSN('checking whether zlib works...');
		MkCompileC('HAVE_ZLIB',
		           '${ZLIB_CFLAGS}', '${ZLIB_LIBS}', $testCode);
		MkIfFalse('${HAVE_ZLIB}');
			MkDisableFailed('zlib');
		MkEndif;
	MkElse;
		MkPrintS('no');
		MkDisableNotFound('zlib');
	MkEndif;
}

sub CMAKE_zlib
{
        return << 'EOF';
macro(Check_Zlib)
	set(ZLIB_CFLAGS "")
	set(ZLIB_LIBS "")

	include(FindZLIB)
	if(ZLIB_FOUND)
		set(HAVE_ZLIB ON)
		BB_Save_Define(HAVE_ZLIB)
		if(${ZLIB_INCLUDE_DIRS})
			set(ZLIB_CFLAGS "-I${ZLIB_INCLUDE_DIRS}")
		endif()
		set(ZLIB_LIBS "${ZLIB_LIBRARIES}")
	else()
		set(HAVE_ZLIB OFF)
		BB_Save_Undef(HAVE_ZLIB)
	endif()

	BB_Save_MakeVar(ZLIB_CFLAGS "${ZLIB_CFLAGS}")
	BB_Save_MakeVar(ZLIB_LIBS "${ZLIB_LIBS}")
endmacro()

macro(Disable_Zlib)
	set(HAVE_ZLIB OFF)
	BB_Save_Undef(HAVE_ZLIB)
	BB_Save_MakeVar(ZLIB_CFLAGS "")
	BB_Save_MakeVar(ZLIB_LIBS "")
endmacro()
EOF
}

sub DISABLE_zlib
{
	MkDefine('HAVE_ZLIB', 'no') unless $TestFailed;
	MkDefine('ZLIB_CFLAGS', '');
	MkDefine('ZLIB_LIBS', '');
	MkSaveUndef('HAVE_ZLIB');
}

BEGIN
{
	my $n = 'zlib';

	$DESCR{$n}   = 'zlib';
	$TESTS{$n}   = \&TEST_zlib;
	$CMAKE{$n}   = \&CMAKE_zlib;
	$DISABLE{$n} = \&DISABLE_zlib;
	$DEPS{$n}    = 'cc';
	$SAVED{$n}   = 'ZLIB_CFLAGS ZLIB_LIBS';
}
;1
