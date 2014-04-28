# vim:ts=4
#
# Copyright (c) 2012 Hypertriton, Inc. <http://hypertriton.com/>
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
#include <stdio.h>
#include <string.h>
#include <fontconfig/fontconfig.h>

int
main(int argc, char *argv[])
{
	FcPattern *pattern, *fpat;
    FcResult result = FcResultMatch;
	const FcChar8 name[1] = { '\0' };
    FcChar8 *file;
    FcMatrix *mat = NULL;
    double size;
    int idx;
    if (!FcInit()) { return (1); }
    if ((pattern = FcNameParse(name)) == NULL) { return (1); }
    if (!FcConfigSubstitute(NULL, pattern, FcMatchPattern)) { return (1); }
    FcDefaultSubstitute(pattern);
    if ((fpat = FcFontMatch(NULL, pattern, &result)) == NULL) { return (1); }
    if (FcPatternGetString(fpat, FC_FILE, 0, &file) != FcResultMatch) { return (1); }
    if (FcPatternGetInteger(fpat, FC_INDEX, 0, &idx) != FcResultMatch) { return (1); }
    if (FcPatternGetDouble(fpat, FC_SIZE, 0, &size) != FcResultMatch) { return (1); }
    if (FcPatternGetMatrix(fpat, FC_MATRIX, 0, &mat) != FcResultMatch) { return (1); }
    return (0);
}
EOF

sub Test
{
	my ($ver, $pfx) = @_;
	
	MkExecPkgConfig($pfx, 'fontconfig', '--modversion', 'FONTCONFIG_VERSION');
	MkExecPkgConfig($pfx, 'fontconfig', '--cflags', 'FONTCONFIG_CFLAGS');
	MkExecPkgConfig($pfx, 'fontconfig', '--libs', 'FONTCONFIG_LIBS');
	MkIfFound($pfx, $ver, 'FONTCONFIG_VERSION');
		MkPrintN('checking whether fontconfig works...');
		MkCompileC('HAVE_FONTCONFIG',
		           '${FONTCONFIG_CFLAGS}', '${FONTCONFIG_LIBS}',
				   $testCode);
		MkSaveIfTrue('${HAVE_FONTCONFIG}', 'FONTCONFIG_CFLAGS', 'FONTCONFIG_LIBS');
	MkElse;
		MkSaveUndef('HAVE_FONTCONFIG');
	MkEndif;
	return (0);
}

sub Emul
{
	my ($os, $osrel, $machine) = @_;
	
	MkEmulUnavail('FONTCONFIG');
	return (1);
}

BEGIN
{
	$DESCR{'fontconfig'} = 'fontconfig (http://fontconfig.org/)';
	$TESTS{'fontconfig'} = \&Test;
	$DEPS{'fontconfig'} = 'cc';
	$EMUL{'fontconfig'} = \&Emul;
}

;1
