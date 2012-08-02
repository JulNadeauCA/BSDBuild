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
	TryCompile 'HAVE_GETOPT', << 'EOF';
#include <string.h>
#include <unistd.h>

int
main(int argc, char *argv[])
{
	int c, x = 0;
	while ((c = getopt(argc, argv, "foo")) != -1) {
		extern char *optarg;
		extern int optind, opterr, optopt;
		if (optarg != NULL) { x = 1; }
		if (optind > 0) { x = 2; }
		if (opterr > 0) { x = 3; }
		if (optopt > 0) { x = 4; }
	}
	return (x != 0);
}
EOF
}

sub Emul
{
	my ($os, $osrel, $machine) = @_;

	MkEmulUnavail('GETOPT');
	return (1);
}

BEGIN
{
	$TESTS{'getopt'} = \&Test;
	$DEPS{'getopt'} = 'cc';
	$EMUL{'getopt'} = \&Emul;
	$DESCR{'getopt'} = 'the getopt() function';
}

;1
