# $Csoft: libqnet.pm,v 1.2 2004/10/24 23:43:06 vedge Exp $
# vim:ts=4
#
# Copyright (c) 2004 CubeSoft Communications, Inc.
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
	
	MkExecOutput('qnet-config', '--version', 'libqnet_version');
	MkIf(q/"${libqnet_version}" != ""/);
		MkPrint('yes');
		MkExecOutput('qnet-config', '--cflags', 'LIBQNET_CFLAGS');
		MkExecOutput('qnet-config', '--libs', 'LIBQNET_LIBS');
		MkPrint('checking whether libqnet works...');
		MkCompileC('HAVE_LIBQNET', '${LIBQNET_CFLAGS}', '${LIBQNET_LIBS}',
			       << 'EOF');
#include <sys/param.h>
#include <qnet/qnet.h>
#include <qnet/server.h>
int main(int argc, char *argv[]) {
	server_regcmd("foo", NULL, NULL);
	server_listen("foo", "1.0", NULL, NULL);
	return (0);
}
EOF
		MkIf('${HAVE_LIBQNET} = "yes"');
			MkSaveMK('LIBQNET_CFLAGS', 'LIBQNET_LIBS');
			MkSaveDefine('LIBQNET_CFLAGS', 'LIBQNET_LIBS');
		MkElse;
			MkSaveUndef('LIBQNET_CFLAGS', 'LIBQNET_LIBS');
		MkEndif;
	MkElse;
		MkPrint('no');
	MkEndif;
	return (0);
}

BEGIN
{
	$TESTS{'libqnet'} = \&Test;
	$DESCR{'libqnet'} = 'libqnet (http://libqnet.csoft.org/)';
}

;1
