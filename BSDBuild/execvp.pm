# Public domain

sub TEST_execvp
{
	TryCompile 'HAVE_EXECVP', << 'EOF';
#include <unistd.h>

int
main(int argc, char *argv[])
{
	char *args[3] = { "foo", NULL, NULL };
	int rv;

	rv = execvp(args[0], args);
	return (rv);
}
EOF
}

sub DISABLE_execvp
{
	MkDefine('HAVE_EXECVP', 'no');
	MkSaveUndef('HAVE_EXECVP');
}

BEGIN
{
	my $n = 'execvp';

	$DESCR{$n}   = 'the execvp() function';
	$TESTS{$n}   = \&TEST_execvp;
	$DISABLE{$n} = \&DISABLE_execvp;
	$DEPS{$n}    = 'cc';
}
;1
