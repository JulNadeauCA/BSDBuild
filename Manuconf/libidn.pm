# $Csoft: glib.pm,v 1.9 2003/10/01 09:24:19 vedge Exp $
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
	my ($ver) = @_;
	
	print ReadOut('pkg-config', 'libidn --version', 'libidn_version');
	print ReadOut('pkg-config', 'libidn --cflags', 'LIBIDN_CFLAGS');
	print ReadOut('pkg-config', 'libidn --libs', 'LIBIDN_LIBS');

	MkIf('"${libidn_version}" != ""');
		MkPrint('yes');
		MkPrintN('checking whether libidn works...');
		MkCompileC('HAVE_LIBIDN', '${LIBIDN_CFLAGS}', '${LIBIDN_LIBS}',
		           << 'EOF');
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stringprep.h>
#include <idna.h>

int main(int argc, char *argv[]) {
	char *buf = "foo.com", *p;
	int rv;

	rv = idna_to_unicode_lzlz(buf, &p, 0);
	return ((rv == IDNA_SUCCESS) ? 0 : 1);
}
EOF
		MkIf('"${HAVE_LIBIDN}" != ""');
			MkSaveMK('LIBIDN_CFLAGS', 'LIBIDN_LIBS');
			MkSaveDefine('LIBIDN_CFLAGS', 'LIBIDN_LIBS');
		MkEndif;
	MkElse;
		MkPrint('no');
		MkSaveUndef('HAVE_LIBIDN');
	MkEndif;
	return (0);
}

BEGIN
{
	$TESTS{'libidn'} = \&Test;
	$DESCR{'libidn'} = 'Libidn (http://www.gnu.org/software/libidn/)';
}

;1
