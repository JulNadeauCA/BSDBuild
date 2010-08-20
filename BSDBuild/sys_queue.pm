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
	MkCompileC('_MK_HAVE_SYS_QUEUE_H', '', '', << 'EOF');
#include <sys/queue.h>
#include <stdio.h>

struct foo { TAILQ_ENTRY(foo) foos; };
struct bar { CIRCLEQ_ENTRY(bar) bars; };
TAILQ_HEAD(fooqname,foo) fooq = TAILQ_HEAD_INITIALIZER(fooq);
CIRCLEQ_HEAD(,bar) barq = CIRCLEQ_HEAD_INITIALIZER(barq);

int main(int argc, char *argv[])
{
	struct foo foo1;
	struct bar bar1;
	struct foo *pfoo, *pfoo_next;
	struct bar *pbar;
	
	TAILQ_INIT(&fooq);
	TAILQ_INSERT_HEAD(&fooq, &foo1, foos);
	TAILQ_FOREACH(pfoo, &fooq, foos) { }
	TAILQ_FOREACH_REVERSE(pfoo, &fooq, fooqname, foos) { }
	for (pfoo = TAILQ_FIRST(&fooq);
	     pfoo != TAILQ_END(&fooq);
		 pfoo = pfoo_next) {
		pfoo_next = TAILQ_NEXT(pfoo,foos);
	}
	TAILQ_REMOVE(&fooq, &foo1, foos);

	CIRCLEQ_INIT(&barq);
	CIRCLEQ_INSERT_HEAD(&barq, &bar1, bars);
	CIRCLEQ_FOREACH(pbar, &barq, bars) { }
	CIRCLEQ_REMOVE(&barq, &bar1, bars);

	return (0);
}
EOF
	return (0);
}

sub Emul
{
	my ($os, $osrel, $machine) = @_;

	if ($os eq 'openbsd' || $os eq 'fabbsd') {
		MkDefine('_MK_HAVE_SYS_QUEUE_H', 'yes');
		MkSaveDefine('_MK_HAVE_SYS_QUEUE_H');
	} else {
		MkSaveUndef('_MK_HAVE_SYS_QUEUE_H');
	}
	return (1);
}

BEGIN
{
	$DESCR{'sys_queue'} = 'a compatible <sys/queue.h>';
	$TESTS{'sys_queue'} = \&Test;
	$EMUL{'sys_queue'} = \&Emul;
	$DEPS{'sys_queue'} = 'cc';
}

;1
