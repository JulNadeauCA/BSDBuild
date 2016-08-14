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

sub Test
{
	my ($ver, $pfx) = @_;
	
	MkExecOutputPfx($pfx, 'curl-config', '--version', 'CURL_VERSION');

	MkIfFound($pfx, $ver, 'CURL_VERSION');
		MkPrintSN('checking whether libcurl works...');
		MkExecOutputPfx($pfx, 'curl-config', '--cflags', 'CURL_CFLAGS');
		MkExecOutputPfx($pfx, 'curl-config', '--libs', 'CURL_LIBS');
		MkCompileC('HAVE_CURL', '${CURL_CFLAGS}', '${CURL_LIBS}', << 'EOF');
#include <curl/curl.h>

int
main(int argc, char *argv[])
{
	curl_version_info_data *v;
	curl_global_init(CURL_GLOBAL_ALL);
	v = curl_version_info(CURLVERSION_NOW);
	curl_global_cleanup();
	return (0);
}
EOF
		MkSaveIfTrue('${HAVE_CURL}', 'CURL_CFLAGS', 'CURL_LIBS');
	MkElse;
		MkSaveUndef('HAVE_CURL', 'CURL_CFLAGS', 'CURL_LIBS');
	MkEndif;
	return (0);
}

BEGIN
{
	$DESCR{'curl'} = 'libcurl';
	$URL{'curl'} = 'http://curl.haxx.se';

	$TESTS{'curl'} = \&Test;
	$DEPS{'curl'} = 'cc';
}

;1
