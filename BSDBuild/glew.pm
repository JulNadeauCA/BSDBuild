# Public domain

my $testCode = << 'EOF';
#include <GL/glew.h>

int main(int argc, char *argv[])
{
	return (glewInit() != GLEW_OK);
}
EOF

sub TEST_glew
{
	my ($ver, $pfx) = @_;

	MkExecPkgConfig($pfx, 'glew', '--modversion', 'GLEW_VERSION');
	MkExecPkgConfig($pfx, 'glew', '--cflags', 'GLEW_CFLAGS');
	MkExecPkgConfig($pfx, 'glew', '--libs', 'GLEW_LIBS');

	MkIfFound($pfx, $ver, 'GLEW_VERSION');
		MkPrintSN('checking whether GLEW works...');
		MkCompileC('HAVE_GLEW', '${GLEW_CFLAGS}', '${GLEW_LIBS}', $testCode);
		MkIfFalse('${HAVE_GLEW}');
			MkDisableFailed('glew');
		MkEndif;
	MkElse;
		MkDisableNotFound('glew');
	MkEndif;
	
	MkIfTrue('${HAVE_GLEW}');
		MkDefine('GLEW_PC', 'glew');
	MkEndif;
}

sub CMAKE_glew
{
        return << 'EOF';
macro(Check_Glew)
	set(GLEW_CFLAGS "")
	set(GLEW_LIBS "")

	find_package(glew)
	if(GLEW_FOUND)
		set(HAVE_GLEW ON)
		BB_Save_Define(HAVE_GLEW)
		if(${GLEW_INCLUDE_DIRS})
			set(GLEW_CFLAGS "-I${GLEW_INCLUDE_DIRS}")
		endif()
		set(GLEW_LIBS "${GLEW_LIBRARIES}")
	else()
		set(HAVE_GLEW OFF)
		BB_Save_Undef(HAVE_GLEW)
	endif()

	BB_Save_MakeVar(GLEW_CFLAGS "${GLEW_CFLAGS}")
	BB_Save_MakeVar(GLEW_LIBS "${GLEW_LIBS}")
endmacro()

macro(Disable_Glew)
	set(HAVE_GLEW OFF)
	BB_Save_Undef(HAVE_GLEW)
	BB_Save_MakeVar(GLEW_CFLAGS "")
	BB_Save_MakeVar(GLEW_LIBS "")
endmacro()
EOF
}

sub DISABLE_glew
{
	MkDefine('HAVE_GLEW', 'no') unless $TestFailed;
	MkDefine('GLEW_CFLAGS', '');
	MkDefine('GLEW_LIBS', '');
	MkSaveUndef('HAVE_GLEW');
}

BEGIN
{
	my $n = 'glew';

	$DESCR{$n}   = 'glew';
	$URL{$n}     = 'https://www.glew.sourceforge.net/';
	$TESTS{$n}   = \&TEST_glew;
	$CMAKE{$n}   = \&CMAKE_glew;
	$DISABLE{$n} = \&DISABLE_glew;
	$DEPS{$n}    = 'cc';
	$SAVED{$n}   = 'GLEW_CFLAGS GLEW_LIBS';
}
;1
