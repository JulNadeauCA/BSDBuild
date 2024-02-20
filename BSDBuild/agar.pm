# Public domain

my $testCode = << 'EOF';
#include <agar/core.h>
#include <agar/gui.h>

int
main(int argc, char *argv[])
{
	AG_InitCore("conf-test", 0);
	AG_InitGraphics(AG_NULL);
#ifdef AG_EVENT_LOOP
	AG_EventLoop();
#endif
	AG_Quit();
	return (0);
}
EOF

sub TEST_agar
{
	my ($ver, $pfx) = @_;
	
	MkExecOutputPfx($pfx, 'agar-config', '--version', 'AGAR_VERSION');
	MkIfFound($pfx, $ver, 'AGAR_VERSION');
		MkPrintSN('checking whether Agar works...');
		MkExecOutputPfx($pfx, 'agar-config', '--cflags', 'AGAR_CFLAGS');
		MkExecOutputPfx($pfx, 'agar-config', '--libs', 'AGAR_LIBS');
		MkCompileC('HAVE_AGAR',
		           '${AGAR_CFLAGS}', '${AGAR_LIBS}', $testCode);
		MkIfFalse('${HAVE_AGAR}');
			MkDisableFailed('agar');
		MkEndif;
	MkElse;
		MkDisableNotFound('agar');
	MkEndif;
}

sub CMAKE_agar
{
        return << 'EOF';
macro(Check_Agar)
	set(AGAR_CFLAGS "")
	set(AGAR_LIBS "")
	set(AGAR_CORE_CFLAGS "")
	set(AGAR_CORE_LIBS "")
	set(AGAR_GUI_CFLAGS "")
	set(AGAR_GUI_LIBS "")
	set(AGAR_AU_CFLAGS "")
	set(AGAR_AU_LIBS "")
	set(AGAR_MAP_CFLAGS "")
	set(AGAR_MAP_LIBS "")
	set(AGAR_MATH_CFLAGS "")
	set(AGAR_MATH_LIBS "")

	find_package(agar)
	if(agar_FOUND)
		set(HAVE_AGAR ON)
		foreach(agarincdir ${AGAR_INCLUDE_DIRS})
			list(APPEND AGAR_CFLAGS "-I${agarincdir}")
			list(APPEND AGAR_CORE_CFLAGS "-I${agarincdir}")
		endforeach()
		foreach(agarlib ${AGAR_CORE_LIBRARIES})
			list(APPEND AGAR_CORE_LIBS "${agarlib}")
		endforeach()
		foreach(agarlib ${AGAR_GUI_LIBRARIES} ${AGAR_CORE_LIBRARIES})
			list(APPEND AGAR_LIBS "${agarlib}")
		endforeach()
		list(REMOVE_DUPLICATES AGAR_CFLAGS)
		list(REMOVE_DUPLICATES AGAR_LIBS)
		list(REMOVE_DUPLICATES AGAR_CORE_CFLAGS)
		list(REMOVE_DUPLICATES AGAR_CORE_LIBS)
		list(REMOVE_DUPLICATES AGAR_INCLUDE_DIRS)
		BB_Save_Define(HAVE_AGAR)
	else()
		set(HAVE_AGAR OFF)
		BB_Save_Undef(HAVE_AGAR)
	endif()

	if(HAVE_AGAR_GUI)
		BB_Save_Define(HAVE_AGAR_GUI)
		set(AGAR_GUI_CFLAGS ${AGAR_CFLAGS})
		foreach(agarlib ${AGAR_GUI_LIBRARIES})
			list(APPEND AGAR_GUI_LIBS "${agarlib}")
		endforeach()
	else()
		BB_Save_Undef(HAVE_AGAR_GUI)
	endif()
	if(HAVE_AGAR_AU)
		BB_Save_Define(HAVE_AGAR_AU)
		set(AGAR_AU_CFLAGS ${AGAR_CFLAGS})
		foreach(agarlib ${AGAR_AU_LIBRARIES})
			list(APPEND AGAR_AU_LIBS "${agarlib}")
		endforeach()
	else()
		BB_Save_Undef(HAVE_AGAR_AU)
	endif()
	if(HAVE_AGAR_MAP)
		BB_Save_Define(HAVE_AGAR_MAP)
		set(AGAR_MAP_CFLAGS ${AGAR_CFLAGS})
		foreach(agarlib ${AGAR_MAP_LIBRARIES})
			list(APPEND AGAR_MAP_LIBS "${agarlib}")
		endforeach()
	else()
		BB_Save_Undef(HAVE_AGAR_MAP)
	endif()
	if(HAVE_AGAR_MATH)
		BB_Save_Define(HAVE_AGAR_MATH)
		set(AGAR_MATH_CFLAGS ${AGAR_CFLAGS})
		foreach(agarlib ${AGAR_MATH_LIBRARIES})
			list(APPEND AGAR_MATH_LIBS "${agarlib}")
		endforeach()
	else()
		BB_Save_Undef(HAVE_AGAR_MATH)
	endif()

	BB_Save_MakeVar(AGAR_CFLAGS "${AGAR_CFLAGS}")
	BB_Save_MakeVar(AGAR_LIBS "${AGAR_LIBS}")
	BB_Save_MakeVar(AGAR_CORE_CFLAGS "${AGAR_CORE_CFLAGS}")
	BB_Save_MakeVar(AGAR_CORE_LIBS "${AGAR_CORE_LIBS}")
	BB_Save_MakeVar(AGAR_GUI_CFLAGS "${AGAR_GUI_CFLAGS}")
	BB_Save_MakeVar(AGAR_GUI_LIBS "${AGAR_GUI_LIBS}")
	BB_Save_MakeVar(AGAR_AU_CFLAGS "${AGAR_AU_CFLAGS}")
	BB_Save_MakeVar(AGAR_AU_LIBS "${AGAR_AU_LIBS}")
	BB_Save_MakeVar(AGAR_MAP_CFLAGS "${AGAR_MAP_CFLAGS}")
	BB_Save_MakeVar(AGAR_MAP_LIBS "${AGAR_MAP_LIBS}")
	BB_Save_MakeVar(AGAR_MATH_CFLAGS "${AGAR_MATH_CFLAGS}")
	BB_Save_MakeVar(AGAR_MATH_LIBS "${AGAR_MATH_LIBS}")
endmacro()

macro(Disable_Agar)
	set(HAVE_AGAR OFF)
	BB_Save_Undef(HAVE_AGAR)
	BB_Save_MakeVar(AGAR_CFLAGS "")
	BB_Save_MakeVar(AGAR_LIBS "")
endmacro()
EOF
}

sub DISABLE_agar
{
	MkDefine('HAVE_AGAR', 'no') unless $TestFailed;
	MkDefine('AGAR_CFLAGS', '');
	MkDefine('AGAR_LIBS', '');
	MkSaveUndef('HAVE_AGAR');
}

sub EMUL_agar
{
	my ($os, $osrel, $machine) = @_;

	if ($os =~ /^windows/) {
		MkEmulWindows('AGAR', 'ag_core ag_gui');
	} else {
		MkEmulUnavail('AGAR');
	}
	return (1);
}

BEGIN
{
	my $n = 'agar';

	$DESCR{$n}   = 'Agar';
	$URL{$n}     = 'https://libagar.org';
	$TESTS{$n}   = \&TEST_agar;
	$CMAKE{$n}   = \&CMAKE_agar;
	$DISABLE{$n} = \&DISABLE_agar;
	$EMUL{$n}    = \&EMUL_agar;
	$DEPS{$n}    = 'cc';
	$SAVED{$n}   = 'AGAR_CFLAGS AGAR_LIBS';

	@{$EMULDEPS{$n}} = qw(clock_win32 sdl opengl wgl freetype jpeg png
	                      winsock db4 mysql pthreads iconv gettext
	                      sndfile portaudio);
}
;1
