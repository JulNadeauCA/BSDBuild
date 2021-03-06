# Public domain

my $testCode = << 'EOF';
#include <mysql.h>
#include <string.h>

int
main(int argc, char *argv[])
{
	MYSQL *my = mysql_init(NULL);
	if (my != NULL) { mysql_close(my); }
	return (0);
}
EOF

sub TEST_mysql
{
	my ($ver, $pfx) = @_;
	
	MkExecOutputUnique('mysql_config', '--version', 'MYSQL_VERSION');
	MkIfFound($pfx, $ver, 'MYSQL_VERSION');
		MkPrintSN('checking whether MySQL works...');
		MkExecOutput('mysql_config', '--cflags', 'MYSQL_CFLAGS');
		MkExecOutput('mysql_config', '--libs', 'MYSQL_LIBS');
		MkCompileC('HAVE_MYSQL',
		           '${MYSQL_CFLAGS}', '${MYSQL_LIBS}', $testCode);
		MkIfFalse('${HAVE_MYSQL}');
			MkDisableFailed('mysql');
		MkEndif;
	MkElse;
		MkDisableNotFound('mysql');
	MkEndif;
}

sub DISABLE_mysql
{
	MkDefine('HAVE_MYSQL', 'no') unless $TestFailed;
	MkDefine('MYSQL_CFLAGS', '');
	MkDefine('MYSQL_LIBS', '');
	MkSaveUndef('HAVE_MYSQL');
}

BEGIN
{
	my $n = 'mysql';

	$DESCR{$n}   = 'MySQL';
	$URL{$n}     = 'http://dev.mysql.com';
	$TESTS{$n}   = \&TEST_mysql;
	$DISABLE{$n} = \&DISABLE_mysql;
	$DEPS{$n}    = 'cc';
	$SAVED{$n}   = 'MYSQL_CFLAGS MYSQL_LIBS';
}
;1
