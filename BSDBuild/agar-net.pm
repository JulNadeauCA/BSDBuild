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
	
	MkExecOutput('agar-net-config', '--version', 'AGAR_NET_VERSION');
	MkIf(q/"${AGAR_NET_VERSION}" != ""/);
		MkPrint('yes');
		MkExecOutput('agar-net-config', '--cflags', 'AGAR_NET_CFLAGS');
		MkExecOutput('agar-net-config', '--libs', 'AGAR_NET_LIBS');
		MkPrintN('checking whether agar-net works...');
		MkCompileC('HAVE_AGAR_NET',
		    '${AGAR_CFLAGS} ${AGAR_NET_CFLAGS}',
			'${AGAR_LIBS} ${AGAR_NET_LIBS}', << 'EOF');
#include <agar/core.h>
#include <agar/net.h>
#
int main(int argc, char *argv[]) {
	NC_Session sess;
	NC_Init(&sess, "foo", "bar");
	NC_Destroy(&sess);
	return (0);
}
EOF
		MkIf('"${HAVE_AGAR_NET}" = "yes"');
			MkSaveMK('AGAR_NET_CFLAGS', 'AGAR_NET_LIBS');
			MkSaveDefine('AGAR_NET_CFLAGS', 'AGAR_NET_LIBS');
		MkElse;
			MkSaveUndef('AGAR_NET_CFLAGS', 'AGAR_NET_LIBS');
		MkEndif;
	MkElse;
		MkSaveUndef('HAVE_AGAR_NET');
		MkPrint('no');
	MkEndif;
	return (0);
}

BEGIN
{
	$TESTS{'agar-net'} = \&Test;
	$DESCR{'agar-net'} = 'agar-net (http://hypertriton.com/agar-net/)';
	$DEPS{'agar-net'} = 'agar';
}

;1
