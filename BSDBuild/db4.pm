# Public domain

my @db4_releases = ('4.8', '4.7', '4.6', '4.5', '4.4', '4.3', '4.2', '4');

my $testCode = << 'EOF';
#include <db.h>
int main(int argc, char *argv[]) {
	DB *db;
	db_create(&db, NULL, 0);
	return (0);
}
EOF

my $testCodeCMAKE = << 'EOF';
#ifdef __FreeBSD__
# include <db18/db.h>
#else
# include <db.h>
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

	MkDefine('DB4_CFLAGS', '');
	MkDefine('DB4_LIBS', '');
	MkDefine('DB4_VERSION', '');
	MkDefine('DB4_VERSION_J', '');

	MkFor('path', $pfx.' /usr/local /usr /opt');
		MkFor('dbver', join(' ',@db4_releases));
			MkSetExec('DB4_VERSION_J', 'echo "${dbver}" | sed "s/\.//"');
			MkIfExists('${path}/include/db$dbver');
				MkDefine('DB4_CFLAGS', '-I${path}/include/db${dbver} '.
  				                       '-I${path}/include');			# XXX
				MkDefine('DB4_VERSION', '${dbver}');
				MkBreak;
			MkElse;
				MkIfExists('${path}/include/db${DB4_VERSION_J}');
					MkDefine('DB4_CFLAGS', '-I${path}/include/db${DB4_VERSION_J} '.
					                       '-I${path}/include');			# XXX
					MkDefine('DB4_VERSION', '${dbver}');
					MkBreak;
				MkEndif;
			MkEndif;
		MkDone;
	MkDone;

	MkIfFound($pfx, $ver, 'DB4_VERSION');
		MkIfExists('${path}/lib/db${DB4_VERSION_J}');
			MkDefine('DB4_LIBS', '-L${path}/lib/db${DB4_VERSION_J} -ldb');
		MkElse;
			MkDefine('DB4_LIBS', '-L${path}/lib -ldb-${DB4_VERSION}');
		MkEndif;

		MkPrintSN('checking whether DB4 works...');
		MkCompileC('HAVE_DB4', '${DB4_CFLAGS}', '${DB4_LIBS}', $testCode);
		MkIfFalse('${HAVE_DB4}');
			MkDisableFailed('db4');
		MkEndif;
	MkElse;
		MkDisableNotFound('db4');
	MkEndif;
}

sub CMAKE_db4
{
	my $code = MkCodeCMAKE($testCodeCMAKE);

	return << "EOF";
macro(Check_Db4)
	set(DB4_CFLAGS "")
	set(DB4_LIBS "")
	if(FREEBSD)
		set(ORIG_CMAKE_REQUIRED_FLAGS \${CMAKE_REQUIRED_FLAGS})
		set(ORIG_CMAKE_REQUIRED_LIBRARIES \${CMAKE_REQUIRED_LIBRARIES})
		set(CMAKE_REQUIRED_FLAGS "\${CMAKE_REQUIRED_FLAGS} -I/usr/local/include")
		set(CMAKE_REQUIRED_LIBRARIES "\${CMAKE_REQUIRED_LIBRARIES} -L/usr/local/lib -ldb-18")

		CHECK_INCLUDE_FILE(db18/db.h HAVE_DB18_DB_H)
		if(HAVE_DB18_DB_H)
			check_c_source_compiles("
$code" HAVE_DB4)
			if(HAVE_DB4)
				set(DB4_CFLAGS "-I/usr/local/include")
				set(DB4_LIBS "-L/usr/local/lib" "-ldb-18")
				BB_Save_Define(HAVE_DB4)
			else()
				BB_Save_Undef(HAVE_DB4)
			endif()
		else()
			set(HAVE_DB4 OFF)
			BB_Save_Undef(HAVE_DB4)
		endif()

		set(CMAKE_REQUIRED_FLAGS \${ORIG_CMAKE_REQUIRED_FLAGS})
		set(CMAKE_REQUIRED_LIBRARIES \${ORIG_CMAKE_REQUIRED_LIBRARIES})
	else()
		check_c_source_compiles("
$code" HAVE_DB4)
		if(HAVE_DB4)
			BB_Save_Define(HAVE_DB4)
		else()
			BB_Save_Undef(HAVE_DB4)
		endif()
	endif()

	BB_Save_MakeVar(DB4_CFLAGS "\${DB4_CFLAGS}")
	BB_Save_MakeVar(DB4_LIBS "\${DB4_LIBS}")
endmacro()

macro(Disable_Db4)
	set(HAVE_DB4 OFF)
	BB_Save_MakeVar(DB4_CFLAGS "")
	BB_Save_MakeVar(DB4_LIBS "")
	BB_Save_Undef(HAVE_DB4)
endmacro()
EOF
}

sub DISABLE_db4
{
	MkDefine('HAVE_DB4', 'no') unless $TestFailed;
	MkDefine('DB4_CFLAGS', '');
	MkDefine('DB4_LIBS', '');
	MkSaveUndef('HAVE_DB4');
}

BEGIN
{
	my $n = 'db4';

	$DESCR{$n}   = 'Berkeley DB 4.x';
	$URL{$n}     = 'http://www.oracle.com/technology/products/berkeley-db';
	$TESTS{$n}   = \&TEST_db4;
	$CMAKE{$n}   = \&CMAKE_db4;
	$DISABLE{$n} = \&DISABLE_db4;
	$DEPS{$n}    = 'cc';
	$SAVED{$n}   = 'DB4_CFLAGS DB4_LIBS';
}
;1
