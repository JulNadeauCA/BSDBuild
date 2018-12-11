# vim:ts=4
# Public domain

sub TEST_getenv
{
	TryCompile 'HAVE_GETENV', << 'EOF';
#include <stdlib.h>
int
main(int argc, char *argv[])
{
	(void)getenv("PATH");
	return (0);
}
EOF
}

sub DISABLE_getenv
{
	MkDefine('HAVE_GETENV', 'no');
	MkSaveUndef('HAVE_GETENV');
}

sub EMUL_getenv
{
	my ($os, $osrel, $machine) = @_;

	if ($os =~ /^windows/) {
		MkEmulWindows('GETENV', '');
	} else {
		MkEmulUnavail('GETENV');
	}
	return (1);
}

BEGIN
{
	my $n = 'getenv';

	$DESCR{$n}   = 'getenv()';
	$TESTS{$n}   = \&TEST_getenv;
	$DISABLE{$n} = \&DISABLE_getenv;
	$EMUL{$n}    = \&EMUL_getenv;
	$DEPS{$n}    = 'cc';
}
;1
