# vim:ts=4
# Public domain

sub TEST_glx
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
}

sub DISABLE_glx
{
	MkDefine('HAVE_GLX', 'no');
	MkDefine('GLX_CFLAGS', '');
	MkDefine('GLX_LIBS', '');
	MkSaveUndef('HAVE_GLX');
}

BEGIN
{
	my $n = 'glx';

	$DESCR{$n}   = 'the GLX interface';
	$TESTS{$n}   = \&TEST_glx;
	$DISABLE{$n} = \&DISABLE_glx;
	$DEPS{$n}    = 'cc,opengl,x11,math';
}
;1
