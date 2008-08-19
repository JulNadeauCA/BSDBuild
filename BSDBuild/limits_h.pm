# vim:ts=4
# Public domain

sub Test
{
	MkCompileC('_MK_HAVE_LIMITS_H', '', '', << 'EOF');
#include <limits.h>

int main(int argc, char *argv[]) {
	int i;
	unsigned u;
	long l;
	unsigned long ul;

	i = INT_MIN;	i = INT_MAX;	u = UINT_MAX;
	l = LONG_MIN;	l = LONG_MAX;	ul = ULONG_MAX;
	return (0);
}
EOF
	return (0);
}

sub Emul
{
	my ($os, $osrel, $machine) = @_;

	if ($os eq 'linux' || $os eq 'darwin' || $os eq 'windows' ||
	    $os =~ /^(open|net|free)bsd$/) {
		MkDefine('_MK_HAVE_LIMITS_H', 'yes');
		MkSaveDefine('_MK_HAVE_LIMITS_H');
	} else {
		MkSaveUndef('_MK_HAVE_LIMITS_H');
	}
	return (1);
}

BEGIN
{
	$DESCR{'limits_h'} = 'compatible <limits.h>';
	$TESTS{'limits_h'} = \&Test;
	$EMUL{'limits_h'} = \&Emul;
	$DEPS{'limits_h'} = 'cc';
}

;1
