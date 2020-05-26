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
	$DISABLE{$n} = \&DISABLE_sndfile;
	$DEPS{$n}    = 'cc';
	$SAVED{$n}   = 'SNDFILE_CFLAGS SNDFILE_LIBS SNDFILE_PC';
}
;1
