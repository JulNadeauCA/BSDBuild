# vim:ts=4
#
# Copyright (c) 2013 Hypertriton, Inc. <http://hypertriton.com/>
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
#include <agar/gui.h>
#include <freesg/rg.h>

int main(int argc, char *argv[]) {
	RG_Tileset *ts;

	ts = RG_TilesetNew(NULL, "foo", 0);
	AG_ObjectDestroy(ts);
	return (0);
}
EOF

sub Test
{
	my ($ver, $pfx) = @_;
	
	MkExecOutputPfx($pfx, 'freesg-rg-config', '--version', 'FREESG_RG_VERSION');
	MkIfFound($pfx, $ver, 'FREESG_RG_VERSION');
		MkPrintSN('checking whether FreeSG-RG works...');
		MkExecOutputPfx($pfx, 'agar-config', '--cflags', 'AGAR_CFLAGS');
		MkExecOutputPfx($pfx, 'agar-config', '--libs', 'AGAR_LIBS');
		MkExecOutputPfx($pfx, 'freesg-rg-config', '--cflags', 'FREESG_RG_CFLAGS');
		MkExecOutputPfx($pfx, 'freesg-rg-config', '--libs', 'FREESG_RG_LIBS');
		MkCompileC('HAVE_FREESG_RG',
		           '${FREESG_RG_CFLAGS} ${AGAR_CFLAGS}',
		           '${FREESG_RG_LIBS} ${AGAR_LIBS}',
				   $testCode);
		MkSaveIfTrue('${HAVE_FREESG_RG}', 'FREESG_RG_CFLAGS', 'FREESG_RG_LIBS');
	MkElse;
		MkSaveUndef('HAVE_FREESG_RG', 'FREESG_RG_CFLAGS', 'FREESG_RG_LIBS');
	MkEndif;
	return (0);
}

sub Emul
{
	my ($os, $osrel, $machine) = @_;

	if ($os =~ /^windows/) {
		MkEmulWindows('FREESG_RG', 'freesg_rg');
	} else {
		MkEmulUnavail('FREESG_RG');
	}
	return (1);
}

BEGIN
{
	$DESCR{'freesg-rg'} = 'FreeSG-RG';
	$URL{'freesg-rg'} = 'http://freesg.org';

	$DEPS{'freesg-rg'} = 'cc,agar';
	$TESTS{'freesg-rg'} = \&Test;
	$EMUL{'freesg-rg'} = \&Emul;
}

;1
