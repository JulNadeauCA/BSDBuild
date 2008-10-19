# $Csoft: libqnet.pm,v 1.2 2004/10/24 23:43:06 vedge Exp $
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
	
	MkExecOutputUnique('agar-config', '--version', 'AGAR_VERSION');
	MkIf('"${AGAR_VERSION}" != ""');
		MkPrint('yes');
		MkExecOutput('agar-config', '--cflags', 'AGAR_CFLAGS');
		MkExecOutput('agar-config', '--libs', 'AGAR_LIBS');
		MkPrintN('checking for network support in ag_core...');
		MkCompileC('HAVE_AGAR_NETWORK',
		    '${AGAR_CFLAGS}',
			'${AGAR_LIBS}', << 'EOF');
#include <agar/core.h>
#include <agar/core/net.h>

int main(int argc, char *argv[]) {
	NC_Session sess;
	NC_Init(&sess, "foo", "bar");
	NC_Destroy(&sess);
	return (0);
}
EOF
	MkElse;
		MkPrint('no');
		MkSaveUndef('HAVE_AGAR_NETWORK');
	MkEndif;
	return (0);
}

sub Emul
{
	my ($os, $osrel, $machine) = @_;

	if ($os eq 'windows') {
		MkDefine('HAVE_AGAR_NETWORK', 'no');
	} elsif ($os eq 'linux' || $os eq 'darwin' ||
	         $os =~ /^(open|net|free)bsd$/) {
		MkDefine('HAVE_AGAR_NETWORK', 'yes');
	} else {
		goto UNAVAIL;
	}
	MkDefine('HAVE_AGAR_NETWORK', 'yes');
	MkSaveDefine('HAVE_AGAR_NETWORK');
	return (1);
UNAVAIL:
	MkDefine('HAVE_AGAR_NETWORK', 'no');
	MkSaveUndef('HAVE_AGAR_NETWORK');
	return (1);
}

BEGIN
{
	$DESCR{'agar-network'} = 'ag_core';
	$DEPS{'agar-network'} = 'cc,agar';
	$TESTS{'agar-network'} = \&Test;
	$EMUL{'agar-network'} = \&Emul;
}

;1
