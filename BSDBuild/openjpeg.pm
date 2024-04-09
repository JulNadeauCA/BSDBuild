# Public domain

my $testCode = << 'EOF';
#include <openjpeg.h>

int main(int argc, char *argv[])
{
	const char *opjVer = opj_version();
	return (opj_has_thread_support() != OPJ_TRUE) ? 0 : 1;
}
EOF

sub TEST_openjpeg
{
	my ($ver, $pfx) = @_;

	MkExecPkgConfig($pfx, 'libopenjp2', '--modversion', 'OPENJPEG_VERSION');
	MkExecPkgConfig($pfx, 'libopenjp2', '--cflags', 'OPENJPEG_CFLAGS');
	MkExecPkgConfig($pfx, 'libopenjp2', '--libs', 'OPENJPEG_LIBS');

	MkIfFound($pfx, $ver, 'OPENJPEG_VERSION');
		MkPrintSN('checking whether openjpeg works...');
		MkCompileC('HAVE_OPENJPEG', '${OPENJPEG_CFLAGS}', '${OPENJPEG_LIBS}', $testCode);
		MkIfFalse('${HAVE_OPENJPEG}');
			MkDisableFailed('openjpeg');
		MkEndif;
	MkElse;
		MkDisableNotFound('openjpeg');
	MkEndif;
	
	MkIfTrue('${HAVE_OPENJPEG}');
		MkDefine('OPENJPEG_PC', 'openjpeg');
	MkEndif;
}

sub CMAKE_openjpeg
{
        return << 'EOF';
macro(Check_Zstd)
	set(OPENJPEG_CFLAGS "")
	set(OPENJPEG_LIBS "")

	find_package(openjpeg)
	if(OPENJPEG_FOUND)
		set(HAVE_OPENJPEG ON)
		BB_Save_Define(HAVE_OPENJPEG)
		if(${OPENJPEG_INCLUDE_DIRS})
			set(OPENJPEG_CFLAGS "-I${OPENJPEG_INCLUDE_DIRS}")
		endif()
		set(OPENJPEG_LIBS "${OPENJPEG_LIBRARIES}")
	else()
		set(HAVE_OPENJPEG OFF)
		BB_Save_Undef(HAVE_OPENJPEG)
	endif()

	BB_Save_MakeVar(OPENJPEG_CFLAGS "${OPENJPEG_CFLAGS}")
	BB_Save_MakeVar(OPENJPEG_LIBS "${OPENJPEG_LIBS}")
endmacro()

macro(Disable_Zstd)
	set(HAVE_OPENJPEG OFF)
	BB_Save_Undef(HAVE_OPENJPEG)
	BB_Save_MakeVar(OPENJPEG_CFLAGS "")
	BB_Save_MakeVar(OPENJPEG_LIBS "")
endmacro()
EOF
}

sub DISABLE_openjpeg
{
	MkDefine('HAVE_OPENJPEG', 'no') unless $TestFailed;
	MkDefine('OPENJPEG_CFLAGS', '');
	MkDefine('OPENJPEG_LIBS', '');
	MkSaveUndef('HAVE_OPENJPEG');
}

BEGIN
{
	my $n = 'openjpeg';

	$DESCR{$n}   = 'openjpeg';
	$URL{$n}     = 'https://www.openjpeg.org/';
	$TESTS{$n}   = \&TEST_openjpeg;
	$CMAKE{$n}   = \&CMAKE_openjpeg;
	$DISABLE{$n} = \&DISABLE_openjpeg;
	$DEPS{$n}    = 'cc';
	$SAVED{$n}   = 'OPENJPEG_CFLAGS OPENJPEG_LIBS';
}
;1
