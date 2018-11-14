# Public domain
# vim:ts=4

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

sub Test
{
	my ($ver, $pfx) = @_;

	print << "EOF";
DB4_CFLAGS=''
DB4_LIBS=''
DB4_VERSION=''

for path in $pfx /usr /usr/local /opt; do
EOF
	print << 'EOF';
	if [ -e "${path}/include/db4.8" ]; then
		DB4_CFLAGS="-I${path}/include/db4.8 -I${path}/include"
		DB4_VERSION='4.8'
	elif [ -e "${path}/include/db4.7" ]; then
		DB4_CFLAGS="-I${path}/include/db4.7 -I${path}/include"
		DB4_VERSION='4.7'
	elif [ -e "${path}/include/db4.6" ]; then
		DB4_CFLAGS="-I${path}/include/db4.6 -I${path}/include"
		DB4_VERSION='4.6'
	elif [ -e "${path}/include/db4.5" ]; then
		DB4_CFLAGS="-I${path}/include/db4.5 -I${path}/include"
		DB4_VERSION='4.5'
	elif [ -e "${path}/include/db4.4" ]; then
		DB4_CFLAGS="-I${path}/include/db4.4 -I${path}/include"
		DB4_VERSION='4.4'
	elif [ -e "${path}/include/db4.3" ]; then
		DB4_CFLAGS="-I${path}/include/db4.3 -I${path}/include"
		DB4_VERSION='4.3'
	elif [ -e "${path}/include/db4.2" ]; then
		DB4_CFLAGS="-I${path}/include/db4.2 -I${path}/include"
		DB4_VERSION='4.2'
	elif [ -e "${path}/include/db47" ]; then
		DB4_CFLAGS="-I${path}/include/db47 -I${path}/include"
		DB4_VERSION='4.7'
	elif [ -e "${path}/include/db46" ]; then
		DB4_CFLAGS="-I${path}/include/db46 -I${path}/include"
		DB4_VERSION='4.6'
	elif [ -e "${path}/include/db45" ]; then
		DB4_CFLAGS="-I${path}/include/db45 -I${path}/include"
		DB4_VERSION='4.5'
	elif [ -e "${path}/include/db44" ]; then
		DB4_CFLAGS="-I${path}/include/db44 -I${path}/include"
		DB4_VERSION='4.4'
	elif [ -e "${path}/include/db43" ]; then
		DB4_CFLAGS="-I${path}/include/db43 -I${path}/include"
		DB4_VERSION='4.3'
	elif [ -e "${path}/include/db42" ]; then
		DB4_CFLAGS="-I${path}/include/db42 -I${path}/include"
		DB4_VERSION='4.2'
	elif [ -e "${path}/include/db4" ]; then
		DB4_CFLAGS="-I${path}/include/db4 -I${path}/include"
		DB4_VERSION='4'
	fi
	case "${DB4_VERSION}" in
	4)
		if [ -e "${path}/lib/db4" ]; then
			DB4_LIBS="-L${path}/lib/db4 -ldb"
		fi
		;;
	4.2)
		if [ -e "${path}/lib/db42" ]; then
			DB4_LIBS="-L${path}/lib/db42 -ldb"
		elif [ -e "${path}/lib/libdb-4.2.so" ]; then
			DB4_LIBS="-L${path}/lib -ldb-4.2"
		fi
		;;
	4.3)
		if [ -e "${path}/lib/db43" ]; then
			DB4_LIBS="-L${path}/lib/db43 -ldb"
		elif [ -e "${path}/lib/libdb-4.3.so" ]; then
			DB4_LIBS="-L${path}/lib -ldb-4.3"
		fi
		;;
	4.4)
		if [ -e "${path}/lib/db44" ]; then
			DB4_LIBS="-L${path}/lib/db44 -ldb"
		elif [ -e "${path}/lib/libdb-4.4.so" ]; then
			DB4_LIBS="-L${path}/lib -ldb-4.4"
		fi
		;;
	4.5)
		if [ -e "${path}/lib/db45" ]; then
			DB4_LIBS="-L${path}/lib/db45 -ldb"
		elif [ -e "${path}/lib/libdb-4.5.so" ]; then
			DB4_LIBS="-L${path}/lib -ldb-4.5"
		fi
		;;
	4.6)
		if [ -e "${path}/lib/db46" ]; then
			DB4_LIBS="-L${path}/lib/db46 -ldb"
		elif [ -e "${path}/lib/libdb-4.6.so" ]; then
			DB4_LIBS="-L${path}/lib -ldb-4.6"
		fi
		;;
	4.7)
		if [ -e "${path}/lib/db47" ]; then
			DB4_LIBS="-L${path}/lib/db47 -ldb"
		elif [ -e "${path}/lib/libdb-4.7.so" ]; then
			DB4_LIBS="-L${path}/lib -ldb-4.7"
		fi
		;;
	4.8)
		if [ -e "${path}/lib/db48" ]; then
			DB4_LIBS="-L${path}/lib/db48 -ldb"
		elif [ -e "${path}/lib/libdb-4.8.so" ]; then
			DB4_LIBS="-L${path}/lib -ldb-4.8"
		fi
		;;
	*)
		;;
	esac
done
EOF

	MkIfFound($pfx, $ver, 'DB4_VERSION');
		MkPrintSN('checking whether DB4 works...');
		MkCompileC('HAVE_DB4', '${DB4_CFLAGS}', '${DB4_LIBS}', $testCode);
		MkSaveIfTrue('${HAVE_DB4}', 'DB4_CFLAGS', 'DB4_LIBS');
	MkElse;
		Disable();
	MkEndif;
	return (0);
}

sub Disable
{
	MkDefine('HAVE_DB4', 'no');
	MkDefine('DB4_CFLAGS', '');
	MkDefine('DB4_LIBS', '');
	MkSaveUndef('HAVE_DB4');
}

sub Emul
{
	my ($os, $osrel, $machine) = @_;
	
	MkEmulUnavail('DB4');
	return (1);
}

BEGIN
{
	my $n = 'db4';

	$DESCR{$n} = 'Berkeley DB 4.x';
	$URL{$n}   = 'http://www.oracle.com/technology/products/berkeley-db';

	$TESTS{$n}   = \&Test;
	$DISABLE{$n} = \&Disable;
	$EMUL{$n}    = \&Emul;
	
	$DEPS{$n} = 'cc';
}

;1
