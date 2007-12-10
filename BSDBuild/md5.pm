# $Csoft: snprintf.pm,v 1.3 2004/01/03 04:13:29 vedge Exp $
# vim:ts=4
#
# Copyright (c) 2005 CubeSoft Communications, Inc.
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
	TryCompile 'HAVE_MD5', << 'EOF';
#include <sys/types.h>
#include <md5.h>

int
main(int argc, char *argv[])
{
	MD5_CTX md5;

	MD5Init(&md5);
	return (0);
}
EOF
}

sub Emul
{
	my ($os, $osrel, $machine) = @_;

	if ($os eq 'openbsd') {
		MkDefine('HAVE_MD5', 'yes');
		MkSaveDefine('HAVE_MD5');
	} else {
		MkSaveUndef('HAVE_MD5');
	}
	return (1);
}

BEGIN
{
	$DESCR{'md5'} = 'MD5 functions';
	$TESTS{'md5'} = \&Test;
	$EMUL{'md5'} = \&Emul;
	$DEPS{'md5'} = 'cc';
}

;1
