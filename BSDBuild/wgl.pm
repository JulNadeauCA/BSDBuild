# Public domain

my $testCode = << 'EOF';
#include <windows.h>

int main(int argc, char *argv[]) {
	HWND hwnd;
	HDC hdc;
	HGLRC hglrc;

	hwnd = CreateWindowEx(0, "a", "a", WS_OVERLAPPEDWINDOW, CW_USEDEFAULT,
	    CW_USEDEFAULT, 0,0, NULL, NULL, GetModuleHandle(NULL), NULL);
	hdc = GetDC(hwnd);
	hglrc = wglCreateContext(hdc);
	SwapBuffers(hdc);
	wglDeleteContext(hglrc);
	ReleaseDC(hwnd, hdc);
	DestroyWindow(hwnd);
	return (0);
}
EOF

sub TEST_wgl
{
	my ($ver) = @_;

	MkCompileC('HAVE_WGL',
	           '${OPENGL_CFLAGS}', '${OPENGL_LIBS} -lgdi32', $testCode);
	MkIfTrue('${HAVE_WGL}');
		MkDefine('OPENGL_LIBS', '${OPENGL_LIBS} -lgdi32');
	MkElse;
		MkDisableFailed('wgl');
	MkEndif;
}

sub DISABLE_wgl
{
	MkDefine('HAVE_WGL', 'no') unless $TestFailed;
	#
	# Don't clear OPENGL_CFLAGS and OPENGL_LIBS (conflict with opengl)
	#
	MkSaveUndef('HAVE_WGL');
}

BEGIN
{
	my $n = 'wgl';

	$DESCR{$n}   = 'the WGL interface';
	$TESTS{$n}   = \&TEST_wgl;
	$DISABLE{$n} = \&DISABLE_wgl;
	$DEPS{$n}    = 'cc';
	$SAVED{$n}   = 'OPENGL_CFLAGS OPENGL_LIBS';
}
;1
