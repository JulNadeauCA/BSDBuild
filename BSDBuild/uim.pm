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
#include <uim.h>
#include <uim-util.h>

int main(int argc, char *argv[]) {
	uim_context uimCtx;
	const char *s;
	int i;

	uimCtx = uim_create_context(NULL, "UTF-8", NULL, NULL, uim_iconv, NULL);
	for (i = 0; i < uim_get_nr_im(uimCtx); i++) {
		s = uim_get_im_name(uimCtx, i);
		if (s == NULL) { return (1); }
	}
	uim_release_context(uimCtx);

	return (0);
}
EOF

sub Test
{
	my ($ver, $pfx) = @_;
	
	MkExecPkgConfig($pfx, 'uim', '--modversion', 'UIM_VERSION');
	MkExecPkgConfig($pfx, 'uim', '--cflags', 'UIM_CFLAGS');
	MkExecPkgConfig($pfx, 'uim', '--libs', 'UIM_LIBS');
	MkIfFound($pfx, $ver, 'UIM_VERSION');
		MkPrintN('checking whether uim works...');
		MkCompileC('HAVE_UIM', '${UIM_CFLAGS}', '${UIM_LIBS}', $testCode);
		MkSaveIfTrue('${HAVE_UIM}', 'UIM_CFLAGS', 'UIM_LIBS');
	MkElse;
		MkSaveUndef('HAVE_UIM');
	MkEndif;
	return (0);
}

sub Emul
{
	my ($os, $osrel, $machine) = @_;
	
	MkEmulUnavail('UIM');
	return (1);
}

BEGIN
{
	$DESCR{'uim'} = 'uim framework (http://code.google.com/p/uim/)';
	$TESTS{'uim'} = \&Test;
	$DEPS{'uim'} = 'cc';
	$EMUL{'uim'} = \&Emul;
}

;1
