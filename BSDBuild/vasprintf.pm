# Public domain

sub TEST_vasprintf
{
	TryCompileFlagsC('HAVE_VASPRINTF', '-D_GNU_SOURCE', << 'EOF');
#include <stdio.h>
#include <stdarg.h>

int
testprintf(const char *fmt, ...)
{
	va_list args;
	char *buf;

	va_start(args, fmt);
	if (vasprintf(&buf, "%s", args) == -1) {
		return (-1);
	}
	va_end(args);
	return (0);
}
int
main(int argc, char *argv[])
{
	return (testprintf("foo %s", "bar"));
}
EOF
}

sub DISABLE_vasprintf
{
	MkDefine('HAVE_VASPRINTF', 'no');
	MkSaveUndef('HAVE_VASPRINTF');
}

BEGIN
{
	my $n = 'vasprintf';

	$DESCR{$n}   = 'vasprintf()';
	$TESTS{$n}   = \&TEST_vasprintf;
	$DISABLE{$n} = \&DISABLE_vasprintf;
	$DEPS{$n}    = 'cc';
}
;1
