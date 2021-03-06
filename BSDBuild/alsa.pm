# Public domain

my $testCode = << 'EOF';
#include <alsa/asoundlib.h>
int main(int argc, char *argv[]) {
	int rv;
	snd_rawmidi_t *h = 0;
	rv = snd_rawmidi_open(&h, NULL, "foo", 0);
	return (0);
}
EOF
my @autoIncludeDirs = (
	'/usr/include',
	'/usr/local/include'
);

my @autoLibDirs = (
	'/usr/lib',
	'/usr/local/lib'
);

sub TEST_alsa
{
	my ($ver, $pfx) = @_;

	MkDefine('ALSA_CFLAGS', '');
	MkDefine('ALSA_LIBS', '');

	MkIfNE($pfx, '');
		MkIfExists("$pfx/include/alsa");
			MkDefine('ALSA_CFLAGS', "-I$pfx/include");
		MkEndif;
		MkIfExists("$pfx/lib");
			MkDefine('ALSA_LIBS', "-L$pfx/lib -lasound");
		MkEndif;
	MkElse;
		foreach my $dir (@autoIncludeDirs) {
			MkIfExists("$dir/alsa");
				MkDefine('ALSA_CFLAGS', "\${ALSA_CFLAGS} -I$dir");
			MkEndif;
		}
		foreach my $dir (@autoLibDirs) {
			MkIfExists($dir);
				MkDefine('ALSA_LIBS', "\${ALSA_LIBS} -L$dir -lasound");
			MkEndif;
		}
	MkEndif;

	MkIfNE('${ALSA_LIBS}', '');
		MkPrintS('yes');
		MkPrintSN('checking whether ALSA works...');
		MkCompileC('HAVE_ALSA', '${ALSA_CFLAGS}', '${ALSA_LIBS}', $testCode);
		MkIfFalse('${HAVE_ALSA}');
			MkDisableFailed('alsa');
		MkEndif;
	MkElse;
		MkDisableNotFound('alsa');
	MkEndif;
}

sub DISABLE_alsa
{
	MkDefine('HAVE_ALSA', 'no') unless $TestFailed;
	MkDefine('ALSA_CFLAGS', '');
	MkDefine('ALSA_LIBS', '');
	MkSaveUndef('HAVE_ALSA');
}

BEGIN
{
	my $n = 'alsa';

	$DESCR{$n}   = 'ALSA';
	$URL{$n}     = 'http://www.alsa-project.org';
	$TESTS{$n}   = \&TEST_alsa;
	$DISABLE{$n} = \&DISABLE_alsa;
	$DEPS{$n}    = 'cc';
	$SAVED{$n}   = 'ALSA_CFLAGS ALSA_LIBS';
}
;1
