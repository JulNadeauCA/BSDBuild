# vim:ts=4
#
# Copyright (c) 2008 Hypertriton, Inc. <http://hypertriton.com/>
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
	
	MkExecOutputUnique('agar-config', '--version', 'AGAR_VERSION');
	MkExecOutputUnique('agar-vg-config', '--version', 'AGAR_VG_VERSION');
	MkExecOutputUnique('agar-math-config', '--version', 'AGAR_MATH_VERSION');
	MkExecOutputUnique('edacious-config', '--version', 'EDACIOUS_VERSION');
	MkIf('"${AGAR_VERSION}" != "" -a "${AGAR_VG_VERSION}" != "" '.
	     '-a "${AGAR_MATH_VERSION}" != "" -a "${EDACIOUS_VERSION}" != ""');
		MkPrint('yes');
		MkPrintN('checking whether Edacious works...');
		MkExecOutput('agar-config', '--cflags', 'AGAR_CFLAGS');
		MkExecOutput('agar-config', '--libs', 'AGAR_LIBS');
		MkExecOutput('agar-vg-config', '--cflags', 'AGAR_VG_CFLAGS');
		MkExecOutput('agar-vg-config', '--libs', 'AGAR_VG_LIBS');
		MkExecOutput('agar-math-config', '--cflags', 'AGAR_MATH_CFLAGS');
		MkExecOutput('agar-math-config', '--libs', 'AGAR_MATH_LIBS');
		MkExecOutput('edacious-config', '--cflags', 'EDACIOUS_CFLAGS');
		MkExecOutput('edacious-config', '--libs', 'EDACIOUS_LIBS');
		MkCompileC('HAVE_EDACIOUS',
		    '${EDACIOUS_CFLAGS} ${AGAR_MATH_CFLAGS} ${AGAR_VG_CFLAGS} '.
			'${AGAR_CFLAGS}',
		    '${EDACIOUS_LIBS} ${AGAR_MATH_LIBS} ${AGAR_VG_LIBS} '.
			'${AGAR_LIBS}',
		           << 'EOF');
#include <edacious/core.h>
int main(int argc, char *argv[]) {
	ES_Circuit *ckt;
	ckt = ES_CircuitNew(NULL, "foo");
	ES_CircuitLog(ckt, "foo");
	return (0);
}
EOF
		MkIf('"${HAVE_EDACIOUS}" != ""');
			MkSaveMK('EDACIOUS_CFLAGS', 'EDACIOUS_LIBS');
			MkSaveDefine('EDACIOUS_CFLAGS', 'EDACIOUS_LIBS');
		MkEndif;
	MkElse;
		MkPrint('no');
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
	MkSaveDefine('HAVE_EDACIOUS', 'EDACIOUS_CFLAGS', 'EDACIOUS_LIBS');
	MkSaveMK('EDACIOUS_CFLAGS', 'EDACIOUS_LIBS');
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
