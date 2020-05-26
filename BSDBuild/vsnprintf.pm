# Public domain

sub TEST_vsnprintf
{
	TryCompile 'HAVE_VSNPRINTF', << 'EOF';
#include <stdio.h>
#include <stdarg.h>

static void
testfmt(const char *fmt, ...)
{
	char buf[16];
	va_list ap;
	va_start(ap, fmt);
	(void)vsnprintf(buf, sizeof(buf), fmt, ap);
	va_end(ap);
}
int
main(int argc, char *argv[])
{
	testfmt("foo", 1, 2, 3);
	return (0);
}
EOF
}

sub DISABLE_vsnprintf
{
	MkDefine('HAVE_VSNPRINTF', 'no');
	MkSaveUndef('HAVE_VSNPRINTF');
}

BEGIN
{
	my $n = 'vsnprintf';

	$DESCR{$n}   = 'vsnprintf()';
	$TESTS{$n}   = \&TEST_vsnprintf;
	$DISABLE{$n} = \&DISABLE_vsnprintf;
	$DEPS{$n}    = 'cc';
}
;1
