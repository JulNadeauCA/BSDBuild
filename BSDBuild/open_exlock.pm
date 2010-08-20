# vim:ts=4
#
# Copyright (c) 2007 Hypertriton, Inc. <http://hypertriton.com/>
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
	TryCompile 'HAVE_OPEN_EXLOCK', << 'EOF';
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

int
main(int argc, char *argv[])
{
	int fd;

	fd = open("foo", O_WRONLY|O_CREAT|O_EXLOCK);
	close(fd);
	return (0);
}
EOF
}

sub Emul
{
	my ($os, $osrel, $machine) = @_;

	if ($os eq 'darwin' || $os =~ /^(open|net|free)bsd$/) {
		MkDefine('HAVE_OPEN_EXLOCK', 'yes');
		MkSaveDefine('HAVE_OPEN_EXLOCK');
	} else {
		MkSaveUndef('HAVE_OPEN_EXLOCK');
	}
	return (1);
}

BEGIN
{
	$DESCR{'open_exlock'} = 'the O_EXLOCK open() flag';
	$TESTS{'open_exlock'} = \&Test;
	$EMUL{'open_exlock'} = \&Emul;
	$DEPS{'open_exlock'} = 'cc';
}

;1
