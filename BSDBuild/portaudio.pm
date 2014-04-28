# vim:ts=4
#
# Copyright (c) 2011 Hypertriton, Inc. <http://hypertriton.com/>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
# USE OF THIS SOFTWARE EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

my $testCode = << 'EOF';
#include <stdio.h>
#include <portaudio2/portaudio.h>

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

sub Test
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
			# XXX 
			MkIfExists("$dir/include/portaudio2/portaudio.h");
				MkDefine('PORTAUDIO_CFLAGS', "-I$dir/include \${PORTAUDIO_CFLAGS}");
			MkEndif;
		}
	MkElse;
		MkDefine('PORTAUDIO_CFLAGS', '');
		MkDefine('PORTAUDIO_LIBS', '');
		MkIfNE($pfx, '');
			MkIfExists("$pfx/include/portaudio.h");
				MkDefine('PORTAUDIO_CFLAGS', "-I$pfx/include \${PTHREADS_CFLAGS}");
			    MkDefine('PORTAUDIO_LIBS', "-L$pfx/lib -lportaudio \${PTHREADS_LIBS}");
				MkDefine('PORTAUDIO_VERSION', "18.0");
			MkEndif;
		MkElse;
			foreach my $dir (@autoPrefixes) {
				MkIfExists("$dir/include/portaudio.h");
					MkDefine('PORTAUDIO_CFLAGS', "-I$dir/include \${PTHREADS_CFLAGS}");
				    MkDefine('PORTAUDIO_LIBS', "-L$dir/lib -lportaudio \${PTHREADS_LIBS}");
					MkDefine('PORTAUDIO_VERSION', "18.0");
				MkEndif;
			}
		MkEndif;
	MkEndif;

	MkIfFound($pfx, $ver, 'PORTAUDIO_VERSION');
		MkPrintN('checking whether PortAudio2 works...');
		MkCompileC('HAVE_PORTAUDIO', '${PORTAUDIO_CFLAGS}', '${PORTAUDIO_LIBS}', $testCode);
		MkSaveIfTrue('${HAVE_PORTAUDIO}', 'PORTAUDIO_CFLAGS', 'PORTAUDIO_LIBS');
	MkElse;
		MkSaveUndef('HAVE_PORTAUDIO', 'PORTAUDIO_CFLAGS', 'PORTAUDIO_LIBS');
	MkEndif;
}

sub Emul
{
	my ($os, $osrel, $machine) = @_;
	
	MkEmulUnavail('PORTAUDIO');
	return (1);
}

BEGIN
{
	$TESTS{'portaudio'} = \&Test;
	$DEPS{'portaudio'} = 'cc,pthreads';
	$DESCR{'portaudio'} = 'PortAudio2 (http://www.portaudio.com/)';
	$EMUL{'portaudio'} = \&Emul;
}
;1
