# Public domain
# vim:ts=4

sub Test_Asprintf
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

sub Disable_Asprintf
{
	MkDefine('HAVE_ASPRINTF', 'no');
	MkSaveUndef('HAVE_ASPRINTF');
}

sub Emul
{
	my ($os, $osrel, $machine) = @_;

	MkEmulUnavailSYS('ASPRINTF');
	return (1);
}

BEGIN
{
	my $n = 'asprintf';

	$DESCR{$n} = 'asprintf()';
	$DEPS{$n}  = 'cc';

	$TESTS{$n}   = \&Test_Asprintf;
	$DISABLE{$n} = \&Disable_Asprintf;
	$EMUL{$n}    = \&Emul;
}

;1
