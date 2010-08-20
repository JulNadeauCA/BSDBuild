# vim:ts=4
#
# Copyright (c) 2008-2010 Hypertriton, Inc. <http://hypertriton.com/>
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
#include <edacious/core.h>

int main(int argc, char *argv[]) {
	ES_Circuit *ckt;
	ckt = ES_CircuitNew(NULL, "foo");
	ES_CircuitLog(ckt, "foo");
	return (0);
}
EOF

sub Test
{
	my ($ver, $pfx) = @_;
	
	MkExecOutputPfx($pfx, 'edacious-config', '--version', 'EDACIOUS_VERSION');
	MkIfNE('${EDACIOUS_VERSION}', '');
		MkFoundVer($pfx, $ver, 'EDACIOUS_VERSION');
		MkPrintN('checking whether Edacious works...');
		MkExecOutputPfx($pfx, 'agar-config', '--cflags', 'AGAR_CFLAGS');
		MkExecOutputPfx($pfx, 'agar-config', '--libs', 'AGAR_LIBS');
		MkExecOutputPfx($pfx, 'agar-vg-config', '--cflags', 'AGAR_VG_CFLAGS');
		MkExecOutputPfx($pfx, 'agar-vg-config', '--libs', 'AGAR_VG_LIBS');
		MkExecOutputPfx($pfx, 'agar-math-config', '--cflags', 'AGAR_MATH_CFLAGS');
		MkExecOutputPfx($pfx, 'agar-math-config', '--libs', 'AGAR_MATH_LIBS');
		MkExecOutputPfx($pfx, 'edacious-config', '--cflags', 'EDACIOUS_CFLAGS');
		MkExecOutputPfx($pfx, 'edacious-config', '--libs', 'EDACIOUS_LIBS');
		MkCompileC('HAVE_EDACIOUS',
		           '${EDACIOUS_CFLAGS} ${AGAR_MATH_CFLAGS} ${AGAR_VG_CFLAGS} '.
		           '${AGAR_CFLAGS}',
		           '${EDACIOUS_LIBS} ${AGAR_MATH_LIBS} ${AGAR_VG_LIBS} '.
		           '${AGAR_LIBS}',
		           $testCode);
		MkSaveIfTrue('${HAVE_EDACIOUS}', 'EDACIOUS_CFLAGS', 'EDACIOUS_LIBS');
	MkElse;
		MkNotFound($pfx);
		MkSaveUndef('HAVE_EDACIOUS', 'EDACIOUS_CFLAGS', 'EDACIOUS_LIBS');
	MkEndif;
	return (0);
}

sub Emul
{
	my ($os, $osrel, $machine) = @_;

	if ($os eq 'darwin') {
		MkDefine('EDACIOUS_CFLAGS', '-I/opt/local/include/edacious '.
		                            '-I/opt/local/include '.
		                            '-I/usr/local/include/edacious '.
							        '-I/usr/local/include '.
		                            '-I/usr/include/edacious -I/usr/include '.
		                            '-D_THREAD_SAFE');
		MkDefine('EDACIOUS_LIBS', '-L/usr/lib -L/opt/local/lib '.
		                          '-L/usr/local/lib '.
		                          '-L/usr/X11R6/lib '.
		                          '-les_core');
	} elsif ($os eq 'windows') {
		MkDefine('EDACIOUS_CFLAGS', '');
		MkDefine('EDACIOUS_LIBS', 'es_core');
	} else {
		MkDefine('EDACIOUS_CFLAGS', '-I/usr/include/edacious -I/usr/include '.
		                          '-I/usr/local/include/edacious '.
							      '-I/usr/local/include ');
		MkDefine('EDACIOUS_LIBS', '-L/usr/local/lib -les_core');
	}
	MkDefine('HAVE_EDACIOUS', 'yes');
	MkSave('HAVE_EDACIOUS', 'EDACIOUS_CFLAGS', 'EDACIOUS_LIBS');
	return (1);
}

sub Link
{
	my $var = shift;

	if ($var ne 'edacious' && $var ne 'es_core') {
		return (0);
	}
	PmLink('es_core');
	if ($EmulEnv =~ /^cb-/) {
		PmIncludePath('$(#edacious.include)');
		PmLibPath('$(#edacious.lib)');
	}
	return (1);
}

BEGIN
{
	$TESTS{'edacious'} = \&Test;
	$DESCR{'edacious'} = 'Edacious (http://edacious.hypertriton.com/)';
	$DEPS{'edacious'} = 'cc,agar,agar-vg,agar-math';
	$EMUL{'edacious'} = \&Emul;
	$LINK{'edacious'} = \&Link;
}

;1
