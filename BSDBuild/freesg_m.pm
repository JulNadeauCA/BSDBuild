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
	
	MkExecOutput('agar-config', '--version', 'AGAR_VERSION');
	MkExecOutput('freesg-m-config', '--version', 'FREESG_VERSION');
	MkIf('"${AGAR_VERSION}" != "" -a "${FREESG_VERSION}" != ""');
		MkPrint('yes');
		MkPrintN('checking whether FreeSG works...');
		MkExecOutput('agar-config', '--cflags', 'AGAR_CFLAGS');
		MkExecOutput('agar-config', '--libs', 'AGAR_LIBS');
		MkExecOutput('freesg-m-config', '--cflags', 'FREESG_M_CFLAGS');
		MkExecOutput('freesg-m-config', '--libs', 'FREESG_M_LIBS');
		MkCompileC('HAVE_FREESG_M',
		    '${FREESG_M_CFLAGS} ${AGAR_CFLAGS}',
		    '${FREESG_M_LIBS} ${AGAR_LIBS}',
		           << 'EOF');
#include <agar/core.h>
#include <freesg/m/m.h>
int main(int argc, char *argv[]) {
	M_Matrix *A = M_New(2,2);
	AG_InitCore("test", 0);
	M_InitSubsystem();
	M_SetIdentity(A);
	AG_Destroy();
	return (0);
}
EOF
		MkIf('"${HAVE_FREESG_M}" != ""');
			MkSaveMK('FREESG_M_CFLAGS', 'FREESG_M_LIBS');
			MkSaveDefine('FREESG_M_CFLAGS', 'FREESG_M_LIBS');
		MkEndif;
	MkElse;
		MkPrint('no');
		MkSaveUndef('HAVE_FREESG_M', 'FREESG_M_CFLAGS', 'FREESG_M_LIBS');
	MkEndif;
	return (0);
}

sub Emul
{
	my ($os, $osrel, $machine) = @_;

	if ($os eq 'darwin') {
		MkDefine('FREESG_M_CFLAGS', '-I/opt/local/include/freesg '.
		                            '-I/opt/local/include '.
		                            '-I/usr/local/include/freesg '.
							        '-I/usr/local/include '.
		                            '-I/usr/include/freesg -I/usr/include '.
		                            '-D_THREAD_SAFE');
		MkDefine('FREESG_M_LIBS', '-L/usr/lib -L/opt/local/lib '.
		                          '-L/usr/local/lib -L/usr/X11R6/lib '.
		                          '-lfreesg_m');
	} elsif ($os eq 'windows') {
		MkDefine('FREESG_M_CFLAGS', '');
		MkDefine('FREESG_M_LIBS', 'freesg_m');
	} else {
		MkDefine('FREESG_CFLAGS', '-I/usr/include/freesg -I/usr/include '.
		                          '-I/usr/local/include/freesg '.
							      '-I/usr/local/include ');
		MkDefine('FREESG_LIBS', '-L/usr/local/lib -lfreesg_m');
	}
	MkDefine('HAVE_FREESG_M', 'yes');
	MkSaveDefine('HAVE_FREESG_M', 'FREESG_M_CFLAGS', 'FREESG_M_LIBS');
	MkSaveMK('FREESG_M_CFLAGS', 'FREESG_M_LIBS');
	return (1);
}

sub Link
{
	my $var = shift;

	if ($var ne 'freesg_m') {
		return (0);
	}
	PmLink('freesg_m');
	if ($EmulEnv =~ /^cb-/) {
		PmIncludePath('$(#freesg.include)');
		PmLibPath('$(#freesg.lib)');
	}
	return (1);
}

BEGIN
{
	$TESTS{'freesg_m'} = \&Test;
	$DESCR{'freesg_m'} = 'FreeSG math library (http://FreeSG.org/)';
	$DEPS{'freesg_m'} = 'cc,agar';
	$EMUL{'freesg_m'} = \&Emul;
	$LINK{'freesg_m'} = \&Link;
}

;1
