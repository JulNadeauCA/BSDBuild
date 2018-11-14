# Public domain
# vim:ts=4

sub Test
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
	return (0);
}

sub Emul
{
	my ($os, $osrel, $machine) = @_;

	MkEmulUnavailSYS('_MK_HAVE_UNISTD_H');
	return (1);
}

BEGIN
{
	$DESCR{'unistd_h'} = '<unistd.h>';
	$TESTS{'unistd_h'} = \&Test;
	$EMUL{'unistd_h'} = \&Emul;
	$DEPS{'unistd_h'} = 'cc';
}

;1
