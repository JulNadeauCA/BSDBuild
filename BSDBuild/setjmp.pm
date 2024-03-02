# Public domain

sub TEST_setjmp
{
	TryCompile '_MK_HAVE_SETJMP', << 'EOF';
#include <setjmp.h>

jmp_buf jmpbuf;

int
main(int argc, char *argv[])
{
	longjmp(jmpbuf, 1);
	setjmp(jmpbuf);
	return (0);
}
EOF
}

sub DISABLE_setjmp
{
	MkDefine('_MK_HAVE_SETJMP', 'no');
	MkSaveUndef('_MK_HAVE_SETJMP');
}

BEGIN
{
	my $n = 'setjmp';

	$DESCR{$n}   = 'setjmp() and longjmp()';
	$TESTS{$n}   = \&TEST_setjmp;
	$DISABLE{$n} = \&DISABLE_setjmp;
	$DEPS{$n}    = 'cc';
}
;1
