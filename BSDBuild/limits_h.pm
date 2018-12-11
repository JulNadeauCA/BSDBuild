# vim:ts=4
# Public domain

sub TEST_limits_h
{
	MkCompileC('_MK_HAVE_LIMITS_H', '', '', << 'EOF');
#include <limits.h>

int main(int argc, char *argv[]) {
	int i = INT_MIN;
	unsigned u = 0;
	long l = LONG_MIN;
	unsigned long ul = 0;
	i = INT_MAX;
	u = UINT_MAX;
	l = LONG_MAX;
	ul = ULONG_MAX;
	return (i != INT_MAX || u != UINT_MAX || l != LONG_MAX || ul != LONG_MAX);
}
EOF
}

sub DISABLE_limits_h
{
	MkDefine('_MK_HAVE_LIMITS_H', 'no');
	MkSaveUndef('_MK_HAVE_LIMITS_H');
}

sub EMUL_limits_h
{
	my ($os, $osrel, $machine) = @_;
	
	if ($os =~ /^windows/) {
		MkDefine('_MK_HAVE_LIMITS_H', 'yes');
		MkSaveDefine('_MK_HAVE_LIMITS_H');
	} else {
		MkSaveUndef('_MK_HAVE_LIMITS_H');
	}
	return (1);
}

BEGIN
{
	my $n = 'limits_h';

	$DESCR{$n}   = 'compatible <limits.h>';
	$TESTS{$n}   = \&TEST_limits_h;
	$DISABLE{$n} = \&DISABLE_limits_h;
	$EMUL{$n}    = \&EMUL_limits_h;
	$DEPS{$n}    = 'cc';
}
;1
