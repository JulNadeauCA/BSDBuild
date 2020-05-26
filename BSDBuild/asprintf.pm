# Public domain

sub TEST_asprintf
{
	TryCompileFlagsC('HAVE_ASPRINTF', '-D_GNU_SOURCE', << 'EOF');
#include <stdio.h>

int
main(int argc, char *argv[])
{
	char *buf;
	if (asprintf(&buf, "foo %s", "bar") == 0) {
	    return (0);
	}
	return (1);
}
EOF
}

sub DISABLE_asprintf
{
	MkDefine('HAVE_ASPRINTF', 'no');
	MkSaveUndef('HAVE_ASPRINTF');
}

BEGIN
{
	my $n = 'asprintf';

	$DESCR{$n}   = 'asprintf()';
	$TESTS{$n}   = \&TEST_asprintf;
	$DISABLE{$n} = \&DISABLE_asprintf;
	$DEPS{$n}    = 'cc';
}
;1
