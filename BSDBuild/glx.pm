# vim:ts=4
#
# Copyright (c) 2009-2010 Hypertriton Inc. <http://hypertriton.com/>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
# USE OF THIS SOFTWARE EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

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

sub Link
{
	my $lib = shift;

	if ($lib ne 'glx') {
		return (0);
	}
	PmIfHDefined('HAVE_GLX');
		if ($EmulEnv =~ /^cb-/) {
			PmIncludePath('$(#GLX.include)');
			PmLibPath('$(#GLX.lib)');
		}
	PmEndif;
	return (1);
}

sub Emul
{
	my ($os, $osrel, $machine) = @_;

	MkEmulUnavail('GLX');
	return (1);
}

BEGIN
{
	$DESCR{'glx'} = 'the GLX interface';
	$TESTS{'glx'} = \&Test;
	$LINK{'glx'} = \&Link;
	$EMUL{'glx'} = \&Emul;
	$DEPS{'glx'} = 'cc,opengl,x11,math';
}

;1
