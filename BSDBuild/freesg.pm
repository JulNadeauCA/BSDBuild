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
#include <agar/gui.h>
#include <freesg/sg.h>
int main(int argc, char *argv[]) {
	SG *sg;
	sg = SG_New(NULL, "foo", 0);
	AG_ObjectDestroy(sg);
	return (0);
}
EOF

sub Test
{
	my ($ver, $pfx) = @_;
	
	MkExecOutputPfx($pfx, 'freesg-config', '--version', 'FREESG_VERSION');
	MkIfNE('${FREESG_VERSION}', '');
		MkFoundVer($pfx, $ver, 'FREESG_VERSION');
		MkPrintN('checking whether FreeSG works...');
		MkExecOutputPfx($pfx, 'agar-config', '--cflags', 'AGAR_CFLAGS');
		MkExecOutputPfx($pfx, 'agar-config', '--libs', 'AGAR_LIBS');
		MkExecOutputPfx($pfx, 'freesg-config', '--cflags', 'FREESG_CFLAGS');
		MkExecOutputPfx($pfx, 'freesg-config', '--libs', 'FREESG_LIBS');
		MkCompileC('HAVE_FREESG',
		           '${FREESG_CFLAGS} ${AGAR_CFLAGS}',
		           '${FREESG_LIBS} ${AGAR_LIBS}',
		           $testCode);
		MkSaveIfTrue('${HAVE_FREESG}', 'FREESG_CFLAGS', 'FREESG_LIBS');
	MkElse;
		MkNotFound($pfx);
		MkSaveUndef('HAVE_FREESG', 'FREESG_CFLAGS', 'FREESG_LIBS');
	MkEndif;
	return (0);
}

sub Emul
{
	my ($os, $osrel, $machine) = @_;

	if ($os =~ /^windows/) {
		MkEmulWindows('FREESG', 'freesg_pe freesg glu');
	} else {
		MkEmulUnavail('FREESG');
	}
	return (1);
}

sub Link
{
	my $var = shift;

	if ($var eq 'freesg') {
		PmLink('freesg');
		if ($EmulEnv =~ /^cb-/) {
			PmIncludePath('$(#freesg.include)');
			PmLibPath('$(#freesg.lib)');
		}
		return (1);
	}
	if ($var eq 'freesg_sk') {
		PmLink('freesg_sk');
		if ($EmulEnv =~ /^cb-/) {
			PmIncludePath('$(#freesg.include)');
			PmLibPath('$(#freesg.lib)');
		}
		return (1);
	}
	if ($var eq 'freesg_pe') {
		PmLink('freesg_pe');
		if ($EmulEnv =~ /^cb-/) {
			PmIncludePath('$(#freesg.include)');
			PmLibPath('$(#freesg.lib)');
		}
		return (1);
	}

	return (0);
}

BEGIN
{
	$TESTS{'freesg'} = \&Test;
	$DESCR{'freesg'} = 'FreeSG (http://FreeSG.org/)';
	$DEPS{'freesg'} = 'cc,agar';
	$EMUL{'freesg'} = \&Emul;
	$LINK{'freesg'} = \&Link;
}

;1
