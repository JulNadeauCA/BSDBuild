# vim:ts=4
# Public domain

my @db5_releases = ('5.0', '5.1', '5.2', '5.3', '5');

my $testCode = << 'EOF';
#include <db5/db.h>
#if DB_VERSION_MAJOR != 5
#error version
#endif
int main(int argc, char *argv[]) {
	DB *db;
	db_create(&db, NULL, 0);
	return (0);
}
EOF

sub Test_DB5
{
	my ($ver, $pfx) = @_;
	
	MkSetS('DB5_CFLAGS', '');
	MkSetS('DB5_LIBS', '');
	MkSetS('DB5_VERSION', '');
	MkSetS('DB5_VERSION_J', '');

	MkFor('path', $pfx.' /usr/local /usr /opt');
		MkFor('dbver', join(' ',@db5_releases));
			MkSetExec('DB5_VERSION_J', 'echo "${dbver}" | sed "s/\.//"');
			MkIfExists('${path}/lib/db5/libdb-$dbver.so');
				MkIfExists('${path}/include/db${DB5_VERSION_J}');
					MkSetS('DB5_CFLAGS', '-I${path}/include/db${DB5_VERSION_J} '.
  					                     '-I${path}/include');			# XXX
				MkElse;
					MkSetS('DB5_CFLAGS', '-I${path}/include/db5 '.
  					                     '-I${path}/include');			# XXX
				MkEndif;
				MkSetS('DB5_LIBS', '-L${path}/lib/db5 -ldb-$dbver');
				MkSetS('DB5_VERSION', '${dbver}');
				MkBreak;
			MkEndif;
		MkDone;
	MkDone;

	MkIfFound($pfx, $ver, 'DB5_VERSION');
		MkPrintSN('checking whether DB5 works...');
		MkCompileC('HAVE_DB5', '${DB5_CFLAGS}', '${DB5_LIBS}', $testCode);
		MkSaveIfTrue('${HAVE_DB5}', 'DB5_CFLAGS', 'DB5_LIBS');
	MkElse;
		MkPrint('no');
		Disable_DB5();
	MkEndif;
	return (0);
}

sub Disable_DB5
{
	MkSetS('HAVE_DB5', 'no');
	MkSetS('DB5_CFLAGS', '');
	MkSetS('DB5_LIBS', '');
	MkSaveUndef('HAVE_DB5', 'DB5_CFLAGS', 'DB5_LIBS');
}

BEGIN
{
	my $n = 'db5';

	$DESCR{$n}   = 'Berkeley DB 5.x';
	$URL{$n}     = 'http://www.oracle.com/technology/products/berkeley-db';
	$TESTS{$n}   = \&Test_DB5;
	$DISABLE{$n} = \&Disable_DB5;
	$DEPS{$n}    = 'cc';
}
;1
