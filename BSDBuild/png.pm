# vim:ts=4
#
# Copyright (c) 2009 Hypertriton, Inc. <http://hypertriton.com/>
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

sub Test
{
	my ($ver) = @_;
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
	
	MkExecOutput('libpng-config', '--version', 'PNG_VERSION');
	MkExecOutput('libpng-config', '--cflags', 'PNG_CFLAGS');
	MkExecOutput('libpng-config', '--L_opts', 'PNG_LIBS');
	
	MkIf('"${PNG_VERSION}" != ""');
		MkPrint('yes');
		MkTestVersion('libpng', 'PNG_VERSION', $ver);
		MkPrintN('checking whether libpng works...');
		MkCompileC('HAVE_PNG', '${PNG_CFLAGS}', '${PNG_LIBS}', $testCode);
		MkIf('"${HAVE_PNG}" != "no"');
			MkSaveMK('PNG_CFLAGS', 'PNG_LIBS');
			MkSaveDefine('PNG_CFLAGS', 'PNG_LIBS');
		MkEndif;
	MkElse;
		MkPrint('no');
		MkSaveUndef('HAVE_PNG', 'PNG_CFLAGS', 'PNG_LIBS');
	MkEndif;
	return (0);
}

sub Link
{
	my $lib = shift;

	if ($lib ne 'png') {
		return (0);
	}
	PmIfHDefined('HAVE_PNG');
		PmLink('png');
		if ($EmulEnv =~ /^cb-/) {
			PmIncludePath('$(#libpng.include)');
			PmLibPath('$(#libpng.lib)');
		}
	PmEndif;
	return (1);
}

sub Emul
{
	my ($os, $osrel, $machine) = @_;

	if ($os eq 'darwin') {
		MkDefine('PNG_CFLAGS', '-I/opt/local/include/libpng12 -I/opt/local/include '.
		                       '-I/usr/local/include/libpng12 -I/usr/local/include '.
		                       '-I/usr/include/libpng12 -I/usr/include '.
		                       '-D_GNU_SOURCE=1 -D_THREAD_SAFE');
		MkDefine('PNG_LIBS', '-L/usr/lib -L/opt/local/lib -L/usr/local/lib '.
		                     '-lpng12');
	} elsif ($os eq 'windows') {
		MkDefine('PNG_CFLAGS', '');
		MkDefine('PNG_LIBS', 'png');
	} else {
		MkDefine('PNG_CFLAGS', '-I/usr/include/libpng12 -I/usr/include '.
		                       '-I/usr/local/include/libpng12 '.
							   '-I/usr/local/include '.
		                       '-I/usr/X11R6/include '.
		                       '-D_GNU_SOURCE=1 -D_REENTRANT');
		MkDefine('PNG_LIBS', '-lpng12 -lpthread');
	}
	MkDefine('HAVE_PNG', 'yes');
	MkSaveDefine('HAVE_PNG', 'PNG_CFLAGS', 'PNG_LIBS');
	MkSaveMK('PNG_CFLAGS', 'PNG_LIBS');
	return (1);
}

BEGIN
{
	$DESCR{'png'} = 'libpng (http://www.libpng.org)';
	$EMUL{'png'} = \&Emul;
	$TESTS{'png'} = \&Test;
	$LINK{'png'} = \&Link;
	$DEPS{'png'} = 'cc';
}

;1
