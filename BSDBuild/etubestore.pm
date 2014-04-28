# vim:ts=4
#
# Copyright (c) 2012 Hypertriton, Inc. <http://hypertriton.com/>
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
#include <etubestore/ets/ets.h>
int main(int argc, char *argv[]) {
	ETS_Item *it;
	ETS_Init(0);
	it = ETS_ItemNew(NULL);
	ETS_Destroy();
	return (it != NULL);
}
EOF

sub Test
{
	my ($ver, $pfx) = @_;
	
	MkExecOutputPfx($pfx, 'etubestore-config', '--version', 'ETUBESTORE_VERSION');
	MkIfFound($pfx, $ver, 'ETUBESTORE_VERSION');
		MkPrintN('checking whether libetubestore works...');
		MkExecOutputPfx($pfx, 'agar-config', '--cflags', 'AGAR_CFLAGS');
		MkExecOutputPfx($pfx, 'agar-config', '--libs', 'AGAR_LIBS');
		MkExecOutputPfx($pfx, 'etubestore-config', '--cflags', 'ETUBESTORE_CFLAGS');
		MkExecOutputPfx($pfx, 'etubestore-config', '--libs', 'ETUBESTORE_LIBS');
		MkCompileC('HAVE_ETUBESTORE',
		           '${ETUBESTORE_CFLAGS} ${AGAR_CFLAGS}',
				   '${ETUBESTORE_LIBS} ${AGAR_LIBS}',
		           $testCode);
		MkSaveIfTrue('${HAVE_ETUBESTORE}', 'ETUBESTORE_CFLAGS', 'ETUBESTORE_LIBS');
	MkElse;
		MkSaveUndef('HAVE_ETUBESTORE', 'ETUBESTORE_CFLAGS', 'ETUBESTORE_LIBS');
	MkEndif;
	return (0);
}

sub Emul
{
	my ($os, $osrel, $machine) = @_;

	if ($os =~ /^windows/) {
		MkEmulWindows('ETUBESTORE', 'etubestore');
	} else {
		MkEmulUnavail('ETUBESTORE');
	}
	return (1);
}

BEGIN
{
	$TESTS{'etubestore'} = \&Test;
	$DESCR{'etubestore'} = 'ElectronTubeStore API (http://electrontubestore.com/)';
	$DEPS{'etubestore'} = 'cc,agar';
	$EMUL{'etubestore'} = \&Emul;
	@{$EMULDEPS{'etubestore'}} = qw(
		agar
	);
}

;1
