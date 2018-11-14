# vim:ts=4
# Public domain

sub Test
{
	my ($ver, $pfx) = @_;
	
	MkDefine('GLX_CFLAGS', '${OPENGL_CFLAGS} ${X11_CFLAGS}');
	MkDefine('GLX_LIBS', '${OPENGL_LIBS} ${X11_LIBS}');

	MkCompileC('HAVE_GLX', '${GLX_CFLAGS}',
	                       '${GLX_LIBS}', << 'EOF');
#include <X11/Xlib.h>
#include <X11/Xutil.h>
#ifdef __APPLE__
#include <OpenGL/gl.h>
#include <OpenGL/glx.h>
#else
#include <GL/gl.h>
#include <GL/glx.h>
#endif
int main(int argc, char *argv[]) {
	Display *d;
	XVisualInfo *xvi;
	int glxAttrs[] = { GLX_RGBA, GLX_RED_SIZE,1, GLX_DEPTH_SIZE,1, None };
	GLXContext glxCtx;
	int err, ev, s;

	d = XOpenDisplay(NULL);
	(void)glXQueryExtension(d, &err, &ev);
	s = DefaultScreen(d);
	if ((xvi = glXChooseVisual(d, s, glxAttrs)) == NULL) { return (1); }
	if ((glxCtx = glXCreateContext(d, xvi, 0, GL_FALSE)) == NULL) { return (1); }
	return (0);
}
EOF
	MkSaveIfTrue('${HAVE_GLX}', 'GLX_CFLAGS', 'GLX_LIBS');
	return (0);
}

sub Disable
{
	MkDefine('GLX_CFLAGS', '');
	MkDefine('GLX_LIBS', '');

	MkSaveUndef('HAVE_GLX');
}

sub Emul
{
	my ($os, $osrel, $machine) = @_;

	MkEmulUnavail('GLX');
	return (1);
}

BEGIN
{
	my $n = 'glx';

	$DESCR{$n} = 'the GLX interface';

	$TESTS{$n}   = \&Test;
	$DISABLE{$n} = \&Disable;
	$EMUL{$n}    = \&Emul;

	$DEPS{$n} = 'cc,opengl,x11,math';
}

;1
