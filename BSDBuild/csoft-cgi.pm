# $Csoft: agar.pm,v 1.6 2004/08/30 04:54:06 vedge Exp $
# vim:ts=4
#
# Copyright (c) 2004 CubeSoft Communications, Inc.
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
	my ($ver) = @_;
	
	MkExecOutput('cgi-config', '--version', 'CGI_VERSION');

	MkIf('"${CGI_VERSION}" != ""');
		MkPrint('yes');
		MkTestVersion('Csoft-CGI', 'CGI_VERSION', $ver);
		MkExecOutput('cgi-config', '--cflags', 'CGI_CFLAGS');
		MkExecOutput('cgi-config', '--libs', 'CGI_LIBS');
        MkSaveMK('CGI_CFLAGS', 'CGI_LIBS');
        MkSaveDefine('CGI_CFLAGS', 'CGI_LIBS');

		MkPrintN('checking whether csoft-cgi works...');
		MkCompileC('HAVE_CGI', '${CGI_CFLAGS}', '${CGI_LIBS}', << 'EOF');
#include <libcgi/cgi.h>

int
main(int argc, char *argv[])
{
	CGI_Init(NULL);
	return (0);
}
EOF
	MkElse;
		MkPrint('no');
	    MkSaveUndef('HAVE_CGI', 'CGI_CFLAGS', 'CGI_LIBS');
	MkEndif;
	return (0);
}

BEGIN
{
	$TESTS{'csoft-cgi'} = \&Test;
	$DEPS{'csoft-cgi'} = 'cc';
	$DESCR{'csoft-cgi'} = 'csoft-cgi (http://hypertriton.com/csoft-cgi/)';
}

;1
