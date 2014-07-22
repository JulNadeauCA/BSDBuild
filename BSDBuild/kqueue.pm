# vim:ts=4
#
# Copyright (c) 2012 Hypertriton, Inc. <http://hypertriton.com/>
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
	TryCompile 'HAVE_KQUEUE', << 'EOF';
#include <sys/types.h>
#include <sys/event.h>
#include <sys/time.h>
#include <fcntl.h>
#include <unistd.h>

int
main(int argc, char *argv[])
{
	struct kevent kev, chg;
	int kq, fd = -1, nev;

	if ((kq = kqueue()) == -1) { return (1); }
#if defined(__NetBSD__)
	EV_SET(&kev, (uintptr_t)fd, EVFILT_READ, EV_ADD|EV_ENABLE|EV_ONESHOT, 0, 0, (intptr_t)NULL);
	EV_SET(&kev, (uintptr_t)1, EVFILT_TIMER, EV_ADD|EV_ENABLE, 0, 0, (intptr_t)NULL);
#else
	EV_SET(&kev, fd, EVFILT_READ, EV_ADD|EV_ENABLE|EV_ONESHOT, 0, 0, NULL);
	EV_SET(&kev, 1, EVFILT_TIMER, EV_ADD|EV_ENABLE, 0, 0, NULL);
#endif
	nev = kevent(kq, &kev, 1, &chg, 1, NULL);
	return (chg.flags & EV_ERROR);
}
EOF
}

sub Emul
{
	my ($os, $osrel, $machine) = @_;

	MkEmulUnavail('KQUEUE');
	return (1);
}

BEGIN
{
	$DESCR{'kqueue'} = 'the kqueue() mechanism';
	$DEPS{'kqueue'} = 'cc';
	$TESTS{'kqueue'} = \&Test;
	$EMUL{'kqueue'} = \&Emul;
}

;1
