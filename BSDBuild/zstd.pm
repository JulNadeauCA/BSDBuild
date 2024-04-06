# Public domain

my $testCode = << 'EOF';
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <zstd.h>

int main(int argc, char *argv[])
{
	ZSTD_CCtx * const cctx = ZSTD_createCCtx();
	ZSTD_freeCCtx(cctx);
	return (0);
}
EOF

sub TEST_zstd
{
	my ($ver, $pfx) = @_;

	MkExecPkgConfig($pfx, 'libzstd', '--modversion', 'ZSTD_VERSION');
	MkExecPkgConfig($pfx, 'libzstd', '--cflags', 'ZSTD_CFLAGS');
	MkExecPkgConfig($pfx, 'libzstd', '--libs', 'ZSTD_LIBS');

	MkIfFound($pfx, $ver, 'ZSTD_VERSION');
		MkPrintSN('checking whether zstd works...');
		MkCompileC('HAVE_ZSTD', '${ZSTD_CFLAGS}', '${ZSTD_LIBS}', $testCode);
		MkIfFalse('${HAVE_ZSTD}');
			MkDisableFailed('zstd');
		MkEndif;
	MkElse;
		MkDisableNotFound('zstd');
	MkEndif;
	
	MkIfTrue('${HAVE_ZSTD}');
		MkDefine('ZSTD_PC', 'zstd');
	MkEndif;
}

sub CMAKE_zstd
{
        return << 'EOF';
macro(Check_Zstd)
	set(ZSTD_CFLAGS "")
	set(ZSTD_LIBS "")

	find_package(zstd)
	if(ZSTD_FOUND)
		set(HAVE_ZSTD ON)
		BB_Save_Define(HAVE_ZSTD)
		if(${ZSTD_INCLUDE_DIRS})
			set(ZSTD_CFLAGS "-I${ZSTD_INCLUDE_DIRS}")
		endif()
		set(ZSTD_LIBS "${ZSTD_LIBRARIES}")
	else()
		set(HAVE_ZSTD OFF)
		BB_Save_Undef(HAVE_ZSTD)
	endif()

	BB_Save_MakeVar(ZSTD_CFLAGS "${ZSTD_CFLAGS}")
	BB_Save_MakeVar(ZSTD_LIBS "${ZSTD_LIBS}")
endmacro()

macro(Disable_Zstd)
	set(HAVE_ZSTD OFF)
	BB_Save_Undef(HAVE_ZSTD)
	BB_Save_MakeVar(ZSTD_CFLAGS "")
	BB_Save_MakeVar(ZSTD_LIBS "")
endmacro()
EOF
}

sub DISABLE_zstd
{
	MkDefine('HAVE_ZSTD', 'no') unless $TestFailed;
	MkDefine('ZSTD_CFLAGS', '');
	MkDefine('ZSTD_LIBS', '');
	MkSaveUndef('HAVE_ZSTD');
}

BEGIN
{
	my $n = 'zstd';

	$DESCR{$n}   = 'zstd';
	$URL{$n}     = 'https://www.zstd.net/';
	$TESTS{$n}   = \&TEST_zstd;
	$CMAKE{$n}   = \&CMAKE_zstd;
	$DISABLE{$n} = \&DISABLE_zstd;
	$DEPS{$n}    = 'cc';
	$SAVED{$n}   = 'ZSTD_CFLAGS ZSTD_LIBS';
}
;1
