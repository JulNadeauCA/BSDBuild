# vim:ts=4
#
# Copyright (c) 2002-2018 Julien Nadeau Carriere <vedge@hypertriton.com>
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

my $testCode = << 'EOF';
#include <ft2build.h>
#include FT_FREETYPE_H
#include FT_OUTLINE_H
int
main(int argc, char *argv[])
{
	FT_Library library;
	FT_Face face;
	FT_Init_FreeType(&library);
	FT_New_Face(library, "foo", 0, &face);
	return (0);
}
EOF

sub Test
{
	my ($ver, $pfx) = @_;

	MkIfPkgConfig('freetype2');
		MkExecPkgConfig($pfx, 'freetype2', '--modversion', 'FREETYPE_VERSION');
		MkExecPkgConfig($pfx, 'freetype2', '--cflags', 'FREETYPE_CFLAGS');
		MkExecPkgConfig($pfx, 'freetype2', '--libs', 'FREETYPE_LIBS');
	MkElse;
	    MkExecOutputPfx($pfx, 'freetype-config', '--version', 'FREETYPE_VERSION');
	    MkExecOutputPfx($pfx, 'freetype-config', '--cflags', 'FREETYPE_CFLAGS');
	    MkExecOutputPfx($pfx, 'freetype-config', '--libs', 'FREETYPE_LIBS');
    MkEndif;

	MkCaseIn('${host}');
	MkCaseBegin('*-*-irix*');
		MkIfExists('/usr/freeware/include');
			MkAppend('FREETYPE_CFLAGS', '-I/usr/freeware/include');
		MkEndif;
		MkCaseEnd;
	MkEsac;

	MkIfFound($pfx, $ver, 'FREETYPE_VERSION');
		MkPrintSN('checking whether FreeType works...');
		MkCompileC('HAVE_FREETYPE', '${FREETYPE_CFLAGS}', '${FREETYPE_LIBS}', $testCode);
		MkSaveIfTrue('${HAVE_FREETYPE}', 'FREETYPE_CFLAGS', 'FREETYPE_LIBS');
	MkElse;
		MkSaveUndef('HAVE_FREETYPE');
	MkEndif;
	
	MkIfTrue('${HAVE_FREETYPE}');
		MkDefine('FREETYPE_PC', 'freetype2');
	MkElse;
		MkDefine('FREETYPE_PC', '');
	MkEndif;
	return (0);
}

sub Emul
{
	my ($os, $osrel, $machine) = @_;

	if ($os =~ /^windows/) {
		MkEmulWindows('FREETYPE', 'freetype');
	} else {
		MkEmulUnavail('FREETYPE');
	}
	return (1);
}

BEGIN
{
	$DESCR{'freetype'} = 'FreeType';
	$URL{'freetype'} = 'http://www.freetype.org';

	$DEPS{'freetype'} = 'cc';
	$TESTS{'freetype'} = \&Test;
	$EMUL{'freetype'} = \&Emul;
}

;1
