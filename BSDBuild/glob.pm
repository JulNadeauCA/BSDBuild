# $Csoft: gethostname.pm,v 1.2 2004/01/03 04:13:29 vedge Exp $
# vim:ts=4
#
# Copyright (c) 2009 CubeSoft Communications, Inc.
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
	TryCompile 'HAVE_GLOB', << 'EOF';
#include <glob.h>
#include <stdio.h>

int
main(int argc, char *argv[])
{
	glob_t gl;
	int rv, i;
	char *s;

	rv = glob("~/foo", GLOB_TILDE, NULL, &gl);
	for (i = 0; i < gl.gl_pathc; i++) { s = gl.gl_pathv[i]; }
	return (0);
}
EOF
}

sub Emul
{
	my ($os, $osrel, $machine) = @_;

	if ($os eq 'linux' || $os eq 'darwin' || $os =~ /^(open|net|free)bsd$/) {
		MkDefine('HAVE_GLOB', 'yes');
		MkSaveDefine('HAVE_GLOB');
	} else {
		MkSaveUndef('HAVE_GLOB');
	}
	return (1);
}

BEGIN
{
	$DESCR{'glob'} = 'the glob() function';
	$TESTS{'glob'} = \&Test;
	$EMUL{'glob'} = \&Emul;
	$DEPS{'glob'} = 'cc';
}

;1
