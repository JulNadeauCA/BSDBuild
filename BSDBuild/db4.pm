# Public domain
# vim:ts=4

my @db4_releases = ('4.8', '4.7', '4.6', '4.5', '4.4', '4.3', '4.2', '4');

my $testCode = << 'EOF';
#include <db.h>
#if DB_VERSION_MAJOR != 4
#error version
#endif
int main(int argc, char *argv[]) {
	DB *db;
	db_create(&db, NULL, 0);
	return (0);
}
EOF

sub TEST_db4
{
	my ($ver, $pfx) = @_;

	MkSetS('DB4_CFLAGS', '');
	MkSetS('DB4_LIBS', '');
	MkSetS('DB4_VERSION', '');
	MkSetS('DB4_VERSION_J', '');

	MkFor('path', $pfx.' /usr/local /usr /opt');
		MkFor('dbver', join(' ',@db4_releases));
			MkSetExec('DB4_VERSION_J', 'echo "${dbver}" | sed "s/\.//"');
			MkIfExists('${path}/include/db$dbver');
				MkSetS('DB4_CFLAGS', '-I${path}/include/db${dbver} '.
  				                     '-I${path}/include');			# XXX
				MkSetS('DB4_VERSION', '${dbver}');
				MkBreak;
			MkElse;
				MkIfExists('${path}/include/db${DB4_VERSION_J}');
					MkSetS('DB4_CFLAGS', '-I${path}/include/db${DB4_VERSION_J} '.
					                     '-I${path}/include');			# XXX
					MkSetS('DB4_VERSION', '${dbver}');
					MkBreak;
				MkEndif;
			MkEndif;
		MkDone;
	MkDone;

	MkIfFound($pfx, $ver, 'DB4_VERSION');
		MkIfExists('${path}/lib/db${DB4_VERSION_J}');
			MkSetS('DB4_LIBS', '-L${path}/lib/db${DB4_VERSION_J} -ldb');
		MkElse;
			MkSetS('DB4_LIBS', '-L${path}/lib -ldb-${DB4_VERSION}');
		MkEndif;

		MkPrintSN('checking whether DB4 works...');
		MkCompileC('HAVE_DB4', '${DB4_CFLAGS}', '${DB4_LIBS}', $testCode);
		MkSave('DB4_CFLAGS', 'DB4_LIBS');
	MkElse;
		DISABLE_db4();
	MkEndif;
}

sub DISABLE_db4
{
	MkSetS('HAVE_DB4', 'no');
	MkSetS('DB4_CFLAGS', '');
	MkSetS('DB4_LIBS', '');
	MkSaveUndef('HAVE_DB4');
}

BEGIN
{
	my $n = 'db4';

	$DESCR{$n}   = 'Berkeley DB 4.x';
	$URL{$n}     = 'http://www.oracle.com/technology/products/berkeley-db';
	$TESTS{$n}   = \&TEST_db4;
	$DISABLE{$n} = \&DISABLE_db4;
	$DEPS{$n}    = 'cc';
}
;1
