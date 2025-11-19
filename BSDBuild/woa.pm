# Public domain

my $testCode = << 'EOF';
#include <woa.h>

int
main(int argc, char *argv[])
{
	AG_InitCore("conf-test", 0);
	AG_InitGraphics(AG_NULL);
	WOA_Init();
	AG_EventLoop();
	WOA_Destroy();
	AG_Quit();
	return (0);
}
EOF

sub TEST_woa
{
	my ($ver, $pfx) = @_;
	
	MkExecOutputPfx($pfx, 'woa-config', '--version', 'WOA_VERSION');
	MkIfFound($pfx, $ver, 'WOA_VERSION');
		MkPrintSN('checking whether WoA works...');
		MkExecOutputPfx($pfx, 'woa-config', '--cflags', 'WOA_CFLAGS');
		MkExecOutputPfx($pfx, 'woa-config', '--libs', 'WOA_LIBS');
		MkCompileC('HAVE_WOA',
		           '${WOA_CFLAGS}', '${WOA_LIBS}', $testCode);
		MkIfFalse('${HAVE_WOA}');
			MkDisableFailed('woa');
		MkEndif;
	MkElse;
		MkDisableNotFound('woa');
	MkEndif;
}

sub CMAKE_woa
{
        return << 'EOF';
macro(Check_WoA)
	set(WOA_CFLAGS "")
	set(WOA_LIBS "")

	find_package(woa)
	if(woa_FOUND)
		set(HAVE_WOA ON)
		foreach(woaincdir ${WOA_INCLUDE_DIRS})
			list(APPEND WOA_CFLAGS "-I${woaincdir}")
		endforeach()
		foreach(woalib ${WOA_LIBRARIES})
			list(APPEND WOA_LIBS "${woalib}")
		endforeach()
		list(REMOVE_DUPLICATES WOA_CFLAGS)
		list(REMOVE_DUPLICATES WOA_LIBS)
		list(REMOVE_DUPLICATES WOA_INCLUDE_DIRS)
		BB_Save_Define(HAVE_WOA)
	else()
		set(HAVE_WOA OFF)
		BB_Save_Undef(HAVE_WOA)
	endif()

	BB_Save_MakeVar(WOA_CFLAGS "${WOA_CFLAGS}")
	BB_Save_MakeVar(WOA_LIBS "${WOA_LIBS}")
endmacro()

macro(Disable_WoA)
	set(HAVE_WOA OFF)
	BB_Save_Undef(HAVE_WOA)
endmacro()
EOF
}

sub DISABLE_woa
{
	MkDefine('HAVE_WOA', 'no') unless $TestFailed;
	MkDefine('WOA_CFLAGS', '');
	MkDefine('WOA_LIBS', '');
	MkSaveUndef('HAVE_WOA');
}

BEGIN
{
	my $n = 'woa';

	$DESCR{$n}   = 'WoA';
	$URL{$n}     = 'https://woa.libAgar.org';
	$TESTS{$n}   = \&TEST_woa;
	$CMAKE{$n}   = \&CMAKE_woa;
	$DISABLE{$n} = \&DISABLE_woa;
	$DEPS{$n}    = 'cc';
	$SAVED{$n}   = 'WOA_CFLAGS WOA_LIBS';
}
;1
