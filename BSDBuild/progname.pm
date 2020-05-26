# Public domain

sub TEST_progname
{
	TryCompile 'HAVE_PROGNAME', << 'EOF';
#include <string.h>
int
main(int argc, char *argv[])
{
	extern char *__progname;
	return strcmp(__progname, "foo");
}
EOF
}

sub DISABLE_progname
{
	MkDefine('HAVE_PROGNAME', 'no');
	MkSaveUndef('HAVE_PROGNAME');
}

BEGIN
{
	my $n = 'progname';

	$DESCR{$n}   = '__progname';
	$TESTS{$n}   = \&TEST_progname;
	$DISABLE{$n} = \&DISABLE_progname;
	$DEPS{$n}    = 'cc';
}
;1
