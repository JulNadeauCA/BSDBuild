# Public domain

my $testCode = << 'EOF';
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

sub TEST_kqueue
{
	TryCompile('HAVE_KQUEUE', $testCode);
}

sub CMAKE_kqueue
{
	my $code = MkCodeCMAKE($testCode);

	return << "EOF";
macro(Check_Kqueue)
	check_c_source_compiles("
$code" HAVE_KQUEUE)
	if (HAVE_KQUEUE)
		BB_Save_Define(HAVE_KQUEUE)
	else()
		BB_Save_Undef(HAVE_KQUEUE)
	endif()
endmacro()
EOF
}

sub DISABLE_kqueue
{
	MkDefine('HAVE_KQUEUE', 'no');
	MkSaveUndef('HAVE_KQUEUE');
}

BEGIN
{
	my $n = 'kqueue';

	$DESCR{$n}   = 'the kqueue() mechanism';
	$TESTS{$n}   = \&TEST_kqueue;
	$CMAKE{$n}   = \&CMAKE_kqueue;
	$DISABLE{$n} = \&DISABLE_kqueue;
	$DEPS{$n}    = 'cc';
}
;1
