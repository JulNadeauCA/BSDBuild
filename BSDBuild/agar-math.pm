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

my $testCode = << 'EOF';
#include <agar/core.h>
#include <agar/math.h>

int main(int argc, char *argv[]) {
	M_Matrix *A = M_New(2,2);
	AG_InitCore("test", 0);
	M_InitSubsystem();
	M_SetIdentity(A);
	AG_Destroy();
	return (0);
}
EOF

sub Test
{
	my ($ver, $pfx) = @_;
	
	MkExecOutputPfx($pfx, 'agar-math-config', '--version', 'AGAR_MATH_VERSION');
	MkIfNE('${AGAR_MATH_VERSION}', '');
		MkFoundVer($pfx, $ver, 'AGAR_MATH_VERSION');
		MkPrintN('checking whether Agar-Math works...');
		MkExecOutputPfx($pfx, 'agar-config', '--cflags', 'AGAR_CFLAGS');
		MkExecOutputPfx($pfx, 'agar-config', '--libs', 'AGAR_LIBS');
		MkExecOutputPfx($pfx, 'agar-math-config', '--cflags', 'AGAR_MATH_CFLAGS');
		MkExecOutputPfx($pfx, 'agar-math-config', '--libs', 'AGAR_MATH_LIBS');
		MkCompileC('HAVE_AGAR_MATH',
		           '${AGAR_MATH_CFLAGS} ${AGAR_CFLAGS}',
		           '${AGAR_MATH_LIBS} ${AGAR_LIBS}',
				   $testCode);
		MkSaveIfTrue('${HAVE_AGAR_MATH}', 'AGAR_MATH_CFLAGS', 'AGAR_MATH_LIBS');
	MkElse;
		MkNotFound($pfx);
		MkSaveUndef('HAVE_AGAR_MATH', 'AGAR_MATH_CFLAGS', 'AGAR_MATH_LIBS');
	MkEndif;
	return (0);
}

sub Emul
{
	my ($os, $osrel, $machine) = @_;

	if ($os eq 'darwin') {
		MkDefine('AGAR_MATH_CFLAGS', '-I/opt/local/include/agar '.
		                             '-I/opt/local/include '.
		                             '-I/usr/local/include/agar '.
							         '-I/usr/local/include '.
		                             '-I/usr/include/agar -I/usr/include '.
		                             '-D_THREAD_SAFE');
		MkDefine('AGAR_MATH_LIBS', '-L/usr/lib -L/opt/local/lib '.
		                           '-L/usr/local/lib -L/usr/X11R6/lib '.
		                           '-lag_math');
	} elsif ($os eq 'windows') {
		MkDefine('AGAR_MATH_CFLAGS', '');
		MkDefine('AGAR_MATH_LIBS', 'ag_math');
	} else {
		MkDefine('AGAR_MATH_CFLAGS', '-I/usr/include/agar -I/usr/include '.
		                             '-I/usr/local/include/agar '.
							         '-I/usr/local/include ');
		MkDefine('AGAR_MATH_LIBS', '-L/usr/local/lib -lag_math');
	}
	MkDefine('HAVE_AGAR_MATH', 'yes');
	MkSave('HAVE_AGAR_MATH', 'AGAR_MATH_CFLAGS', 'AGAR_MATH_LIBS');
	return (1);
}

sub Link
{
	my $var = shift;

	if ($var ne 'ag_math') {
		return (0);
	}
	PmLink('ag_math');
	if ($EmulEnv =~ /^cb-/) {
		PmIncludePath('$(#agar.include)');
		PmLibPath('$(#agar.lib)');
	}
	return (1);
}

BEGIN
{
	$TESTS{'agar-math'} = \&Test;
	$DESCR{'agar-math'} = 'Agar-Math library (http://libagar.org/)';
	$DEPS{'agar-math'} = 'cc,agar';
	$EMUL{'agar-math'} = \&Emul;
	$LINK{'agar-math'} = \&Link;
}

;1
