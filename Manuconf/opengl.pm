# $Csoft: opengl.pm,v 1.2 2002/12/31 07:42:16 vedge Exp $
# vim:ts=4
#
# Copyright (c) 2002, 2003 CubeSoft Communications, Inc.
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
OPENGL_CFLAGS="${X11_CFLAGS}"
OPENGL_LIBS="${X11_LIBS} -lGL"
EOF
	TryLibCompile 'HAVE_OPENGL',
	    '${OPENGL_CFLAGS}', '${OPENGL_LIBS}', << 'EOF';
#include <GL/gl.h>

int
main(int argc, char *argv[])
{
	GLdouble d;

	glFlush();
	return (0);
}
EOF

	print Cond('"${HAVE_OPENGL}" = "yes"',
	    MKSave('OPENGL_CFLAGS', '$OPENGL_CFLAGS') .
		MKSave('OPENGL_LIBS', '$OPENGL_LIBS'),
		Nothing());

	return (0);
}

BEGIN
{
	$TESTS{'opengl'} = \&Test;
	$DESCR{'opengl'} = 'OpenGL (http://www.sgi.com/software/opengl)';
}

;1
