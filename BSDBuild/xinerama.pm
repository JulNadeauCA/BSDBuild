# Public domain

sub TEST_xinerama
{
	my ($ver, $pfx) = @_;

	MkIfPkgConfig('xinerama');
		MkExecPkgConfig($pfx, 'xinerama', '--modversion', 'XINERAMA_VERSION');
		MkExecPkgConfig($pfx, 'xinerama', '--cflags', 'XINERAMA_CFLAGS');
		MkExecPkgConfig($pfx, 'xinerama', '--libs', 'XINERAMA_LIBS');
	MkElse;
		MkDefine('XINERAM_CFLAGS', '');
		MkDefine('XINERAMA_LIBS', '');
		MkIfNE($pfx, '');
			MkIfExists("$pfx/include/X11");
				MkDefine('XINERAMA_CFLAGS', "-I$pfx/include");
			MkEndif;
			MkIfExists("$pfx/lib");
				MkDefine('XINERAMA_LIBS', "-L$pfx/lib");
			MkEndif;
		MkElse;
			my @autoIncludeDirs = (
				'/usr/include/X11',
				'/usr/include/X11R6',
				'/usr/local/X11/include',
				'/usr/local/X11R6/include',
				'/usr/local/include/X11',
				'/usr/local/include/X11R6',
				'/usr/X11/include',
				'/usr/X11R6/include',
			);
			my @autoLibDirs = (
				'/usr/local/X11/lib',
				'/usr/local/X11R6/lib',
				'/usr/X11/lib',
				'/usr/X11R6/lib',
			);
			foreach my $dir (@autoIncludeDirs) {
				MkIfExists("$dir/X11");
					MkDefine('XINERAMA_CFLAGS', "-I$dir");
				MkEndif;
			}
			foreach my $dir (@autoLibDirs) {
				MkIfExists($dir);
					MkDefine('XINERAMA_LIBS', "\${XINERAMA_LIBS} -L$dir");
				MkEndif;
			}
		MkEndif;
		MkDefine('XINERAMA_LIBS', "\${XINERAMA_LIBS} -lXinerama");
	MkEndif;

	MkCompileC('HAVE_XINERAMA', '${X11_CFLAGS} ${XINERAMA_CFLAGS}',
	                            '${X11_LIBS} ${XINERAMA_LIBS}', << 'EOF');
#include <X11/Xlib.h>
#include <X11/extensions/Xinerama.h>

int main(int argc, char *argv[])
{
	Display *disp;
	int event_base = 0, error_base = 0;
	int rv = 1;

	disp = XOpenDisplay(NULL);
	if (XineramaQueryExtension(disp, &event_base, &error_base)) {
		rv = 0;
	}
	XCloseDisplay(disp);
	return (rv);
}
EOF
	MkIfTrue('${HAVE_XINERAMA}');
		MkDefine('XINERAMA_PC', 'xinerama');
	MkElse;
		MkDisableFailed('xinerama');
	MkEndif;
}

sub DISABLE_xinerama
{
	MkDefine('HAVE_XINERAMA', 'no') unless $TestFailed;
	MkDefine('XINERAMA_CFLAGS', '');
	MkDefine('XINERAMA_LIBS', '');
	MkSaveUndef('HAVE_XINERAMA');
}

BEGIN
{
	my $n = 'xinerama';

	$DESCR{$n}   = 'the Xinerama extension';
	$URL{$n}     = 'http://x.org';
	$TESTS{$n}   = \&TEST_xinerama;
	$DISABLE{$n} = \&DISABLE_xinerama;
	$DEPS{$n}    = 'cc,x11';
	$SAVED{$n}   = 'XINERAMA_CFLAGS XINERAMA_LIBS XINERAMA_PC';
}
;1
