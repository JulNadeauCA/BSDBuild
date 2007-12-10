# $Csoft: agar.pm,v 1.7 2005/09/27 00:29:42 vedge Exp $
# vim:ts=4
#
# Copyright (c) 2005 CubeSoft Communications, Inc.
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
	
	MkExecOutput('agar-config', '--version', 'AGAR_VERSION');
	MkExecOutput('agar-sg-config', '--version', 'AGAR_SG_VERSION');
	MkIf('"${AGAR_VERSION}" != "" -a "${AGAR_SG_VERSION}" != ""');
		MkPrint('yes');
		MkPrintN('checking whether agar-sg works...');
		MkExecOutput('agar-config', '--cflags', 'AGAR_CFLAGS');
		MkExecOutput('agar-config', '--libs', 'AGAR_LIBS');
		MkExecOutput('agar-sg-config', '--cflags', 'AGAR_SG_CFLAGS');
		MkExecOutput('agar-sg-config', '--libs', 'AGAR_SG_LIBS');
		MkCompileC('HAVE_AGAR_SG',
		    '${AGAR_SG_CFLAGS} ${AGAR_CFLAGS}',
		    '${AGAR_SG_LIBS} ${AGAR_LIBS}',
		           << 'EOF');
#include <agar/core.h>
#include <agar/sg.h>
int main(int argc, char *argv[]) {
	SG *sg;
	sg = SG_New(NULL, "foo");
	AG_ObjectDestroy(sg);
	return (0);
}
EOF
		MkIf('"${HAVE_AGAR_SG}" != ""');
			MkSaveMK('AGAR_SG_CFLAGS', 'AGAR_SG_LIBS');
			MkSaveDefine('AGAR_SG_CFLAGS', 'AGAR_SG_LIBS');
		MkEndif;
	MkElse;
		MkPrint('no');
		MkSaveUndef('HAVE_AGAR_SG', 'AGAR_SG_CFLAGS', 'AGAR_SG_LIBS');
	MkEndif;
	return (0);
}

sub Emul
{
	my ($os, $osrel, $machine) = @_;

	if ($os eq 'windows') {
		MkDefine('AGAR_SG_CFLAGS', '');
		MkDefine('AGAR_SG_LIBS', 'ag_sg');
	} elsif ($os eq 'linux' || $os eq 'darwin' ||
	         $os =~ /^(open|net|free)bsd$/) {
		MkDefine('AGAR_SG_CFLAGS', '-I/usr/local/include/agar '.
		                            '-I/usr/include/agar');
		MkDefine('AGAR_SG_LIBS', '-L/usr/local/lib -lag_sg');
	} else {
		goto UNAVAIL;
	}
	MkDefine('HAVE_AGAR_SG', 'yes');
	MkSaveDefine('HAVE_AGAR_SG', 'AGAR_SG_CFLAGS', 'AGAR_SG_LIBS');
	MkSaveMK('AGAR_SG_CFLAGS', 'AGAR_SG_LIBS');
	return (1);
UNAVAIL:
	MkDefine('HAVE_AGAR_SG', 'no');
	MkSaveUndef('HAVE_AGAR_SG');
	MkSaveMK('AGAR_SG_CFLAGS', 'AGAR_SG_LIBS');
	return (1);
}

BEGIN
{
	$DESCR{'agar-sg'} = 'agar-sg (http://hypertriton.com/agar-sg/)';
	$DEPS{'agar-sg'} = 'cc,agar';
	$TESTS{'agar-sg'} = \&Test;
	$EMUL{'agar-sg'} = \&Emul;
}

;1
