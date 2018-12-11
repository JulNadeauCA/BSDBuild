# vim:ts=4
# Public domain

sub TEST_unistd_h
{
	MkCompileC('_MK_HAVE_UNISTD_H', '', '', << 'EOF');
#include <sys/types.h>
#include <unistd.h>
int main(int argc, char *argv[]) {
	char buf;
	int rv, fdout=1;

	if ((rv = write(fdout, (void *)&buf, 1)) < 1) { return (1); }
	if ((rv = read(0, (void *)&buf, 1)) < 1) { return (1); }
	if (unlink("/tmp/foo") != 0) { return (1); }
	return (0);
}
EOF
}

sub DISABLE_unistd_h
{
	MkDefine('_MK_HAVE_UNISTD_H', 'no');
	MkSaveUndef('_MK_HAVE_UNISTD_H');
}

BEGIN
{
	my $n = 'unistd_h';

	$DESCR{$n}   = '<unistd.h>';
	$TESTS{$n}   = \&TEST_unistd_h;
	$DISABLE{$n} = \&DISABLE_unistd_h;
	$DEPS{$n}    = 'cc';
}
;1
