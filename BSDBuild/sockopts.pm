# vim:ts=4
#
# Copyright (c) 2012 Hypertriton, Inc. <http://www.hypertriton.com/>
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

sub CheckBoolOption
{
	my $opt = shift;

	MkPrintN("checking for $opt...");
	TryCompile "HAVE_$opt", << "EOF";
#include <sys/types.h>
#include <sys/socket.h>
#include <fcntl.h>
int
main(int argc, char *argv[])
{
	int fd = 0, val = 1, rv;
	socklen_t valLen = sizeof(val);
	rv = setsockopt(fd, SOL_SOCKET, $opt, &val, valLen);
	return (rv != 0);
}
EOF
}

sub Test
{
	TryCompile 'HAVE_SETSOCKOPT', << 'EOF';
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/time.h>
#include <fcntl.h>
int
main(int argc, char *argv[])
{
	int fd = 0, rv;
	struct timeval tv;
	socklen_t tvLen = sizeof(tv);
	tv.tv_sec = 1; tv.tv_usec = 0;
	rv = setsockopt(fd, SOL_SOCKET, SO_SNDTIMEO, &tv, tvLen);
	return (rv != 0);
}
EOF
	MkIfTrue('${HAVE_SETSOCKOPT}');
		CheckBoolOption('SO_OOBINLINE');
		CheckBoolOption('SO_REUSEPORT');
		CheckBoolOption('SO_TIMESTAMP');
		CheckBoolOption('SO_NOSIGPIPE');

		MkPrintN('checking for SO_LINGER...');
		TryCompile 'HAVE_SO_LINGER', << 'EOF';
#include <sys/types.h>
#include <sys/socket.h>
#include <fcntl.h>
int
main(int argc, char *argv[])
{
	int fd = 0, rv;
	struct linger ling;
	socklen_t lingLen = sizeof(ling);
	ling.l_onoff = 1; ling.l_linger = 1;
	rv = setsockopt(fd, SOL_SOCKET, SO_LINGER, &ling, lingLen);
	return (rv != 0);
}
EOF
		MkPrintN('checking for SO_ACCEPTFILTER...');
		TryCompile 'HAVE_SO_ACCEPTFILTER', << 'EOF';
#include <sys/types.h>
#include <sys/socket.h>
#include <fcntl.h>
int
main(int argc, char *argv[])
{
	int fd = 0, rv;
	struct accept_filter_arg afa;
	socklen_t afaLen = sizeof(afa);
	afa.af_name[0] = '\0';
	afa.af_arg[0] = '\0';
	rv = setsockopt(fd, SOL_SOCKET, SO_ACCEPTFILTER, &afa, afaLen);
	return (rv != 0);
}
EOF
	MkEndif;
}

sub Emul
{
	my ($os, $osrel, $machine) = @_;

	if ($os eq 'linux' || $os eq 'darwin' || $os =~ /^(open|net|free)bsd/) {
		MkDefine('HAVE_SETSOCKOPT', 'yes');
		MkSaveDefine('HAVE_SETSOCKOPT');
	} else {
		MkSaveUndef('HAVE_SETSOCKOPT');
	}
	MkSaveUndef('HAVE_SO_OOBINLINE');
	MkSaveUndef('HAVE_SO_REUSEPORT');
	MkSaveUndef('HAVE_SO_TIMESTAMP');
	MkSaveUndef('HAVE_SO_NOSIGPIPE');
	MkSaveUndef('HAVE_SO_LINGER');
	MkSaveUndef('HAVE_SO_ACCEPTFILTER');
	return (1);
}

BEGIN
{
	$TESTS{'sockopts'} = \&Test;
	$DEPS{'sockopts'} = 'cc';
	$EMUL{'sockopts'} = \&Emul;
	$DESCR{'sockopts'} = 'the setsockopt() interface';
}

;1
