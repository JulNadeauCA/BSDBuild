# vim:ts=4
#
# Copyright (c) 2008 Hypertriton, Inc. <http://hypertriton.com/>
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
#include <libpercgi/cgi.h>

int
main(int argc, char *argv[])
{
	CGI_Init(NULL);
	return (0);
}
EOF

sub Test
{
	my ($ver, $pfx) = @_;
	
	MkExecOutputPfx($pfx, 'percgi-config', '--version', 'PERCGI_VERSION');
	MkIfNE('${PERCGI_VERSION}', '');
		MkFoundVer($pfx, $ver, 'PERCGI_VERSION');
		MkExecOutputPfx($pfx, 'percgi-config', '--cflags', 'PERCGI_CFLAGS');
		MkExecOutputPfx($pfx, 'percgi-config', '--libs', 'PERCGI_LIBS');
		MkPrintN('checking whether PerCGI works...');
		MkCompileC('HAVE_PERCGI',
		           '${PERCGI_CFLAGS}', '${PERCGI_LIBS}',
				   $testCode);
        MkSaveIfTrue('${HAVE_PERCGI}', 'PERCGI_CFLAGS', 'PERCGI_LIBS');
	MkElse;
		MkNotFound($pfx);
	    MkSaveUndef('HAVE_PERCGI', 'PERCGI_CFLAGS', 'PERCGI_LIBS');
	MkEndif;
	return (0);
}

BEGIN
{
	$TESTS{'percgi'} = \&Test;
	$DEPS{'percgi'} = 'cc';
	$DESCR{'percgi'} = 'PerCGI (http://percgi.org/)';
}

;1
