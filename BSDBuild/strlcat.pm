# vim:ts=4
# Public domain

sub TEST_strlcat
{
	TryCompile 'HAVE_STRLCAT', << 'EOF';
#include <string.h>
int
main(int argc, char *argv[])
{
	char buf[16];
	buf[0] = '\0';
	return (strlcat(buf, "hello", sizeof(buf)) >= sizeof(buf));
}
EOF
}

sub DISABLE_strlcat
{
	MkDefine('HAVE_STRLCAT', 'no');
	MkSaveUndef('HAVE_STRLCAT');
}

BEGIN
{
	my $n = 'strlcat';

	$DESCR{$n}   = 'strlcat()';
	$TESTS{$n}   = \&TEST_strlcat;
	$DISABLE{$n} = \&DISABLE_strlcat;
	$DEPS{$n}    = 'cc';
}
;1
