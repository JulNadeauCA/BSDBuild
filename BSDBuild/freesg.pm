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
	MkExecOutputUnique('freesg-config', '--version', 'FREESG_VERSION');
	MkIf('"${AGAR_VERSION}" != "" -a "${FREESG_VERSION}" != ""');
		MkPrint('yes');
		MkPrintN('checking whether FreeSG works...');
		MkExecOutput('agar-config', '--cflags', 'AGAR_CFLAGS');
		MkExecOutput('agar-config', '--libs', 'AGAR_LIBS');
		MkExecOutput('freesg-config', '--cflags', 'FREESG_CFLAGS');
		MkExecOutput('freesg-config', '--libs', 'FREESG_LIBS');
		MkCompileC('HAVE_FREESG',
		    '${FREESG_CFLAGS} ${AGAR_CFLAGS}',
		    '${FREESG_LIBS} ${AGAR_LIBS}',
		           << 'EOF');
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
		MkIf('"${HAVE_FREESG}" != ""');
			MkSaveMK('FREESG_CFLAGS', 'FREESG_LIBS');
			MkSaveDefine('FREESG_CFLAGS', 'FREESG_LIBS');
		MkEndif;
	MkElse;
		MkPrint('no');
		MkSaveUndef('HAVE_FREESG', 'FREESG_CFLAGS', 'FREESG_LIBS');
	MkEndif;
	return (0);
}

sub Emul
{
	my ($os, $osrel, $machine) = @_;

	if ($os eq 'darwin') {
		MkDefine('FREESG_CFLAGS', '-I/opt/local/include/freesg '.
		                          '-I/opt/local/include '.
		                          '-I/usr/local/include/freesg '.
							      '-I/usr/local/include '.
		                          '-I/usr/include/freesg -I/usr/include '.
		                          '-D_THREAD_SAFE');
		MkDefine('FREESG_LIBS', '-L/usr/lib -L/opt/local/lib -L/usr/local/lib '.
		                        '-L/usr/X11R6/lib '.
		                        '-lfreesg -framework GLU');
	} elsif ($os eq 'windows') {
		MkDefine('FREESG_CFLAGS', '');
		MkDefine('FREESG_LIBS', 'freesg_pe freesg glu');
	} else {
		MkDefine('FREESG_CFLAGS', '-I/usr/include/freesg -I/usr/include '.
		                          '-I/usr/local/include/freesg '.
							      '-I/usr/local/include ');
		MkDefine('FREESG_LIBS', '-L/usr/local/lib -lfreesg_pe -lfreesg -lGLU');
	}
	MkDefine('HAVE_FREESG', 'yes');
	MkSaveDefine('HAVE_FREESG', 'FREESG_CFLAGS', 'FREESG_LIBS');
	MkSaveMK('FREESG_CFLAGS', 'FREESG_LIBS');
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
