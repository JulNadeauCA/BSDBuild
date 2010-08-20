# vim:ts=4
#
# Copyright (c) 2002-2004 Hypertriton, Inc. <http://hypertriton.com/>
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
	TryCompile 'HAVE_SETENV', << 'EOF';
#include <stdlib.h>
int
main(int argc, char *argv[])
{
	(void)setenv("BSDBUILD_SETENV_TEST", "foo", 1);
	unsetenv("BSDBUILD_SETENV_TEST");

	return (0);
}
EOF
}

sub Emul
{
	my ($os, $osrel, $machine) = @_;

	if ($os eq 'linux' || $os eq 'darwin' || $os eq 'windows' ||
	    $os =~ /^(open|net|free)bsd$/) {
		MkDefine('HAVE_SETENV', 'yes');
		MkSaveDefine('HAVE_SETENV');
	} else {
		MkSaveUndef('HAVE_SETENV');
	}
	return (1);
}

BEGIN
{
	$DESCR{'setenv'} = 'setenv() and unsetenv()';
	$TESTS{'setenv'} = \&Test;
	$EMUL{'setenv'} = \&Emul;
	$DEPS{'setenv'} = 'cc';
}

;1
