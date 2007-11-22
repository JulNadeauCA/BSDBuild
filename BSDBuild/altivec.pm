# vim:ts=4
#
# Copyright (c) 2007 Hypertriton, Inc. <http://hypertriton.com/>
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
	my $testCode = << 'EOF';
float a[4] = { 1,2,3,4 };
float b[4] = { 5,6,7,8 };
float c[4];

int
main(int argc, char *argv[])
{
	vector float *va = (vector float *)a;
	vector float *vb = (vector float *)b;
	vector float *vc = (vector float *)c;

	*vc = vec_add(*va, *vb);
	return (0);
}
EOF
	
	MkIf q{"$SYSTEM" = "Darwin"};
		MkDefine('ALTIVEC_CFLAGS', '-faltivec -maltivec');
	MkElse;
		MkDefine('ALTIVEC_CFLAGS', '-mabi=altivec -maltivec');
	MkEndif;

	MkCompileC('HAVE_ALTIVEC', '${CFLAGS} ${ALTIVEC_CFLAGS}', '',
	    '#include <altivec.h>'."\n".
		$testCode);
	MkIf('"${HAVE_ALTIVEC}" = "yes"');
	    MkSaveMK('ALTIVEC_CFLAGS');
		MkDefine('HAVE_ALTIVEC_H');
		MkSaveDefine('ALTIVEC_CFLAGS', 'HAVE_ALTIVEC_H');
	MkElse;
		MkPrintN('checking for AltiVec (without <altivec.h>)...');
		MkCompileC('HAVE_ALTIVEC', '${CFLAGS} ${ALTIVEC_CFLAGS}', '',
		    $testCode);
		MkIf('"${HAVE_ALTIVEC}" = "yes"');
	   		MkSaveMK('ALTIVEC_CFLAGS');
			MkSaveDefine('ALTIVEC_CFLAGS');
		MkElse;
			MkSaveUndef('ALTIVEC_CFLAGS');
			MkDefine('ALTIVEC_CFLAGS', '');
			MkSaveMK('ALTIVEC_CFLAGS');
		MkEndif;
		MkSaveUndef('HAVE_ALTIVEC_H');
	MkEndif;

	return (0);
}

sub Emul
{
	my ($os, $osrel, $machine) = @_;

	if ($os eq 'darwin' && $machine eq 'ppc') {
		MkDefine('HAVE_ALTIVEC', 'yes');
		MkSaveDefine('HAVE_ALTIVEC');
		MkDefine('ALTIVEC_CFLAGS', '-faltivec -maltivec');
	} else {
		MkSaveUndef('HAVE_ALTIVEC');
		MkDefine('ALTIVEC_CFLAGS', '');
	}
	MkSaveUndef('HAVE_ALTIVEC_H');
	MkSaveMK('ALTIVEC_CFLAGS');
	MkSaveDefine('ALTIVEC_CFLAGS');
	return (1);
}

BEGIN
{
	$TESTS{'altivec'} = \&Test;
	$EMUL{'altivec'} = \&Emul;
	$DESCR{'altivec'} = 'AltiVec (with <altivec.h>)';
}

;1
