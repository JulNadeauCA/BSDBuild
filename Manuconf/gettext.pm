# $Csoft: gettext.pm,v 1.3 2003/07/26 20:42:51 vedge Exp $
# vim:ts=4
#
# Copyright (c) 2003 CubeSoft Communications, Inc.
# <http://www.csoft.org>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistribution of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Neither the name of CubeSoft Communications, nor the names of its
#    contributors may be used to endorse or promote products derived from
#    this software without specific prior written permission.
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
	# XXX
	print Define('GETTEXT_CFLAGS', '-I/usr/local/include');
	print Define('GETTEXT_LIBS', '"-L/usr/local/lib -lintl"');
	print Echo("ok");

	print NEcho('checking whether gettext works...');
	TryLibCompile 'HAVE_GETTEXT', '${GETTEXT_CFLAGS}',
	    '${GETTEXT_LIBS}', << 'EOF';
#include <libintl.h>

int
main(int argc, char *argv[])
{
	gettext("");
	return (0);
}
EOF
	
	print
		Cond('"${HAVE_GETTEXT}" != ""',
		MKSave('GETTEXT_CFLAGS') .
		MKSave('GETTEXT_LIBS') .
		MKSave('HAVE_GETTEXT'),
		Nothing());
}

BEGIN
{
	$TESTS{'gettext'} = \&Test;
	$DESCR{'gettext'} = 'a gettext library';
}

;1