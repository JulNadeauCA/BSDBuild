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
		MkIfFalse('${HAVE_PORTAUDIO}');
			MkDisableFailed('portaudio');
		MkEndif;
	MkElse;
		MkDisableNotFound('portaudio');
	MkEndif;
	
	MkIfTrue('${HAVE_PORTAUDIO}');
		MkDefine('PORTAUDIO_PC', 'portaudio-2.0');
	MkEndif;
}

sub CMAKE_portaudio
{
	my $code = MkCodeCMAKE($testCode);

	return << "EOF";
macro(Check_Portaudio)
	set(PORTAUDIO_CFLAGS "")
	set(PORTAUDIO_LIBS "")

	set(ORIG_CMAKE_REQUIRED_FLAGS \${CMAKE_REQUIRED_FLAGS})
	set(ORIG_CMAKE_REQUIRED_LIBRARIES \${CMAKE_REQUIRED_LIBRARIES})
	set(CMAKE_REQUIRED_FLAGS "\${CMAKE_REQUIRED_FLAGS} -I/usr/local/include")
	set(CMAKE_REQUIRED_LIBRARIES "\${CMAKE_REQUIRED_LIBRARIES} -L/usr/local/lib -lm -lpthread -lportaudio")

	CHECK_INCLUDE_FILE(portaudio.h HAVE_PORTAUDIO_H)
	if(HAVE_PORTAUDIO_H)
		check_c_source_compiles("
$code" HAVE_PORTAUDIO)
		if(HAVE_PORTAUDIO)
			set(PORTAUDIO_CFLAGS "-I/usr/local/include")
			set(PORTAUDIO_LIBS "-L/usr/local/lib" "-lm" "-lpthread" "-lportaudio")
			BB_Save_Define(HAVE_PORTAUDIO)
		else()
			BB_Save_Undef(HAVE_PORTAUDIO)
		endif()
	else()
		set(HAVE_PORTAUDIO OFF)
		BB_Save_Undef(HAVE_PORTAUDIO)
	endif()

	set(CMAKE_REQUIRED_FLAGS \${ORIG_CMAKE_REQUIRED_FLAGS})
	set(CMAKE_REQUIRED_LIBRARIES \${ORIG_CMAKE_REQUIRED_LIBRARIES})

	BB_Save_MakeVar(PORTAUDIO_CFLAGS "\${PORTAUDIO_CFLAGS}")
	BB_Save_MakeVar(PORTAUDIO_LIBS "\${PORTAUDIO_LIBS}")
endmacro()

macro(Disable_Portaudio)
	set(HAVE_PORTAUDIO OFF)
	BB_Save_MakeVar(PORTAUDIO_CFLAGS "")
	BB_Save_MakeVar(PORTAUDIO_LIBS "")
	BB_Save_Undef(HAVE_PORTAUDIO)
endmacro()
EOF
}

sub DISABLE_portaudio
{
	MkDefine('HAVE_PORTAUDIO', 'no') unless $TestFailed;
	MkDefine('PORTAUDIO_CFLAGS', '');
	MkDefine('PORTAUDIO_LIBS', '');
	MkSaveUndef('HAVE_PORTAUDIO');
}

BEGIN
{
	my $n = 'portaudio';

	$DESCR{$n}   = 'PortAudio2';
	$URL{$n}     = 'http://www.portaudio.com';
	$TESTS{$n}   = \&TEST_portaudio;
	$CMAKE{$n}   = \&CMAKE_portaudio;
	$DISABLE{$n} = \&DISABLE_portaudio;
	$DEPS{$n}    = 'cc,pthreads';
	$SAVED{$n}   = 'PORTAUDIO_CFLAGS PORTAUDIO_LIBS PORTAUDIO_PC';
}
;1
