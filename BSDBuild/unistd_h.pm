# $Csoft: opengl.pm,v 1.5 2004/03/10 16:33:36 vedge Exp $
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
	MkCompileC('_MK_HAVE_UNISTD_H', '', '', << 'EOF');
#include <unistd.h>
#include <sys/types.h>
int main(int argc, char *argv[]) {
	uid_t uid = 0;
	pid_t pid = 0;

	uid = getuid();
	pid = getpid();
	return (0);
}
EOF
	return (0);
}

sub Emul
{
	my ($os, $osrel, $machine) = @_;

	if ($os eq 'linux' || $os eq 'darwin' || $os =~ /^(open|net|free)bsd$/) {
		MkDefine('_MK_HAVE_UNISTD_H', 'yes');
		MkSaveDefine('_MK_HAVE_UNISTD_H');
	} else {
		MkSaveUndef('_MK_HAVE_UNISTD_H');
	}
	return (1);
}

BEGIN
{
	$DESCR{'unistd_h'} = '<unistd.h>';
	$TESTS{'unistd_h'} = \&Test;
	$EMUL{'unistd_h'} = \&Emul;
	$DEPS{'unistd_h'} = 'cc';
}

;1
