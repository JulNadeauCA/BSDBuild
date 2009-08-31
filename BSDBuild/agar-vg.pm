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

sub Test
{
	my ($ver) = @_;
	
	MkExecOutputUnique('agar-config', '--version', 'AGAR_VERSION');
	MkExecOutputUnique('agar-vg-config', '--version', 'AGAR_VG_VERSION');
	MkTestVersion('Agar', 'AGAR_VG_VERSION', $ver);
	MkIf('"${AGAR_VERSION}" != "" -a "${AGAR_VG_VERSION}" != ""');
		MkPrint('yes');
		MkPrintN('checking whether agar-vg works...');
		MkExecOutput('agar-config', '--cflags', 'AGAR_CFLAGS');
		MkExecOutput('agar-config', '--libs', 'AGAR_LIBS');
		MkExecOutput('agar-vg-config', '--cflags', 'AGAR_VG_CFLAGS');
		MkExecOutput('agar-vg-config', '--libs', 'AGAR_VG_LIBS');
		MkCompileC('HAVE_AGAR_VG',
		    '${AGAR_VG_CFLAGS} ${AGAR_CFLAGS}',
		    '${AGAR_VG_LIBS} ${AGAR_LIBS}',
		           << 'EOF');
#include <agar/core.h>
#include <agar/vg.h>

int main(int argc, char *argv[]) {
	VG vg;
	VG_Init(&vg, 0);
	return (0);
}
EOF
		MkIf('"${HAVE_AGAR_VG}" != ""');
			MkSaveMK('AGAR_VG_CFLAGS', 'AGAR_VG_LIBS');
			MkSaveDefine('AGAR_VG_CFLAGS', 'AGAR_VG_LIBS');
		MkEndif;
	MkElse;
		MkPrint('no');
		MkSaveUndef('HAVE_AGAR_VG', 'AGAR_VG_CFLAGS', 'AGAR_VG_LIBS');
	MkEndif;
	return (0);
}

sub Emul
{
	my ($os, $osrel, $machine) = @_;

	if ($os eq 'windows') {
		MkDefine('AGAR_VG_CFLAGS', '');
		MkDefine('AGAR_VG_LIBS', 'ag_vg');
	} else {
		MkDefine('AGAR_VG_CFLAGS', '-I/usr/local/include/agar '.
		                            '-I/usr/include/agar');
		MkDefine('AGAR_VG_LIBS', '-L/usr/local/lib -lag_vg');
	}
	MkDefine('HAVE_AGAR_VG', 'yes');
	MkSaveDefine('HAVE_AGAR_VG', 'AGAR_VG_CFLAGS', 'AGAR_VG_LIBS');
	MkSaveMK('AGAR_VG_CFLAGS', 'AGAR_VG_LIBS');
	return (1);
}

sub Link
{
	my $var = shift;

	if ($var ne 'ag_vg') {
		return (0);
	}
	PmLink('ag_vg');
	if ($EmulEnv =~ /^cb-/) {
		PmIncludePath('$(#agar.include)');
		PmLibPath('$(#agar.lib)');
	}
	return (1);
}

BEGIN
{
	$DESCR{'agar-vg'} = 'agar-vg (http://hypertriton.com/agar-vg/)';
	$DEPS{'agar-vg'} = 'cc,agar';
	$TESTS{'agar-vg'} = \&Test;
	$LINK{'agar-vg'} = \&Link;
	$EMUL{'agar-vg'} = \&Emul;
}

;1
