# $Csoft: freetype.pm,v 1.12 2004/03/10 16:33:36 vedge Exp $
# vim:ts=4
#
# Copyright (c) 2002-2007 CubeSoft Communications, Inc.
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

	MkExecOutput('freetype-config', '--version', 'FREETYPE_VERSION');
	MkExecOutput('freetype-config', '--cflags', 'FREETYPE_CFLAGS');
	MkExecOutput('freetype-config', '--libs', 'FREETYPE_LIBS');

	# XXX IRIX package hack.
	MkIf('-d /usr/freeware/include');
		MkAppend('FREETYPE_CFLAGS', '-I/usr/freeware/include');
	MkEndif;

	MkIf('"${FREETYPE_VERSION}" != ""');
		MkPrint('yes');
		MkPrintN('checking whether FreeType works...');
		MkCompileC('HAVE_FREETYPE', '${FREETYPE_CFLAGS}', '${FREETYPE_LIBS}',
		           << 'EOF');
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
		MkIf('"${HAVE_FREETYPE}" = "yes"');
	    	MkSaveDefine('FREETYPE_CFLAGS', 'FREETYPE_LIBS');
			MkSaveMK	('FREETYPE_CFLAGS', 'FREETYPE_LIBS');
		MkElse;
	    	MkSaveUndef	('FREETYPE_CFLAGS', 'FREETYPE_LIBS');
		MkEndif;
	MkElse;
	    MkSaveUndef('HAVE_FREETYPE');
		MkPrint('no');
	MkEndif;
	return (0);
}

sub Link
{
	my $lib = shift;

	if ($lib eq 'freetype') {
			print << 'EOF';
if (hdefs["HAVE_FREETYPE"] ~= nil) then
	table.insert(package.links, { "freetype" })
end
EOF
		return (1);
	}
	return (0);
}

sub Emul
{
	my ($os, $osrel, $machine) = @_;

	if ($os eq 'darwin') {
		MkDefine('FREETYPE_CFLAGS', '-I/usr/X11R6/include '.
		                            '-I/usr/X11R6/include/freetype2');
		MkDefine('FREETYPE_LIBS', '-L/usr/X11R6/lib -lfreetype');
	} elsif ($os eq 'windows') {
		MkDefine('FREETYPE_CFLAGS', '');
		MkDefine('FREETYPE_LIBS', 'freetype6');
	} elsif ($os eq 'linux' || $os =~ /^(open|net|free)bsd$/) {
		MkDefine('FREETYPE_CFLAGS', '-I/usr/include/freetype2 '.
		                            '-I/usr/local/include/freetype2 '.
									'-I/usr/local/include '.
									'-I/usr/X11R6/include/freetype2 '.
									'-I/usr/X11R6/include');
		MkDefine('FREETYPE_LIBS', '-L/usr/local/lib '.
		                          '-Wl,--rpath --Wl,/usr/local/lib ' .
		                          '-L/usr/X11R6/lib '.
		                          '-Wl,--rpath --Wl,/usr/X11R6/lib ' .
		                          '-lfreetype -lz');
	} else {
		goto UNAVAIL;
	}
	MkDefine('HAVE_FREETYPE', 'yes');
	MkSaveDefine('HAVE_FREETYPE', 'FREETYPE_CFLAGS', 'FREETYPE_LIBS');
	MkSaveMK('FREETYPE_CFLAGS', 'FREETYPE_LIBS');
	return (1);
UNAVAIL:
	MkDefine('HAVE_FREETYPE', 'no');
	MkSaveUndef('HAVE_FREETYPE');
	MkSaveMK('FREETYPE_CFLAGS', 'FREETYPE_LIBS');
	return (1);
}

BEGIN
{
	$DESCR{'freetype'} = 'FreeType (http://www.freetype.org)';
	$DEPS{'freetype'} = 'cc';
	$TESTS{'freetype'} = \&Test;
	$EMUL{'freetype'} = \&Emul;
	$LINK{'freetype'} = \&Link;
}

;1
