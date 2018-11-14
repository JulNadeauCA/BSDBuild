# Public domain
# vim:ts=4

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

sub Test
{
	my ($ver) = @_;

	MkCompileC('HAVE_WGL',
	           '${OPENGL_CFLAGS}',
			   '${OPENGL_LIBS} -lgdi32',
	           $testCode);
	MkIfTrue('${HAVE_WGL}');
		MkDefine('OPENGL_LIBS', '${OPENGL_LIBS} -lgdi32');
		MkSave('OPENGL_LIBS');
	MkEndif;

	return (0);
}

sub Disable
{
	MkSaveUndef('HAVE_WGL');
}

sub Emul
{
	my ($os, $osrel, $machine) = @_;
	
	if ($os =~ /^windows/) {
		MkEmulWindowsSYS('WGL');
	} else {
		MkEmulUnavailSYS('WGL');
	}
	return (1);
}

BEGIN
{
	my $n = 'wgl';

	$DESCR{$n} = 'the WGL interface';

	$TESTS{$n}   = \&Test;
	$DISABLE{$n} = \&Disable;
	$EMUL{$n}    = \&Emul;

	$DEPS{$n} = 'cc';
}

;1
