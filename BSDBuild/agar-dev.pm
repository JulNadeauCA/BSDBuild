# vim:ts=4
#
# Copyright (c) 2009 Hypertriton, Inc. <http://hypertriton.com/>
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
#include <agar/dev.h>

int main(int argc, char *argv[]) {
	AG_Object obj;

	AG_ObjectInitStatic(&obj, &agObjectClass);
	DEV_InitSubsystem(0);
	DEV_Browser(&obj);
	AG_ObjectDestroy(&obj);
	return (0);
}
EOF

sub Test
{
	my ($ver, $pfx) = @_;
	
	MkExecOutputPfx($pfx, 'agar-dev-config', '--version', 'AGAR_DEV_VERSION');
	MkIfNE('${AGAR_DEV_VERSION}', '');
		MkFoundVer($pfx, $ver, 'AGAR_DEV_VERSION');
		MkPrintN('checking whether Agar-DEV works...');
		MkExecOutputPfx($pfx, 'agar-config', '--cflags', 'AGAR_CFLAGS');
		MkExecOutputPfx($pfx, 'agar-config', '--libs', 'AGAR_LIBS');
		MkExecOutputPfx($pfx, 'agar-dev-config', '--cflags', 'AGAR_DEV_CFLAGS');
		MkExecOutputPfx($pfx, 'agar-dev-config', '--libs', 'AGAR_DEV_LIBS');
		MkCompileC('HAVE_AGAR_DEV',
		           '${AGAR_DEV_CFLAGS} ${AGAR_CFLAGS}',
				   '${AGAR_DEV_LIBS} ${AGAR_LIBS}',
				   $testCode);
		MkSaveIfTrue('${HAVE_AGAR_DEV}', 'AGAR_DEV_CFLAGS', 'AGAR_DEV_LIBS');
	MkElse;
		MkNotFound($pfx);
		MkSaveUndef('HAVE_AGAR_DEV', 'AGAR_DEV_CFLAGS', 'AGAR_DEV_LIBS');
	MkEndif;
	return (0);
}

sub Emul
{
	my ($os, $osrel, $machine) = @_;

	if ($os eq 'windows') {
		MkDefine('AGAR_DEV_CFLAGS', '');
		MkDefine('AGAR_DEV_LIBS', 'ag_dev');
	} else {
		MkDefine('AGAR_DEV_CFLAGS', '-I/usr/local/include/agar '.
		                            '-I/usr/include/agar');
		MkDefine('AGAR_DEV_LIBS', '-L/usr/local/lib -lag_dev');
	}
	MkDefine('HAVE_AGAR_DEV', 'yes');
	MkSave('HAVE_AGAR_DEV', 'AGAR_DEV_CFLAGS', 'AGAR_DEV_LIBS');
	return (1);
}

sub Link
{
	my $var = shift;

	if ($var ne 'ag_dev') {
		return (0);
	}
	PmLink('ag_dev');
	if ($EmulEnv =~ /^cb-/) {
		PmIncludePath('$(#agar.include)');
		PmLibPath('$(#agar.lib)');
	}
	return (1);
}

BEGIN
{
	$DESCR{'agar-dev'} = 'agar-dev (http://libagar.org/)';
	$DEPS{'agar-dev'} = 'cc,agar';
	$TESTS{'agar-dev'} = \&Test;
	$LINK{'agar-dev'} = \&Link;
	$EMUL{'agar-dev'} = \&Emul;
}

;1
