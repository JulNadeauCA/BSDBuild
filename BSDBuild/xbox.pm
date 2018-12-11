# vim:ts=4
# Public domain

sub TEST_xbox
{
	TryCompile 'HAVE_XBOX', << 'EOF'
#include <xtl.h>
#ifndef _XBOX
# error undefined
#endif
int
main(int argc, char *argv[])
{
	return (0);
}
EOF
}

sub DISABLE_xbox
{
	MkDefine('HAVE_XBOX', 'no');
	MkSaveUndef('HAVE_XBOX');
}

BEGIN
{
	my $n = 'xbox';

	$DESCR{$n}   = 'the Xbox XDK';
	$TESTS{$n}   = \&TEST_xbox;
	$DISABLE{$n} = \&DISABLE_xbox;
	$DEPS{$n}    = 'cc';
}
;1
