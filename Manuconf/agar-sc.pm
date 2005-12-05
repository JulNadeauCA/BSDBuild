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
	MkExecOutput('agar-sc-config', '--version', 'AGAR_SC_VERSION');
	MkIf('"${AGAR_VERSION}" != "" -a "${AGAR_SC_VERSION}" != ""');
		MkPrint('yes');
		MkPrintN('checking whether agar-sc works...');
		MkExecOutput('agar-config', '--cflags', 'AGAR_CFLAGS');
		MkExecOutput('agar-config', '--libs', 'AGAR_LIBS');
		MkExecOutput('agar-sc-config', '--cflags', 'AGAR_SC_CFLAGS');
		MkExecOutput('agar-sc-config', '--libs', 'AGAR_SC_LIBS');
		MkCompileC('HAVE_AGAR_SC',
		    '${AGAR_CFLAGS} ${AGAR_SC_CFLAGS}',
		    '${AGAR_SC_LIBS} ${AGAR_LIBS}',
		           << 'EOF');
#include <agar/core.h>
#include <agar/sc.h>
int main(int argc, char *argv[]) {
	SC_Matrix *m;

	m = SC_MatrixNew(4,4);
	SC_MatrixFree(m);
	return (0);
}
EOF
		MkIf('"${HAVE_AGAR_SC}" != ""');
			MkSaveMK('AGAR_SC_CFLAGS', 'AGAR_SC_LIBS');
			MkSaveDefine('AGAR_SC_CFLAGS', 'AGAR_SC_LIBS');
		MkEndif;
	MkElse;
		MkPrint('no');
		MkSaveUndef('HAVE_AGAR_SC');
	MkEndif;
	return (0);
}

BEGIN
{
	$TESTS{'agar-sc'} = \&Test;
	$DESCR{'agar-sc'} = 'Agar-Sc (http://agar-sc.csoft.org/)';
}

;1
