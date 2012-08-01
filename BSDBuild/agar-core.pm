# vim:ts=4
#
# Copyright (c) 2007-2010 Hypertriton, Inc. <http://hypertriton.com/>
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

AG_ObjectClass FooClass = {
	"FooClass",
	sizeof(AG_Object),
	{ 0,0 },
	NULL,		/* init */
	NULL,		/* reinit */
	NULL,		/* destroy */
	NULL,		/* load */
	NULL,		/* save */
	NULL		/* edit */
};

int
main(int argc, char *argv[])
{
	AG_Object obj;

	AG_InitCore("conf-test", 0);
	AG_ObjectInitStatic(&obj, &FooClass);
	AG_ObjectDestroy(&obj);
	AG_Quit();
	return (0);
}
EOF

sub Test
{
	my ($ver, $pfx) = @_;
	
	MkExecOutputPfx($pfx, 'agar-core-config', '--version', 'AGAR_CORE_VERSION');
	MkIfNE('${AGAR_CORE_VERSION}', '');
		MkFoundVer($pfx, $ver, 'AGAR_CORE_VERSION');
		MkPrintN('checking whether Agar-Core works...');
		MkExecOutputPfx($pfx, 'agar-core-config', '--cflags', 'AGAR_CORE_CFLAGS');
		MkExecOutputPfx($pfx, 'agar-core-config', '--libs', 'AGAR_CORE_LIBS');
		MkCompileC('HAVE_AGAR_CORE',
		           '${AGAR_CORE_CFLAGS}', '${AGAR_CORE_LIBS}',
				   $testCode);
		MkSaveIfTrue('${HAVE_AGAR_CORE}', 'AGAR_CORE_CFLAGS', 'AGAR_CORE_LIBS');
	MkElse;
	    MkNotFound($pfx);
		MkSaveUndef('AGAR_CORE_CFLAGS', 'AGAR_CORE_LIBS');
	MkEndif;
	return (0);
}

sub Emul
{
	my ($os, $osrel, $machine) = @_;

	if ($os =~ /^windows/) {
		MkEmulWindows('AGAR_CORE', 'ag_core');
	} else {
		MkEmulUnavail('AGAR_CORE');
	}
	return (1);
}

sub Link
{
	my $var = shift;

	if ($var ne 'ag_core') {
		return (0);
	}
	PmLink('ag_core');
	if ($EmulEnv =~ /^cb-/) {
		PmIncludePath('$(#agar.include)');
		PmLibPath('$(#agar.lib)');
	}
	return (1);
}

BEGIN
{
	$TESTS{'agar-core'} = \&Test;
	$DEPS{'agar-core'} = 'cc';
	$LINK{'agar-core'} = \&Link;
	$EMUL{'agar-core'} = \&Emul;
	$DESCR{'agar-core'} = 'Agar-Core (http://libagar.org/)';
}

;1
