# vim:ts=4
#
# Copyright (c) 2016 Hypertriton, Inc. <http://hypertriton.com/>
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

use BSDBuild::Core;

my @autoPrefixDirs = (
	'/usr/local',
	'/usr',
	'/usr/pkg',
	'/opt/local',
	'/opt'
);

my $testCode = << 'EOF';
#include <stdio.h>
#include <libircclient.h>
#include <libirc_rfcnumeric.h>

int main(int argc, char *argv[]) {
	irc_callbacks_t cb;
	irc_session_t *sess;
	cb.event_connect = NULL;
	return ((sess = irc_create_session(&cb)) == NULL);
}
EOF

sub Test
{
	my ($ver, $pfx) = @_;
	my @pfxDirs = ();

	# XXX TODO: detect if compiled against openssl

	push @pfxDirs, $pfx if $pfx;
	push @pfxDirs, @autoPrefixDirs;

	foreach my $dir (@pfxDirs) {
		MkIfExists("$dir/include/libircclient.h");
		    MkDefine('LIBIRCCLIENT_CFLAGS', "-I$dir/include");
		    MkDefine('LIBIRCCLIENT_LIBS', "-L$dir/lib -lircclient");
			MkPrintS('yes');
			MkBreak;
		MkEndif;
	}
	MkIfNE('${LIBIRCCLIENT_CFLAGS}', '');
		MkPrintSN('checking whether libircclient works...');
		MkCompileC('HAVE_LIBIRCCLIENT', '${LIBIRCCLIENT_CFLAGS}',
		    '${LIBIRCCLIENT_LIBS}', $testCode);
		MkIfTrue('${HAVE_LIBIRCCLIENT}');
			MkSave('LIBIRCCLIENT_CFLAGS', 'LIBIRCCLIENT_LIBS');
		MkElse;
			MkSaveUndef('HAVE_LIBIRCCLIENT', 'LIBIRCCLIENT_CFLAGS',
			            'LIBIRCCLIENT_LIBS');
		MkEndif;
	MkElse;
		MkPrintS('no');
		MkSaveUndef('HAVE_LIBIRCCLIENT', 'LIBIRCCLIENT_CFLAGS',
		            'LIBIRCCLIENT_LIBS');
	MkEndif;
	return (0);
}

sub Emul
{
	my ($os, $osrel, $machine) = @_;

	if ($os =~ /^windows/) {
		MkEmulWindows('LIBIRCCLIENT', 'LIBIRCCLIENT');
	} else {
		MkEmulUnavail('LIBIRCCLIENT');
	}
	return (1);
}

BEGIN
{
	$DESCR{'libircclient'} = 'libircclient';
	$URL{'libircclient'} = 'http://www.ulduzsoft.com/libircclient';

	$EMUL{'libircclient'} = \&Emul;
	$TESTS{'libircclient'} = \&Test;
	$DEPS{'libircclient'} = 'cc';
}

;1
