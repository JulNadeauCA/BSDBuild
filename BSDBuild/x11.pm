# vim:ts=4
# Public domain

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
				    MkDefine('X11_CFLAGS', '-I${with_x_includes}/X11');
				MkElse;
				    MkDefine('X11_CFLAGS', '-I${with_x_includes}');
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

	MkCompileC('HAVE_X11', '${X11_CFLAGS}', '${X11_LIBS}', << 'EOF');
#include <X11/Xlib.h>
int main(int argc, char *argv[])
{
	Display *disp = XOpenDisplay(NULL);
	XCloseDisplay(disp);
	return (0);
}
EOF
	MkSaveIfTrue('${HAVE_X11}', 'X11_CFLAGS', 'X11_LIBS');

	MkIfTrue('${HAVE_X11}');
		MkDefine('X11_PC', 'x11');

		MkPrintSN('checking for the XKB extension...');
		MkCompileC('HAVE_XKB', '${X11_CFLAGS}', '${X11_LIBS} -lX11', << 'EOF');
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
		MkIfTrue('${HAVE_XKB}');
			MkDefine('HAVE_XF86MISC', 'no');
			MkSaveUndef('HAVE_XF86MISC');
		MkElse;
			MkPrintSN('checking for the XF86MISC extension...');
			MkCompileC('HAVE_XF86MISC', '${X11_CFLAGS}', '${X11_LIBS} -lX11 -lXxf86misc', << 'EOF');
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
			MkIfTrue('${HAVE_XF86MISC}');
				MkDefine('X11_LIBS', '${X11_LIBS} -lXxf86misc');
				MkSaveMK('X11_LIBS');
				MkSaveDefine('HAVE_XF86MISC', 'X11_LIBS');
			MkElse;
				MkSaveUndef('HAVE_XF86MISC');
			MkEndif;
		MkEndif;
	MkElse;
		DISABLE_x11();
	MkEndif;
}

sub DISABLE_x11
{
	MkDefine('HAVE_X11', 'no');
	MkDefine('HAVE_XKB', 'no');
	MkDefine('HAVE_XF86MISC', 'no');
	MkDefine('X11_CFLAGS', '');
	MkDefine('X11_LIBS', '');
	MkDefine('X11_PC', '');
	MkSaveUndef('HAVE_X11', 'HAVE_XKB', 'HAVE_XF86MISC');
}

BEGIN
{
	my $n = 'x11';

	$DESCR{$n}   = 'the X window system';
	$URL{$n}     = 'http://x.org';
	$TESTS{$n}   = \&TEST_x11;
	$DISABLE{$n} = \&DISABLE_x11;
	$DEPS{$n}    = 'cc';
}
;1
