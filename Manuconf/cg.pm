# $Csoft: opengl.pm,v 1.5 2004/03/10 16:33:36 vedge Exp $
# vim:ts=4
#
# Copyright (c) 2005 CubeSoft Communications, Inc.
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

my @include_dirs = (
	'/usr/include',
	'/usr/local/include',
	'/usr/Cg/include',
	'/usr/local/Cg/include',
	'/usr/X11R6/include',
	'/usr/X11R6/Cg/include',
);

sub Test
{
	my ($ver) = @_;

	MkDefine('CG_CFLAGS', '');
	MkDefine('CG_LIBS', '');

	foreach my $dir (@include_dirs) {
		MkIf qq{-d "$dir/Cg"}; MkDefine('CG_CFLAGS', "-I$dir"); MkEndif;
	}

	MkIf q{"$SYSTEM" = "Darwin"};
		MkDefine('CG_LIBS', '-F/System/Library/Frameworks -framework Cg');
	MkElif q{"$SYSTEM" = "Linux"};
		MkIf q{"$MACHINE" = "x86_64"};
			MkDefine('CG_LIBS', '-L/usr/X11R6/lib64 -L/usr/lib64');
		MkElse;
			MkDefine('CG_LIBS', '-L/usr/X11R6/lib');
		MkEndif;
		MkDefine('CG_LIBS', '${CG_LIBS} -lCgGL -lCg -lstdc++');
	MkElse;
		MkDefine('CG_LIBS', '-lCgGL -lCg -lstdc++');
	MkEndif;
	
	MkCompileC('HAVE_CG', '${CG_CFLAGS} ${OPENGL_CFLAGS} ${PTHREADS_CFLAGS}',
	                      '${CG_LIBS} ${OPENGL_LIBS} ${PTHREADS_LIBS}',
						  << 'EOF');
#include <Cg/cg.h>
#include <Cg/cgGL.h>

CGcontext context;
CGeffect effect;
CGtechnique technique;

int main(int argc, char *argv[]) {
	context = cgCreateContext();
	return (0);
}
EOF

	MkIf '"${HAVE_CG}" = "yes"';
		MkSaveMK('CG_CFLAGS', 'CG_LIBS');
		MkSaveDefine('CG_CFLAGS', 'CG_LIBS');
	MkEndif;
	return (0);
}

BEGIN
{
	$TESTS{'cg'} = \&Test;
	$DESCR{'cg'} = 'NVIDIA Cg Toolkit';
}

;1
