# $Csoft: opengl.pm,v 1.5 2004/03/10 16:33:36 vedge Exp $
# vim:ts=4
#
# Copyright (c) 2002, 2003, 2004 CubeSoft Communications, Inc.
# <http://www.csoft.org>
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
	my ($ver) = @_;

	print << 'EOF';
if [ "$SYSTEM" = "Darwin" ]; then
	OPENGL_CFLAGS=""
	OPENGL_LIBS="-framework OpenGL"
else
	OPENGL_CFLAGS="${X11_CFLAGS}"
	OPENGL_LIBS="${X11_LIBS} -lGL"
fi
EOF
	TryLibCompile 'HAVE_OPENGL',
	    '${OPENGL_CFLAGS}', '${OPENGL_LIBS}', << 'EOF';
#ifdef __APPLE__
# include <OpenGL/gl.h>
#else
# include <GL/gl.h>
#endif

int
main(int argc, char *argv[])
{
	GLdouble d;

	glFlush();
	return (0);
}
EOF

	print
		Cond('"${HAVE_OPENGL}" = "yes"',
		MKSave('OPENGL_CFLAGS') .
		MKSave('OPENGL_LIBS') .
		HDefineStr('OPENGL_CFLAGS') .
		HDefineStr('OPENGL_LIBS') ,
		HUndef('OPENGL_CFLAGS') .
		HUndef('OPENGL_LIBS'));

	return (0);
}

BEGIN
{
	$TESTS{'opengl'} = \&Test;
	$DESCR{'opengl'} = 'OpenGL (http://www.sgi.com/software/opengl)';
}

;1
