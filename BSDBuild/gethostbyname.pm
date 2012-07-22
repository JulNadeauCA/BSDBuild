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

sub Test
{
	TryCompile 'HAVE_GETHOSTBYNAME', << 'EOF';
#include <string.h>
#include <netdb.h>

int
main(int argc, char *argv[])
{
	struct hostent *hp;
	const char *host = "localhost";

	hp = gethostbyname(host);
	return (hp == NULL);
}
EOF
}

sub Emul
{
	my ($os, $osrel, $machine) = @_;

	if ($os eq 'linux' || $os eq 'darwin' || $os =~ /^(open|net|free)bsd/) {
		MkDefine('HAVE_GETHOSTBYNAME', 'yes');
		MkSaveDefine('HAVE_GETHOSTBYNAME');
	} else {
		MkSaveUndef('HAVE_GETHOSTBYNAME');
	}
	return (1);
}

BEGIN
{
	$TESTS{'gethostbyname'} = \&Test;
	$DEPS{'gethostbyname'} = 'cc';
	$EMUL{'gethostbyname'} = \&Emul;
	$DESCR{'gethostbyname'} = 'the gethostbyname() function';
}

;1