# vim:ts=4
#
# Copyright (c) 2010 Hypertriton, Inc. <http://hypertriton.com/>
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
	
	MkExecOutput('pkg-config', 'sndfile --version', 'SNDFILE_VERSION');
	MkExecOutput('pkg-config', 'sndfile --cflags', 'SNDFILE_CFLAGS');
	MkExecOutput('pkg-config', 'sndfile --libs', 'SNDFILE_LIBS');
	
	MkIf('"${SNDFILE_VERSION}" != ""');
		MkPrint('yes, found ${SNDFILE_VERSION}');
		MkTestVersion('SNDFILE_VERSION', $ver);

		MkPrintN('checking whether libsndfile works...');
		MkCompileC('HAVE_SNDFILE', '${SNDFILE_CFLAGS}', '${SNDFILE_LIBS}', << 'EOF');
#include <stdio.h>
#include <sndfile.h>

int main(int argc, char *argv[]) {
	SNDFILE *sf;
	SF_INFO sfi;

	sfi.format = 0;
	sf = sf_open("foo", 0, &sfi);
	sf_close(sf);
	return (0);
}
EOF
		MkIf('"${HAVE_SNDFILE}" != "no"');
			MkSaveMK('SNDFILE_CFLAGS', 'SNDFILE_LIBS');
			MkSaveDefine('SNDFILE_CFLAGS', 'SNDFILE_LIBS');
		MkEndif;
	MkElse;
		MkPrint('no');
		MkSaveUndef('HAVE_SNDFILE');
	MkEndif;
	return (0);
}

BEGIN
{
	$DESCR{'sndfile'} = 'libsndfile (http://www.mega-nerd.com/libsndfile/)';
	$TESTS{'sndfile'} = \&Test;
	$DEPS{'sndfile'} = 'cc';
}

;1