# vim:ts=4
# Public domain

sub TEST_free_null
{
	# XXX cross-compiling
	MkCompileAndRunC('FREE_NULL_IS_A_NOOP', '', '', << 'EOF');
#include <stdlib.h>
int main(int argc, char *argv[]) {
	free(NULL);
	return (0);
}
EOF
}

sub DISABLE_free_null
{
	MkDefine('FREE_NULL_IS_A_NOOP', 'no');
	MkSaveUndef('FREE_NULL_IS_A_NOOP');
}

BEGIN
{
	my $n = 'free_null';

	$DESCR{$n}   = 'free(NULL) is noop';
	$TESTS{$n}   = \&TEST_free_null;
	$DISABLE{$n} = \&DISABLE_free_null;
	$DEPS{$n}    = 'cc';
}
;1
