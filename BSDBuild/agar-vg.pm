# $Csoft: agar.pm,v 1.7 2005/09/27 00:29:42 vedge Exp $
# vim:ts=4
#
# Copyright (c) 2007 CubeSoft Communications, Inc.
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

my $testCode = << 'EOF';
#include <agar/core.h>
#include <agar/vg.h>

int main(int argc, char *argv[]) {
	VG vg;
	VG_Init(&vg, 0);
	return (0);
}
EOF

sub Test
{
	my ($ver, $pfx) = @_;
	
	MkExecOutputPfx($pfx, 'agar-vg-config', '--version', 'AGAR_VG_VERSION');
	MkIfFound($pfx, $ver, 'AGAR_VG_VERSION');
		MkPrintSN('checking whether agar-vg works...');
		MkExecOutputPfx($pfx, 'agar-config', '--cflags', 'AGAR_CFLAGS');
		MkExecOutputPfx($pfx, 'agar-config', '--libs', 'AGAR_LIBS');
		MkExecOutputPfx($pfx, 'agar-vg-config', '--cflags', 'AGAR_VG_CFLAGS');
		MkExecOutputPfx($pfx, 'agar-vg-config', '--libs', 'AGAR_VG_LIBS');
		MkCompileC('HAVE_AGAR_VG',
		           '${AGAR_VG_CFLAGS} ${AGAR_CFLAGS}',
		           '${AGAR_VG_LIBS} ${AGAR_LIBS}',
				   $testCode);
		MkSaveIfTrue('${HAVE_AGAR_VG}', 'AGAR_VG_CFLAGS', 'AGAR_VG_LIBS');
	MkElse;
		MkSaveUndef('HAVE_AGAR_VG', 'AGAR_VG_CFLAGS', 'AGAR_VG_LIBS');
	MkEndif;
	return (0);
}

sub Emul
{
	my ($os, $osrel, $machine) = @_;

	if ($os =~ /^windows/) {
		MkEmulWindows('AGAR_VG', 'ag_vg');
	} else {
		MkEmulUnavail('AGAR_VG');
	}
	return (1);
}

BEGIN
{
	$DESCR{'agar-vg'} = 'Agar-VG';
	$URL{'agar-vg'} = 'http://libagar.org';

	$DEPS{'agar-vg'} = 'cc,agar';
	$TESTS{'agar-vg'} = \&Test;
	$EMUL{'agar-vg'} = \&Emul;
}

;1
