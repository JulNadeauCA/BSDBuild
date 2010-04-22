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
	
	MkExecOutput('mgid-config', '--version', 'MGID_VERSION');
	MkExecOutput('mgid-config', '--cflags', 'MGID_CFLAGS');
	MkExecOutput('mgid-config', '--libs', 'MGID_LIBS');

	MkIf('"${MGID_VERSION}" != ""');
		MkPrint('yes, found ${MGID_VERSION}');
		MkTestVersion('MGID_VERSION', $ver);

		MkPrintN('checking whether libmgid works...');
		MkCompileC('HAVE_MGID', '${MGID_CFLAGS}', '${MGID_LIBS}',
	               << 'EOF');
#include <mgid/mgid.h>
int main(int argc, char *argv[]) {
	int rv;
	rv = MGI_Init(0);
	MGI_Destroy();
	return (0);
}
EOF
		MkIf('"${HAVE_MGID}" != "no"');
			MkSaveDefine('MGID_CFLAGS', 'MGID_LIBS');
			MkSaveMK	('MGID_CFLAGS', 'MGID_LIBS');
		MkEndif;
	MkElse;
		MkPrint('no');
		MkSaveUndef('HAVE_MGID');
	MkEndif;
	return (0);
}

BEGIN
{
	$DESCR{'mgid'} = 'libmgid (http://mgid.hypertriton.com/)';
	$DEPS{'mgid'} = 'cc';
	$TESTS{'mgid'} = \&Test;
}
;1
