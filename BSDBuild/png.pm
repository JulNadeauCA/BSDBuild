# Public domain

use BSDBuild::Core;

my $testCode = << 'EOF';
#include <stdio.h>
#include <png.h>

int main(int argc, char *argv[])
{
	char foo[4];

	if (png_sig_cmp((png_bytep)foo, 0, 3)) {
		return (1);
	}
	return (0);
}
EOF

sub TEST_png
{
	my ($ver, $pfx) = @_;
	
	MkExecOutputPfx($pfx, 'libpng-config', '--version', 'PNG_VERSION');
	MkExecOutputPfx($pfx, 'libpng-config', '--cflags', 'PNG_CFLAGS');
	MkExecOutputPfx($pfx, 'libpng-config', '--L_opts', 'PNG_LOPTS');
	MkExecOutputPfx($pfx, 'libpng-config', '--static --libs', 'PNG_LIBS');
	MkDefine('PNG_LIBS', '${PNG_LOPTS} ${PNG_LIBS}');
	MkIfFound($pfx, $ver, 'PNG_VERSION');
		MkPrintSN('checking whether libpng works...');
		MkCompileC('HAVE_PNG', '${PNG_CFLAGS}', '${PNG_LIBS}', $testCode);
		MkIfFalse('${HAVE_PNG}');
			MkDisableFailed('png');
		MkElse;
			MkTestVersion('PNG_VERSION', '1.4.0');
			MkIfEQ('${MK_VERSION_OK}', 'yes');
				MkDefine('HAVE_LIBPNG14', 'yes');
				MkSaveDefine('HAVE_LIBPNG14');
			MkElse;
				MkDefine('HAVE_LIBPNG14', 'no');
				MkSaveUndef('HAVE_LIBPNG14');
			MkEndif;
		MkEndif;
	MkElse;
		MkDisableNotFound('png');
	MkEndif;

	MkIfTrue('${HAVE_PNG}');
		MkDefine('PNG_PC', 'libpng');
	MkEndif;
}

sub CMAKE_png
{
        return << 'EOF';
macro(Check_Png)
	set(PNG_CFLAGS "")
	set(PNG_LIBS "")

	include(FindPNG)
	if(PNG_FOUND)
		set(HAVE_PNG ON)

		foreach(pngdef ${PNG_DEFINITIONS})
			list(APPEND PNG_CFLAGS "-D${pngdef}")
		endforeach()
		foreach(pngincdir ${PNG_INCLUDE_DIRS})
			list(APPEND PNG_CFLAGS "-I${pngincdir}")
		endforeach()
		foreach(pnglib ${PNG_LIBRARIES})
			list(APPEND PNG_LIBS "${pnglib}")
		endforeach()

		BB_Save_Define(HAVE_PNG)

		if(${PNG_VERSION_STRING} VERSION_GREATER_EQUAL "1.4.0")
			set(HAVE_LIBPNG14 ON)
			BB_Save_Define(HAVE_LIBPNG14)
		else()
			set(HAVE_LIBPNG14 OFF)
			BB_Save_Undef(HAVE_LIBPNG14)
		endif()
	else()
		set(HAVE_PNG OFF)
		set(HAVE_LIBPNG14 OFF)
		BB_Save_Undef(HAVE_PNG)
		BB_Save_Undef(HAVE_LIBPNG14)
	endif()

	BB_Save_MakeVar(PNG_CFLAGS "${PNG_CFLAGS}")
	BB_Save_MakeVar(PNG_LIBS "${PNG_LIBS}")
endmacro()

macro(Disable_Png)
	set(HAVE_PNG OFF)
	set(HAVE_LIBPNG14 OFF)
	BB_Save_Undef(HAVE_PNG)
	BB_Save_Undef(HAVE_LIBPNG14)
	BB_Save_MakeVar(PNG_CFLAGS "")
	BB_Save_MakeVar(PNG_LIBS "")
endmacro()
EOF
}

sub DISABLE_png
{
	MkDefine('HAVE_PNG', 'no') unless $TestFailed;
	MkDefine('HAVE_LIBPNG14', 'no');
	MkDefine('PNG_CFLAGS', '');
	MkDefine('PNG_LIBS', '');
	MkSaveUndef('HAVE_PNG', 'HAVE_LIBPNG14');
}

BEGIN
{
	my $n = 'png';

	$DESCR{$n}   = 'libpng';
	$URL{$n}     = 'http://www.libpng.org';
	$TESTS{$n}   = \&TEST_png;
	$CMAKE{$n}   = \&CMAKE_png;
	$DISABLE{$n} = \&DISABLE_png;
	$DEPS{$n}    = 'cc';
	$SAVED{$n}   = 'PNG_CFLAGS PNG_LIBS PNG_PC';
}
;1
