# vim:ts=4
# Public domain

sub TEST_sys_queue
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
}

sub DISABLE_sys_queue
{
	MkDefine('_MK_HAVE_SYS_QUEUE_H', 'no');
	MkSaveUndef('_MK_HAVE_SYS_QUEUE_H');
}

BEGIN
{
	my $n = 'sys_queue';

	$DESCR{$n}   = 'a compatible <sys/queue.h>';
	$TESTS{$n}   = \&TEST_sys_queue;
	$DISABLE{$n} = \&DISABLE_sys_queue;
	$DEPS{$n}    = 'cc';
}
;1
