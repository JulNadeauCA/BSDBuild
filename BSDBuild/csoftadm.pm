# $Csoft: csoftadm.pm,v 1.2 2004/01/03 04:13:29 vedge Exp $
# vim:ts=4
#
# Copyright (c) 2003-2007 CubeSoft Communications, Inc.
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
	
	MkExecOutput('csoftadm-config', '--version', 'CSOFTADM_VERSION');
	MkExecOutput('csoftadm-config', '--cflags', 'CSOFTADM_CFLAGS');
	MkExecOutput('csoftadm-config', '--libs', 'CSOFTADM_LIBS');

	MkIf('"${CSOFTADM_VERSION}" != ""');
		MkPrint('yes');
		MkTestVersion('Csoftadm', 'CSOFTADM_VERSION', $ver);
		MkPrintN('checking whether csoftadm works...');
		MkCompileC('HAVE_CSOFTADM', '${CSOFTADM_CFLAGS}', '${CSOFTADM_LIBS}',
	               << 'EOF');
#include <libcsoftadm/csoftadm.h>
int main(int argc, char *argv[]) {
	int rv;
	rv = csoftadm_init();
	csoftadm_destroy();
	return (0);
}
EOF
		MkIf('"${HAVE_CSOFTADM}" != "no"');
			MkSaveDefine('CSOFTADM_CFLAGS', 'CSOFTADM_LIBS');
			MkSaveMK	('CSOFTADM_CFLAGS', 'CSOFTADM_LIBS');
		MkEndif;
	MkElse;
		MkPrint('no');
		MkSaveUndef('HAVE_CSOFTADM');
	MkEndif;
	return (0);
}

BEGIN
{
	$DESCR{'csoftadm'} = 'libcsoftadm (http://hypertriton.com/csoftadm)';
	$DEPS{'csoftadm'} = 'cc';
	$TESTS{'csoftadm'} = \&Test;
}
;1
