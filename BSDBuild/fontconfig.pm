# Public domain

my $testCode = << 'EOF';
#include <stdio.h>
#include <string.h>
#include <fontconfig/fontconfig.h>

int
main(int argc, char *argv[])
{
	FcPattern *pattern, *fpat;
	FcResult result = FcResultMatch;
	const FcChar8 name[1] = { '\0' };
	FcChar8 *file;
	FcMatrix *mat = NULL;
	double size;
	int idx;

	if (!FcInit()) { return (1); }
	if ((pattern = FcNameParse(name)) == NULL) { return (1); }
	if (!FcConfigSubstitute(NULL, pattern, FcMatchPattern)) { return (1); }
	FcDefaultSubstitute(pattern);
	if ((fpat = FcFontMatch(NULL, pattern, &result)) == NULL) { return (1); }
	if (FcPatternGetString(fpat, FC_FILE, 0, &file) != FcResultMatch) { return (1); }
	if (FcPatternGetInteger(fpat, FC_INDEX, 0, &idx) != FcResultMatch) { return (1); }
	if (FcPatternGetDouble(fpat, FC_SIZE, 0, &size) != FcResultMatch) { return (1); }
	if (FcPatternGetMatrix(fpat, FC_MATRIX, 0, &mat) != FcResultMatch) { return (1); }
	return (0);
}
EOF

sub TEST_fontconfig
{
	my ($ver, $pfx) = @_;
	
	MkExecPkgConfig($pfx, 'fontconfig', '--modversion', 'FONTCONFIG_VERSION');
	MkExecPkgConfig($pfx, 'fontconfig', '--cflags', 'FONTCONFIG_CFLAGS');
	MkExecPkgConfig($pfx, 'fontconfig', '--libs', 'FONTCONFIG_LIBS');
	MkIfFound($pfx, $ver, 'FONTCONFIG_VERSION');
		MkPrintSN('checking whether fontconfig works...');
		MkCompileC('HAVE_FONTCONFIG',
		           '${FONTCONFIG_CFLAGS}', '${FONTCONFIG_LIBS}',
		           $testCode);
		MkIfFalse('${HAVE_FONTCONFIG}');
			MkDisableFailed('fontconfig');
		MkEndif;
	MkElse;
		MkDisableNotFound('fontconfig');
	MkEndif;
}

sub CMAKE_fontconfig
{
        return << 'EOF';
macro(Check_Fontconfig)
	set(FONTCONFIG_CFLAGS "")
	set(FONTCONFIG_LIBS "")

	include(FindFontconfig)
	if(Fontconfig_FOUND)
		set(HAVE_FONTCONFIG ON)

		if(Fontconfig_COMPILE_OPTIONS)
			foreach(fontconfigopt ${Fontconfig_COMPILE_OPTIONS})
				list(APPEND FONTCONFIG_CFLAGS ${fontconfigopt})
			endforeach()
		endif()
		foreach(fontconfigincdir ${Fontconfig_INCLUDE_DIRS})
			list(APPEND FONTCONFIG_CFLAGS "-I${fontconfigincdir}")
		endforeach()
		foreach(fontconfiglib ${Fontconfig_LIBRARIES})
			list(APPEND FONTCONFIG_LIBS "${fontconfiglib}")
		endforeach()
		BB_Save_Define(HAVE_FONTCONFIG)
	else()
		set(HAVE_FONTCONFIG OFF)
		BB_Save_Undef(HAVE_FONTCONFIG)
	endif()

	BB_Save_MakeVar(FONTCONFIG_CFLAGS "${FONTCONFIG_CFLAGS}")
	BB_Save_MakeVar(FONTCONFIG_LIBS "${FONTCONFIG_LIBS}")
endmacro()

macro(Disable_Fontconfig)
	set(HAVE_FONTCONFIG OFF)
	BB_Save_Undef(HAVE_FONTCONFIG)
	BB_Save_MakeVar(FONTCONFIG_CFLAGS "")
	BB_Save_MakeVar(FONTCONFIG_LIBS "")
endmacro()
EOF
}

sub DISABLE_fontconfig
{
	MkDefine('HAVE_FONTCONFIG', 'no') unless $TestFailed;
	MkDefine('FONTCONFIG_CFLAGS', '');
	MkDefine('FONTCONFIG_LIBS', '');
	MkSaveUndef('HAVE_FONTCONFIG');
}

BEGIN
{
	my $n = 'fontconfig';

	$DESCR{$n}   = 'fontconfig';
	$URL{$n}     = 'http://fontconfig.org';
	$TESTS{$n}   = \&TEST_fontconfig;
	$CMAKE{$n}   = \&CMAKE_fontconfig;
	$DISABLE{$n} = \&DISABLE_fontconfig;
	$DEPS{$n}    = 'cc';
	$SAVED{$n}   = 'FONTCONFIG_CFLAGS FONTCONFIG_LIBS';
}
;1
