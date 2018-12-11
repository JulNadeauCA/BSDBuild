# vim:ts=4
# Public domain

sub TEST_stdlib_h
{
	MkCompileC('_MK_HAVE_STDLIB_H', '', '', << 'EOF');
#include <stdlib.h>
int main(int argc, char *argv[]) {
	void *foo = malloc(1);
	free(foo);
	return (0);
}
EOF
}

sub DISABLE_stdlib_h
{
	MkDefine('_MK_HAVE_STDLIB_H', 'no');
	MkSaveUndef('_MK_HAVE_STDLIB_H');
}

sub EMUL_stdlib_h
{
	my ($os, $osrel, $machine) = @_;
	
	if ($os =~ /^windows/) {
		MkEmulWindowsSYS('_MK_HAVE_STDLIB_H');
	} else {
		MkEmulUnavailSYS('_MK_HAVE_STDLIB_H');
	}
	return (1);
}

BEGIN
{
	my $n = 'stdlib_h';

	$DESCR{$n}   = '<stdlib.h>';
	$TESTS{$n}   = \&TEST_stdlib_h;
	$DISABLE{$n} = \&DISABLE_stdlib_h;
	$EMUL{$n}    = \&EMUL_stdlib_h;
	$DEPS{$n}    = 'cc';
}
;1
