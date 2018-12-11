# vim:ts=4
# Public domain

sub TEST_snprintf
{
	TryCompile 'HAVE_SNPRINTF', << 'EOF';
#include <stdio.h>

int
main(int argc, char *argv[])
{
	char buf[16];
	(void)snprintf(buf, sizeof(buf), "foo");
	return (0);
}
EOF
}

sub DISABLE_snprintf
{
	MkDefine('HAVE_SNPRINTF', 'no');
	MkSaveUndef('HAVE_SNPRINTF');
}

BEGIN
{
	my $n = 'snprintf';

	$DESCR{$n}   = 'snprintf()';
	$TESTS{$n}   = \&TEST_snprintf;
	$DISABLE{$n} = \&DISABLE_snprintf;
	$DEPS{$n}    = 'cc';
}
;1
