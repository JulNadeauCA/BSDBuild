# Public domain

my $testCode = << 'EOF';
#include <dirent.h>

int
main(int argc, char *argv[])
{
	DIR *dirp = opendir("foo");
	int fd = -1;
	if (dirp != NULL) {
		fd = dirfd(dirp);
		closedir(dirp);
	}
	return (fd == -1);
}
EOF

sub TEST_dirfd
{
	TryCompile('HAVE_DIRFD', $testCode);
}

sub CMAKE_dirfd
{
	my $code = MkCodeCMAKE($testCode);

	return << "EOF";
macro(Check_Dirfd)
	check_c_source_compiles("
$code" HAVE_DIRFD)
	if (HAVE_DIRFD)
		BB_Save_Define(HAVE_DIRFD)
	else()
		BB_Save_Undef(HAVE_DIRFD)
	endif()
endmacro()

macro(Disable_Dirfd)
	BB_Save_Undef(HAVE_DIRFD)
endmacro()
EOF
}

sub DISABLE_dirfd
{
	MkDefine('HAVE_DIRFD', 'no');
	MkSaveUndef('HAVE_DIRFD');
}

BEGIN
{
	my $n = 'dirfd';

	$DESCR{$n}   = 'dirfd()';
	$TESTS{$n}   = \&TEST_dirfd;
	$CMAKE{$n}   = \&CMAKE_dirfd;
	$DISABLE{$n} = \&DISABLE_dirfd;
	$DEPS{$n}    = 'cc';
}
;1
