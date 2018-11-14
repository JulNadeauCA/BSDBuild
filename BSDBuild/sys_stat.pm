# vim:ts=4

sub Test
{
	MkCompileC('_MK_HAVE_SYS_STAT_H', '', '', << 'EOF');
#include <sys/types.h>
#include <sys/stat.h>
int main(int argc, char *argv[]) {
	struct stat sb;
	uid_t uid;
	if (stat("/tmp/foo", &sb) != 0) { return (1); }
	return ((uid = sb.st_uid) == (uid_t)0);
}
EOF
	return (0);
}

sub Disable
{
	MkSaveUndef('_MK_HAVE_SYS_STAT_H');
}

BEGIN
{
	my $n = 'sys_stat';

	$DESCR{$n}   = '<sys/stat.h>';
	$TESTS{$n}   = \&Test;
	$DISABLE{$n} = \&Disable;

	$DEPS{$n}  = 'cc';
}

;1
