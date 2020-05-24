# vim:ts=4
# Public domain

my $testCode = << 'EOF';
#include <stdio.h>
#include <portaudio.h>

int
main(int argc, char *argv[])
{
	int rv;

	if ((rv = Pa_Initialize()) != paNoError) {
		if (Pa_IsFormatSupported(NULL, NULL, 48000.0) != 0) {
			return (0);
		} else {
			return (rv);
		}
	} else {
		Pa_Terminate();
		return (0);
	}
}
EOF

my @autoPrefixes = (
	'/usr/local',
	'/usr',
	'/opt/local',
	'/opt',
	'/usr/pkg'
);

sub TEST_portaudio
{
	my ($ver, $pfx) = @_;
	
	MkDefine('PORTAUDIO_VERSION', '');
	
	MkIfPkgConfig('portaudio-2.0');
		MkExecPkgConfig($pfx, 'portaudio-2.0', '--modversion', 'PORTAUDIO_VERSION');
		MkExecPkgConfig($pfx, 'portaudio-2.0', '--cflags', 'PORTAUDIO_CFLAGS');
		MkExecPkgConfig($pfx, 'portaudio-2.0', '--libs', 'PORTAUDIO_LIBS');
		MkIfNE('${PORTAUDIO_VERSION}', '');
			MkDefine('PORTAUDIO_VERSION', '${PORTAUDIO_VERSION}.0');
		MkEndif;
		foreach my $dir (@autoPrefixes) {
			MkIfExists("$dir/include/portaudio2/portaudio.h");
				MkDefine('PORTAUDIO_CFLAGS',
				         "-I$dir/include/portaudio2 \${PORTAUDIO_CFLAGS}");
			MkEndif;
		}
	MkElse;
		MkDefine('PORTAUDIO_CFLAGS', '');
		MkDefine('PORTAUDIO_LIBS', '');
		MkIfNE($pfx, '');
			MkIfExists("$pfx/include/portaudio.h");
				MkDefine('PORTAUDIO_CFLAGS',
				         "-I$pfx/include \${PTHREADS_CFLAGS}");
			    MkDefine('PORTAUDIO_LIBS',
				         "-L$pfx/lib -lportaudio \${PTHREADS_LIBS}");
				MkDefine('PORTAUDIO_VERSION', "18.0");
			MkEndif;
		MkElse;
			foreach my $dir (@autoPrefixes) {
				MkIfExists("$dir/include/portaudio.h");
					MkDefine('PORTAUDIO_CFLAGS',
					         "-I$dir/include \${PTHREADS_CFLAGS}");
				    MkDefine('PORTAUDIO_LIBS',
					         "-L$dir/lib -lportaudio \${PTHREADS_LIBS}");
					MkDefine('PORTAUDIO_VERSION', "18.0");
				MkEndif;
			}
		MkEndif;
	MkEndif;

	MkIfFound($pfx, $ver, 'PORTAUDIO_VERSION');
		MkPrintSN('checking whether PortAudio2 works...');
		MkCompileC('HAVE_PORTAUDIO', '${PORTAUDIO_CFLAGS}', '${PORTAUDIO_LIBS}', $testCode);
		MkSaveIfTrue('${HAVE_PORTAUDIO}', 'PORTAUDIO_CFLAGS', 'PORTAUDIO_LIBS');
	MkElse;
		MkSaveUndef('HAVE_PORTAUDIO');
	MkEndif;
	
	MkIfTrue('${HAVE_PORTAUDIO}');
		MkDefine('PORTAUDIO_PC', 'portaudio-2.0');
	MkElse;
		MkDefine('PORTAUDIO_PC', '');
	MkEndif;
}

sub DISABLE_portaudio
{
	MkDefine('HAVE_PORTAUDIO', 'no');
	MkDefine('PORTAUDIO_CFLAGS', '');
	MkDefine('PORTAUDIO_LIBS', '');
	MkDefine('PORTAUDIO_PC', '');
	MkSaveUndef('HAVE_PORTAUDIO');
}

BEGIN
{
	my $n = 'portaudio';

	$DESCR{$n}   = 'PortAudio2';
	$URL{$n}     = 'http://www.portaudio.com';
	$TESTS{$n}   = \&TEST_portaudio;
	$DISABLE{$n} = \&DISABLE_portaudio;
	$DEPS{$n}    = 'cc,pthreads';
}
;1
