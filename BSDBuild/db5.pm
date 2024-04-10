# Public domain

my @db5_releases = ('5.0', '5.1', '5.2', '5.3', '5');

my $testCode = << 'EOF';
#ifdef DB5_HAVE_INCLUDES_IN_DB4
# include <db4/db.h>
#else
# include <db5/db.h>
# if DB_VERSION_MAJOR != 5
#  error version
# endif
#endif
int main(int argc, char *argv[]) {
	DB *db;
	db_create(&db, NULL, 0);
	return (0);
}
EOF

sub TEST_db5
{
	my ($ver, $pfx) = @_;
	
	MkDefine('DB5_CFLAGS', '');
	MkDefine('DB5_LIBS', '');
	MkDefine('DB5_VERSION', '');
	MkDefine('DB5_VERSION_J', '');

	MkFor('path', $pfx.' /usr/local /usr /opt');
		MkFor('dbver', join(' ',@db5_releases));
			MkSetExec('DB5_VERSION_J', 'echo "${dbver}" | sed "s/\.//"');
			MkIfExists('${path}/lib/db5/libdb-$dbver.so');
				MkIfExists('${path}/include/db${DB5_VERSION_J}');
					MkDefine('DB5_CFLAGS', '-I${path}/include/db${DB5_VERSION_J} ' .
  					                       '-I${path}/include');			# XXX
				MkElse;
					MkDefine('DB5_CFLAGS', '-I${path}/include/db5 ' .
  					                       '-I${path}/include');			# XXX
				MkEndif;
				MkDefine('DB5_LIBS', '-L${path}/lib/db5 -ldb-$dbver');
				MkDefine('DB5_VERSION', '${dbver}');
				MkBreak;
			MkElse;
				#
				# Handle platforms that have DB5 installed with libraries and includes under db4/.
				#
				MkIfExists('${path}/lib/db4/libdb.so.5.0');
					MkIfExists('${path}/include/db4');
						MkDefine('DB5_CFLAGS', '-DDB5_HAVE_INCLUDES_IN_DB4 ' .
						                       '-I${path}/include/db4 ' .
  						                       '-I${path}/include');
					MkElse;
						MkDefine('DB5_CFLAGS', '-I${path}/include');
					MkEndif;
					MkDefine('DB5_LIBS', '-L${path}/lib/db4 -ldb');
					MkDefine('DB5_VERSION', '5');
					MkBreak;
				MkEndif;
			MkEndif;
		MkDone;
	MkDone;

	MkIfFound($pfx, $ver, 'DB5_VERSION');
		MkPrintSN('checking whether DB5 works...');
		MkCompileC('HAVE_DB5', '${DB5_CFLAGS}', '${DB5_LIBS}', $testCode);
		MkIfFalse('${HAVE_DB5}');
			MkDisableFailed('db5');
		MkEndif;
	MkElse;
		MkPrint('no');
		MkDisableNotFound('db5');
	MkEndif;
}

sub CMAKE_db5
{
	my $code = MkCodeCMAKE($testCode);

	return << "EOF";
macro(Check_Db5)
	# TODO
endmacro()

macro(Disable_Db5)
	BB_Save_MakeVar(DB5_CFLAGS "")
	BB_Save_MakeVar(DB5_LIBS "")
	BB_Save_Undef(HAVE_DB5)
endmacro()
EOF
}

sub DISABLE_db5
{
	MkDefine('HAVE_DB5', 'no') unless $TestFailed;
	MkDefine('DB5_CFLAGS', '');
	MkDefine('DB5_LIBS', '');
	MkSaveUndef('HAVE_DB5');
}

BEGIN
{
	my $n = 'db5';

	$DESCR{$n}   = 'Berkeley DB 5.x';
	$URL{$n}     = 'http://www.oracle.com/technology/products/berkeley-db';
	$TESTS{$n}   = \&TEST_db5;
	$CMAKE{$n}   = \&CMAKE_db5;
	$DISABLE{$n} = \&DISABLE_db5;
	$DEPS{$n}    = 'cc';
	$SAVED{$n}   = 'DB5_CFLAGS DB5_LIBS';
}
;1
