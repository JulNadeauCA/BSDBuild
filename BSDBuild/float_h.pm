# vim:ts=4
# Public domain

sub Test
{
	MkCompileC('_MK_HAVE_FLOAT_H', '', '', << 'EOF');
#include <float.h>

int main(int argc, char *argv[]) {
	float flt = 0.0f;
	double dbl = 0.0;

	flt += FLT_EPSILON;
	dbl += DBL_EPSILON;
	return (0);
}
EOF
	return (0);
}

sub Emul
{
	my ($os, $osrel, $machine) = @_;

	if ($os eq 'linux' || $os eq 'darwin' || $os =~ /^(open|net|free)bsd$/) {
		MkDefine('_MK_HAVE_FLOAT_H', 'yes');
		MkSaveDefine('_MK_HAVE_FLOAT_H');
	} else {
		MkSaveUndef('_MK_HAVE_FLOAT_H');
	}
	return (1);
}

BEGIN
{
	$DESCR{'float_h'} = 'compatible <float.h>';
	$TESTS{'float_h'} = \&Test;
	$EMUL{'float_h'} = \&Emul;
	$DEPS{'float_h'} = 'cc';
}

;1
