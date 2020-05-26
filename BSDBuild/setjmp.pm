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

sub EMUL_setjmp
{
	my ($os, $osrel, $machine) = @_;

	if ($os =~ /^windows/) {
		MkDefine('_MK_HAVE_SETJMP', 'yes');
		MkSaveDefine('_MK_HAVE_SETJMP');
	} else {
		MkSaveUndef('_MK_HAVE_SETJMP');
	}
	return (1);
}

BEGIN
{
	my $n = 'setjmp';

	$DESCR{$n}   = 'setjmp() and longjmp()';
	$TESTS{$n}   = \&TEST_setjmp;
	$DISABLE{$n} = \&DISABLE_setjmp;
	$EMUL{$n}    = \&EMUL_setjmp;
	$DEPS{$n}    = 'cc';
}
;1
