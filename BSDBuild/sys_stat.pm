# vim:ts=4
# Public domain

sub TEST_sys_stat
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
}

sub DISABLE_sys_stat
{
	MkDefine('_MK_HAVE_SYS_STAT_H', 'no');
	MkSaveUndef('_MK_HAVE_SYS_STAT_H');
}

BEGIN
{
	my $n = 'sys_stat';

	$DESCR{$n}   = '<sys/stat.h>';
	$TESTS{$n}   = \&TEST_sys_stat;
	$DISABLE{$n} = \&DISABLE_sys_stat;
	$DEPS{$n}    = 'cc';
}
;1
