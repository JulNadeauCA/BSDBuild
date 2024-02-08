# Public domain

my $testCode = << 'EOF';
#include <X11/Xlib.h>
int main(int argc, char *argv[])
{
	Display *disp = XOpenDisplay(NULL);
	XCloseDisplay(disp);
	return (0);
}
EOF

my $testCodeXKB = << 'EOF';
#include <X11/Xlib.h>
#include <X11/XKBlib.h>
int main(int argc, char *argv[])
{
	Display *disp = XOpenDisplay(NULL);
	KeyCode kc = 0;
	KeySym ks = XkbKeycodeToKeysym(disp, kc, 0, 0);
	XCloseDisplay(disp);
	return (ks != NoSymbol);
}
EOF

my $testCodeXF86Misc = << 'EOF';
#include <X11/Xlib.h>
#include <X11/extensions/xf86misc.h>
int main(int argc, char *argv[])
{
	Display *disp = XOpenDisplay(NULL);
	int dummy, rv;
	rv = XF86MiscQueryExtension(disp, &dummy, &dummy);
	XCloseDisplay(disp);
	return (rv != 0);
}
EOF

# Match autoconf / libs.m4 / _AC_PATH_X_DIRECT
my @autoIncludeDirs = (
	'/usr/local/include',
	'/usr/include',
	'/usr/include/X11',
	'/usr/include/X11R7',
	'/usr/include/X11R6',
	'/usr/include/X11R5',
	'/usr/include/X11R4',
	'/usr/local/X11/include',
	'/usr/local/X11R7/include',
	'/usr/local/X11R6/include',
	'/usr/local/X11R5/include',
	'/usr/local/X11R4/include',
	'/usr/local/include/X11',
	'/usr/local/include/X11R7',
	'/usr/local/include/X11R6',
	'/usr/local/include/X11R5',
	'/usr/local/include/X11R4',
	'/usr/X11/include',
	'/usr/X11R7/include',
	'/usr/X11R6/include',
	'/usr/X11R5/include',
	'/usr/X11R4/include',
	'/opt/X11/include',
);

my @autoLibDirs = (
	'/usr/local/lib',
	'/usr/lib',
	'/usr/local/X11/lib',
	'/usr/local/X11R7/lib',
	'/usr/local/X11R6/lib',
	'/usr/local/X11R5/lib',
	'/usr/local/X11R4/lib',
	'/usr/X11/lib',
	'/usr/X11R7/lib',
	'/usr/X11R6/lib',
	'/usr/X11R5/lib',
	'/usr/X11R4/lib',
	'/opt/X11/lib'
);

sub TEST_x11
{
	my ($ver, $pfx) = @_;
	
	MkIfPkgConfig('x11');
		MkExecPkgConfig($pfx, 'x11', '--modversion', 'X11_VERSION');
		MkExecPkgConfig($pfx, 'x11', '--cflags', 'X11_CFLAGS');
		MkExecPkgConfig($pfx, 'x11', '--libs', 'X11_LIBS');
	MkElse;
		MkDefine('X11_CFLAGS', '');
		MkDefine('X11_LIBS', '');
		MkIfNE($pfx, '');
			MkIfExists("$pfx/include/X11");
				MkDefine('X11_CFLAGS', "-I$pfx/include");
			MkEndif;
			MkIfExists("$pfx/lib");
				MkDefine('X11_LIBS', "-L$pfx/lib -lX11");
			MkEndif;
		MkElse;
			MkIfNE('${with_x_libraries}', '');
				MkIfExists('${with_x_includes}/X11');
					MkDefine('X11_CFLAGS',
					         '-I${with_x_includes}/X11');
				MkElse;
					MkDefine('X11_CFLAGS',
					         '-I${with_x_includes}');
				MkEndif;
				MkDefine('X11_LIBS', '-L${with_x_libraries} -lX11');
			MkElse;
				foreach my $dir (@autoIncludeDirs) {
					MkIfExists("$dir/X11");
						MkDefine('X11_CFLAGS', "-I$dir");
						MkBreak;
					MkEndif;
				}
				foreach my $dir (@autoLibDirs) {
					MkIfExists("$dir/libX11.so");
						MkDefine('X11_LIBS', "-L$dir -lX11");
						MkBreak;
					MkEndif;
					MkIfExists("$dir/libX11.so.*");
						MkDefine('X11_LIBS', "-L$dir -lX11");
						MkBreak;
					MkEndif;
				}
			MkEndif;
		MkEndif;
	MkEndif;

	MkCompileC('HAVE_X11', '${X11_CFLAGS}', '${X11_LIBS}', $testCode);
	MkIfTrue('${HAVE_X11}');
		MkDefine('X11_PC', 'x11');

		MkPrintSN('checking for the XKB extension...');
		MkCompileC('HAVE_XKB', '${X11_CFLAGS}', '${X11_LIBS} -lX11', $testCodeXKB);
		MkIfTrue('${HAVE_XKB}');
			MkDefine('HAVE_XF86MISC', 'no');
			MkSaveUndef('HAVE_XF86MISC');
		MkElse;
			MkPrintSN('checking for the XF86MISC extension...');
			MkCompileC('HAVE_XF86MISC', '${X11_CFLAGS}', '${X11_LIBS} -lX11 -lXxf86misc',
			    $testCodeXF86Misc);
			MkIfTrue('${HAVE_XF86MISC}');
				MkDefine('X11_LIBS', '${X11_LIBS} -lXxf86misc');
				MkSaveDefine('HAVE_XF86MISC', 'X11_LIBS');
			MkElse;
				MkSaveUndef('HAVE_XF86MISC');
			MkEndif;
		MkEndif;
	MkElse;
		MkDisableFailed('x11');
	MkEndif;
}

sub CMAKE_x11
{
	my $codeXKB = MkCodeCMAKE($testCodeXKB);
	my $codeXF86Misc = MkCodeCMAKE($testCodeXF86Misc);

        return << "EOF";
macro(Check_X11)
	set(X11_CFLAGS "")
	set(X11_LIBS "")
	set(XINERAMA_CFLAGS "")
	set(XINERAMA_LIBS "")

	include(FindX11)
	if(X11_FOUND)
		set(HAVE_X11 ON)

		if(X11_INCLUDE_DIR)
			list(APPEND X11_CFLAGS "-I\${X11_INCLUDE_DIR}")
		endif()
		foreach(x11lib \${X11_LIBRARIES})
			list(APPEND X11_LIBS "\${x11lib}")
		endforeach()

		BB_Save_Define(HAVE_X11)

		if(X11_Xinerama_FOUND)
			if(X11_Xinerama_INCLUDE_PATH)
				list(APPEND XINERAMA_CFLAGS "-I\${X11_Xinerama_INCLUDE_PATH}")
			endif()
			if(X11_Xinerama_LIB)
				list(APPEND XINERAMA_LIBS \${X11_Xinerama_LIB})
			endif()

			set(HAVE_XINERAMA ON)
			BB_Save_Define(HAVE_XINERAMA)
		else()
			set(HAVE_XINERAMA OFF)
			BB_Save_Undef(HAVE_XINERAMA)
		endif()

		set(ORIG_CMAKE_REQUIRED_FLAGS \${CMAKE_REQUIRED_FLAGS})
		set(ORIG_CMAKE_REQUIRED_LIBRARIES \${CMAKE_REQUIRED_LIBRARIES})
		set(CMAKE_REQUIRED_FLAGS \${X11_CFLAGS})
		set(CMAKE_REQUIRED_LIBRARIES \${X11_LIBS})

		check_c_source_compiles("
$codeXKB" HAVE_XKB)
		if (HAVE_XKB)
			BB_Save_Define(HAVE_XKB)
		else()
			BB_Save_Undef(HAVE_XKB)
		endif()

		set(CMAKE_REQUIRED_LIBRARIES "\${CMAKE_REQUIRED_LIBRARIES} -lXxf86misc")
		check_c_source_compiles("
$codeXF86Misc" HAVE_XF86MISC)
		if (HAVE_XF86MISC)
			BB_Save_Define(HAVE_XF86MISC)
			set(X11_LIBS "\${X11_LIBS} -lXxf86misc")
		else()
			BB_Save_Undef(HAVE_XF86MISC)
		endif()

		set(CMAKE_REQUIRED_FLAGS \${ORIG_CMAKE_REQUIRED_FLAGS})
		set(CMAKE_REQUIRED_LIBRARIES \${ORIG_CMAKE_REQUIRED_LIBRARIES})
	else()
		set(HAVE_X11 OFF)
		set(HAVE_XKB OFF)
		set(HAVE_XF86MISC OFF)
		set(HAVE_XINERAMA OFF)
		BB_Save_Undef(HAVE_X11)
		BB_Save_Undef(HAVE_XKB)
		BB_Save_Undef(HAVE_XF86MISC)
		BB_Save_Undef(HAVE_XINERAMA)
	endif()

	BB_Save_MakeVar(X11_CFLAGS "\${X11_CFLAGS}")
	BB_Save_MakeVar(X11_LIBS "\${X11_LIBS}")

	BB_Save_MakeVar(XINERAMA_CFLAGS "\${XINERAMA_CFLAGS}")
	BB_Save_MakeVar(XINERAMA_LIBS "\${XINERAMA_LIBS}")
endmacro()

macro(Disable_X11)
	set(HAVE_X11 OFF)
	set(HAVE_XKB OFF)
	set(HAVE_XF86MISC OFF)
	set(HAVE_XINERAMA OFF)
	BB_Save_Undef(HAVE_X11)
	BB_Save_Undef(HAVE_XKB)
	BB_Save_Undef(HAVE_XF86MISC)
	BB_Save_Undef(HAVE_XINERAMA)
	BB_Save_MakeVar(X11_CFLAGS "")
	BB_Save_MakeVar(X11_LIBS "")
	BB_Save_MakeVar(XINERAMA_CFLAGS "")
	BB_Save_MakeVar(XINERAMA_LIBS "")
endmacro()
EOF
}

sub DISABLE_x11
{
	MkDefine('HAVE_X11', 'no') unless $TestFailed;
	MkDefine('X11_CFLAGS', '');
	MkDefine('X11_LIBS', '');
	MkDefine('HAVE_XKB', 'no');
	MkDefine('HAVE_XF86MISC', 'no');
	MkSaveUndef('HAVE_X11', 'HAVE_XKB', 'HAVE_XF86MISC');
}

BEGIN
{
	my $n = 'x11';

	$DESCR{$n}   = 'the X window system';
	$URL{$n}     = 'http://x.org';
	$TESTS{$n}   = \&TEST_x11;
	$CMAKE{$n}   = \&CMAKE_x11;
	$DISABLE{$n} = \&DISABLE_x11;
	$DEPS{$n}    = 'cc';
	$SAVED{$n}   = 'X11_CFLAGS X11_LIBS X11_PC';
}
;1
