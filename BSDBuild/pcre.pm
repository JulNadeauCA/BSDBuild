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

my $testCode = << 'EOF';
#include <stdio.h>
#include <string.h>
#include <pcre.h>

int
main(int argc, char *argv[])
{
	pcre *re;
	const char *error;
	int eo, rc;
	int ovector[30];

	if (!(re = pcre_compile("(.*)(subject)+", PCRE_CASELESS, &error, &eo, NULL))) {
		rc = pcre_exec(re, NULL, "Subject", strlen("subject"), 0, 0, ovector, 30);
		pcre_free(re);
		return (0);
	}
	return (1);
}
EOF

sub Test
{
	my ($ver, $pfx) = @_;
	
	MkExecOutputPfx($pfx, 'pcre-config', '--version', 'PCRE_VERSION');
	MkExecOutputPfx($pfx, 'pcre-config', '--cflags', 'PCRE_CFLAGS');
	MkExecOutputPfx($pfx, 'pcre-config', '--libs', 'PCRE_LIBS');

	MkIfFound($pfx, $ver, 'PCRE_VERSION');
		MkPrintSN('checking whether PCRE works...');
		MkCompileC('HAVE_PCRE', '${PCRE_CFLAGS}', '${PCRE_LIBS}', $testCode);
		MkSaveIfTrue('${HAVE_PCRE}', 'PCRE_CFLAGS', 'PCRE_LIBS');
	MkElse;
		MkSaveUndef('HAVE_PCRE');
	MkEndif;
	return (0);
}

BEGIN
{
	$DESCR{'pcre'} = 'PCRE library';
	$URL{'pcre'} = 'http://www.pcre.org';

	$TESTS{'pcre'} = \&Test;
	$DEPS{'pcre'} = 'cc';
}

;1
