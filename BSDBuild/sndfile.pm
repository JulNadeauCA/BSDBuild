# Public domain

my $testCode = << 'EOF';
#include <stdio.h>
#include <sndfile.h>

int main(int argc, char *argv[]) {
	SNDFILE *sf;
	SF_INFO sfi;

	sfi.format = 0;
	sf = sf_open("foo", 0, &sfi);
	sf_close(sf);
	return (0);
}
EOF

sub TEST_sndfile
{
	my ($ver, $pfx) = @_;
	
	MkExecPkgConfig($pfx, 'sndfile', '--modversion', 'SNDFILE_VERSION');
	MkExecPkgConfig($pfx, 'sndfile', '--cflags', 'SNDFILE_CFLAGS');
	MkExecPkgConfig($pfx, 'sndfile', '--libs', 'SNDFILE_LIBS');
	MkIfFound($pfx, $ver, 'SNDFILE_VERSION');
		MkPrintSN('checking whether libsndfile works...');
		MkCompileC('HAVE_SNDFILE',
		           '${SNDFILE_CFLAGS}', '${SNDFILE_LIBS}', $testCode);
		MkIfFalse('${HAVE_SNDFILE}');
			MkDisableFailed('sndfile');
		MkEndif;
	MkElse;
		MkDisableNotFound('sndfile');
	MkEndif;

	MkIfTrue('${HAVE_SNDFILE}');
		MkDefine('SNDFILE_PC', 'sndfile');
	MkEndif;
}

sub CMAKE_sndfile
{
	my $code = MkCodeCMAKE($testCode);

	return << "EOF";
macro(Check_Sndfile)
	set(SNDFILE_CFLAGS "")
	set(SNDFILE_LIBS "")

	set(ORIG_CMAKE_REQUIRED_FLAGS \${CMAKE_REQUIRED_FLAGS})
	set(ORIG_CMAKE_REQUIRED_LIBRARIES \${CMAKE_REQUIRED_LIBRARIES})
	set(CMAKE_REQUIRED_FLAGS "\${CMAKE_REQUIRED_FLAGS} -I/usr/local/include")
	set(CMAKE_REQUIRED_LIBRARIES "\${CMAKE_REQUIRED_LIBRARIES} -L/usr/local/lib -lsndfile")

	CHECK_INCLUDE_FILE(sndfile.h HAVE_SNDFILE_H)
	if(HAVE_SNDFILE_H)
		check_c_source_compiles("
$code" HAVE_SNDFILE)
		if(HAVE_SNDFILE)
			set(SNDFILE_CFLAGS "-I/usr/local/include")
			set(SNDFILE_LIBS "-L/usr/local/lib" "-lsndfile")
			BB_Save_Define(HAVE_SNDFILE)
		else()
			BB_Save_Undef(HAVE_SNDFILE)
		endif()
	else()
		set(HAVE_SNDFILE OFF)
		BB_Save_Undef(HAVE_SNDFILE)
	endif()

	set(CMAKE_REQUIRED_FLAGS \${ORIG_CMAKE_REQUIRED_FLAGS})
	set(CMAKE_REQUIRED_LIBRARIES \${ORIG_CMAKE_REQUIRED_LIBRARIES})

	BB_Save_MakeVar(SNDFILE_CFLAGS "\${SNDFILE_CFLAGS}")
	BB_Save_MakeVar(SNDFILE_LIBS "\${SNDFILE_LIBS}")
endmacro()

macro(Disable_Sndfile)
	set(HAVE_SNDFILE OFF)
	BB_Save_MakeVar(SNDFILE_CFLAGS "")
	BB_Save_MakeVar(SNDFILE_LIBS "")
	BB_Save_Undef(HAVE_SNDFILE)
endmacro()
EOF
}

sub DISABLE_sndfile
{
	MkDefine('HAVE_SNDFILE', 'no') unless $TestFailed;
	MkDefine('SNDFILE_CFLAGS', '');
	MkDefine('SNDFILE_LIBS', '');
	MkSaveUndef('HAVE_SNDFILE');
}

BEGIN
{
	my $n = 'sndfile';

	$DESCR{$n}   = 'libsndfile';
	$URL{$n}     = 'http://www.mega-nerd.com/libsndfile';
	$TESTS{$n}   = \&TEST_sndfile;
	$CMAKE{$n}   = \&CMAKE_sndfile;
	$DISABLE{$n} = \&DISABLE_sndfile;
	$DEPS{$n}    = 'cc';
	$SAVED{$n}   = 'SNDFILE_CFLAGS SNDFILE_LIBS SNDFILE_PC';
}
;1
