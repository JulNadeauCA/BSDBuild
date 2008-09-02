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
	MkExecOutput('agar-math-config', '--version', 'AGAR_MATH_VERSION');
	MkIf('"${AGAR_VERSION}" != "" -a "${AGAR_MATH_VERSION}" != ""');
		MkPrint('yes');
		MkPrintN('checking whether FreeSG works...');
		MkExecOutput('agar-config', '--cflags', 'AGAR_CFLAGS');
		MkExecOutput('agar-config', '--libs', 'AGAR_LIBS');
		MkExecOutput('agar-math-config', '--cflags', 'AGAR_MATH_CFLAGS');
		MkExecOutput('agar-math-config', '--libs', 'AGAR_MATH_LIBS');
		MkCompileC('HAVE_AGAR_MATH',
		    '${AGAR_MATH_CFLAGS} ${AGAR_CFLAGS}',
		    '${AGAR_MATH_LIBS} ${AGAR_LIBS}',
		           << 'EOF');
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
		MkIf('"${HAVE_AGAR_MATH}" != ""');
			MkSaveMK('AGAR_MATH_CFLAGS', 'AGAR_MATH_LIBS');
			MkSaveDefine('AGAR_MATH_CFLAGS', 'AGAR_MATH_LIBS');
		MkEndif;
	MkElse;
		MkPrint('no');
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
	} elsif ($os eq 'linux' || $os =~ /^(open|net|free)bsd$/) {
		MkDefine('AGAR_MATH_CFLAGS', '-I/usr/include/agar -I/usr/include '.
		                             '-I/usr/local/include/agar '.
							         '-I/usr/local/include ');
		MkDefine('AGAR_MATH_LIBS', '-L/usr/local/lib -lag_math');
	} else {
		goto UNAVAIL;
	}
	MkDefine('HAVE_AGAR_MATH', 'yes');
	MkSaveDefine('HAVE_AGAR_MATH', 'AGAR_MATH_CFLAGS', 'AGAR_MATH_LIBS');
	MkSaveMK('AGAR_MATH_CFLAGS', 'AGAR_MATH_LIBS');
	return (1);
UNAVAIL:
	MkDefine('HAVE_AGAR_MATH', 'no');
	MkSaveUndef('HAVE_AGAR_MATH');
	MkSaveMK('AGAR_MATH_CFLAGS', 'AGAR_MATH_LIBS');
	return (1);
}

sub Link
{
	my $var = shift;

	if ($var eq 'ag_math') {
		print << 'EOF';
tinsert(package.links, { "ag_math" })
EOF
		return (1);
	}
	return (0);
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