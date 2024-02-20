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

sub CMAKE_mysql
{
	my $code = MkCodeCMAKE($testCode);

	return << "EOF";
macro(Check_Mysql)
	set(MYSQL_CFLAGS "")
	set(MYSQL_LIBS "")

	set(ORIG_CMAKE_REQUIRED_FLAGS \${CMAKE_REQUIRED_FLAGS})
	set(ORIG_CMAKE_REQUIRED_LIBRARIES \${CMAKE_REQUIRED_LIBRARIES})
	set(CMAKE_REQUIRED_FLAGS "\${CMAKE_REQUIRED_FLAGS} -I/usr/local/include/mysql")
	set(CMAKE_REQUIRED_LIBRARIES "\${CMAKE_REQUIRED_LIBRARIES} -L/usr/local/lib/mysql -lmysqlclient_r")

	CHECK_INCLUDE_FILE(mysql.h HAVE_MYSQL_H)
	if(HAVE_MYSQL_H)
		check_c_source_compiles("
$code" HAVE_MYSQL)
		if(HAVE_MYSQL)
			set(MYSQL_CFLAGS "-I/usr/local/include")
			set(MYSQL_LIBS "-L/usr/local/lib/mysql" "-lmysqlclient_r")
			BB_Save_Define(HAVE_MYSQL)
		else()
			BB_Save_Undef(HAVE_MYSQL)
		endif()
	else()
		set(HAVE_MYSQL OFF)
		BB_Save_Undef(HAVE_MYSQL)
	endif()

	set(CMAKE_REQUIRED_FLAGS \${ORIG_CMAKE_REQUIRED_FLAGS})
	set(CMAKE_REQUIRED_LIBRARIES \${ORIG_CMAKE_REQUIRED_LIBRARIES})

	BB_Save_MakeVar(MYSQL_CFLAGS "\${MYSQL_CFLAGS}")
	BB_Save_MakeVar(MYSQL_LIBS "\${MYSQL_LIBS}")
endmacro()

macro(Disable_Mysql)
	set(HAVE_MYSQL OFF)
	BB_Save_MakeVar(MYSQL_CFLAGS "")
	BB_Save_MakeVar(MYSQL_LIBS "")
	BB_Save_Undef(HAVE_MYSQL)
endmacro()
EOF
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
	$CMAKE{$n}   = \&CMAKE_mysql;
	$DISABLE{$n} = \&DISABLE_mysql;
	$DEPS{$n}    = 'cc';
	$SAVED{$n}   = 'MYSQL_CFLAGS MYSQL_LIBS';
}
;1
