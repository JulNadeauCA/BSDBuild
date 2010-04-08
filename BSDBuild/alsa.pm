# vim:ts=4
#
# Copyright (c) 2002, 2003, 2004 CubeSoft Communications, Inc.
# <http://www.csoft.org>
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

my @include_dirs = (
	'/usr/include',
	'/usr/local/include'
);

my @lib_dirs = (
	'/usr/lib',
	'/usr/local/lib'
);

sub Test
{
	my ($ver) = @_;

	MkDefine('ALSA_CFLAGS', '');
	MkDefine('ALSA_LIBS', '');

	foreach my $dir (@include_dirs) {
		MkIf qq{-d "$dir/alsa"};
			MkDefine('ALSA_CFLAGS', "\${ALSA_CFLAGS} -I$dir");
		MkEndif;
	}
	foreach my $dir (@lib_dirs) {
		MkIf qq{-d "$dir"};
			MkDefine('ALSA_LIBS', "\${ALSA_LIBS} -L$dir -lasound");
		MkEndif;
	}
	MkPrint('yes');
	
	my $code = << 'EOF';
#include <alsa/asoundlib.h>
int main(int argc, char *argv[]) {
	int rv;
	snd_rawmidi_t *h = 0;
	rv = snd_rawmidi_open(&h, NULL, "foo", 0);
	return (0);
}
EOF
	MkPrintN('checking whether ALSA works...');
	MkCompileC('HAVE_ALSA', '${ALSA_CFLAGS}', '${ALSA_LIBS}', $code);
	MkIf '"${HAVE_ALSA}" = "yes"';
		MkSaveMK('ALSA_CFLAGS', 'ALSA_LIBS');
		MkSaveDefine('ALSA_CFLAGS', 'ALSA_LIBS');
	MkElse;
		MkSaveUndef('ALSA_CFLAGS', 'ALSA_LIBS');
	MkEndif;
	return (0);
}

sub Link
{
	my $lib = shift;

	if ($lib ne 'alsa') {
		return (0);
	}
	PmIfHDefined('HAVE_ALSA');
		PmLink('asound');
		if ($EmulEnv =~ /^cb-/) {
			PmIncludePath('$(#alsa.include)');
			PmLibPath('$(#alsa.lib)');
		}
	PmEndif;
	return (1);
}

sub Emul
{
	my ($os, $osrel, $machine) = @_;
	
	MkDefine('ALSA_CFLAGS', '-I/usr/local/include');
	MkDefine('ALSA_LIBS', '-lasound');
	MkDefine('HAVE_ALSA', 'yes');
	MkSaveDefine('HAVE_ALSA', 'ALSA_CFLAGS', 'ALSA_LIBS');
	MkSaveMK('ALSA_CFLAGS', 'ALSA_LIBS');
	return (1);
}

BEGIN
{
	$DESCR{'alsa'} = 'ALSA (http://www.alsa-project.org)';
	$TESTS{'alsa'} = \&Test;
	$EMUL{'alsa'} = \&Emul;
	$LINK{'alsa'} = \&Link;
	$DEPS{'alsa'} = 'cc';
}

;1
