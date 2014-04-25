# vim:ts=4
#
# Copyright (c) 2008 Hypertriton, Inc. <http://hypertriton.com/>
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
#include <string.h>
#ifdef HAVE_DLFCN_H
#include <dlfcn.h>
#endif

int
main(int argc, char *argv[])
{
	void *handle;
	char *error;
	handle = dlopen("foo.so", 0);
	error = dlerror();
	(void)dlsym(handle, "foo");
	return (error != NULL);
}
EOF

sub Test
{
	MkDefine('DSO_CFLAGS', '');
	MkDefine('DSO_LIBS', '');

	BeginTestHeaders();
	DetectHeaderC('HAVE_DLFCN_H',	'<dlfcn.h>');
	TryCompile('HAVE_DLOPEN', $testCode);
	MkIfFalse('${HAVE_DLOPEN}');
		MkPrintN('checking for dlopen() in -ldl...');
		TryCompileFlagsC('HAVE_DLOPEN', '-ldl', $testCode);
		MkIfTrue('${HAVE_DLOPEN}');
			MkDefine('DSO_CFLAGS', '');
			MkDefine('DSO_LIBS', '-ldl');
			MkSave('DSO_CFLAGS', 'DSO_LIBS');
		MkEndif;
	MkEndif;
	EndTestHeaders();
}

sub Emul
{
	my ($os, $osrel, $machine) = @_;

	MkEmulUnavail('DSO');
	MkEmulUnavailSYS('DLOPEN', 'DLFCN_H');
	return (1);
}

BEGIN
{
	$DESCR{'dlopen'} = 'dlopen() interface';
	$TESTS{'dlopen'} = \&Test;
	$EMUL{'dlopen'} = \&Emul;
	$DEPS{'dlopen'} = 'cc';
}

;1
