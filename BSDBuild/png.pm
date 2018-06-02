# vim:ts=4
#
# Copyright (c) 2009-2010 Hypertriton, Inc. <http://hypertriton.com/>
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

use BSDBuild::Core;

my $testCode = << 'EOF';
#include <stdio.h>
#include <png.h>

int main(int argc, char *argv[])
{
	char foo[4];

	if (png_sig_cmp((png_bytep)foo, 0, 3)) {
		return (1);
	}
	return (0);
}
EOF

sub Test
{
	my ($ver, $pfx) = @_;
	
	MkExecOutputPfx($pfx, 'libpng-config', '--version', 'PNG_VERSION');
	MkExecOutputPfx($pfx, 'libpng-config', '--cflags', 'PNG_CFLAGS');
	MkExecOutputPfx($pfx, 'libpng-config', '--L_opts', 'PNG_LOPTS');
	MkExecOutputPfx($pfx, 'libpng-config', '--libs', 'PNG_LIBS');
	MkDefine('PNG_LIBS', '${PNG_LOPTS} ${PNG_LIBS}');
	MkIfFound($pfx, $ver, 'PNG_VERSION');
		MkPrintSN('checking whether libpng works...');
		MkCompileC('HAVE_PNG', '${PNG_CFLAGS}', '${PNG_LIBS}', $testCode);
		MkSaveIfTrue('${HAVE_PNG}', 'PNG_CFLAGS', 'PNG_LIBS');
		
		MkTestVersion('PNG_VERSION', '1.4.0');
		MkIfVersionOK;
			MkDefine('HAVE_LIBPNG14', 'yes');
			MkSave('HAVE_LIBPNG14');
		MkElse;
			MkSaveUndef('HAVE_LIBPNG14');
		MkEndif;
	MkElse;
		MkSaveUndef('HAVE_PNG', 'PNG_CFLAGS', 'PNG_LIBS', 'HAVE_LIBPNG14');
	MkEndif;
	
	MkIfTrue('${HAVE_PNG}');
		MkDefine('PNG_PC', 'libpng');
	MkElse;
		MkDefine('PNG_PC', '');
	MkEndif;
	return (0);
}

sub Emul
{
	my ($os, $osrel, $machine) = @_;

	MkEmulUnavail('PNG');

	MkDefine('HAVE_LIBPNG14', 'no');
	MkSaveMK('HAVE_LIBPNG14');
	MkSaveUndef('HAVE_LIBPNG14');
	return (1);
}

BEGIN
{
	$DESCR{'png'} = 'libpng';
	$URL{'png'} = 'http://www.libpng.org';

	$EMUL{'png'} = \&Emul;
	$TESTS{'png'} = \&Test;
	$DEPS{'png'} = 'cc';
}

;1
