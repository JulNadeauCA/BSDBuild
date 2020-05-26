# Public domain

sub TEST_strlcpy
{
	TryCompile 'HAVE_STRLCPY', << 'EOF';
#include <string.h>
int
main(int argc, char *argv[])
{
	char buf[16];
	return (strlcpy(buf, "hello", sizeof(buf)) >= sizeof(buf));
}
EOF
}

sub DISABLE_strlcpy
{
	MkDefine('HAVE_STRLCPY', 'no');
	MkSaveUndef('HAVE_STRLCPY');
}

BEGIN
{
	my $n = 'strlcpy';

	$DESCR{$n}   = 'strlcpy()';
	$TESTS{$n}   = \&TEST_strlcpy;
	$DISABLE{$n} = \&DISABLE_strlcpy;
	$DEPS{$n}    = 'cc';
}
;1
