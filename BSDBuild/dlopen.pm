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

sub Test
{
	my $code = << 'EOF';
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
	return (0);
}
EOF

	MkDefine('DSO_CFLAGS', '');
	MkDefine('DSO_LIBS', '');

	BeginTestHeaders();
	DetectHeaderC('HAVE_DLFCN_H',	'<dlfcn.h>');
	TryCompile('HAVE_DLOPEN', $code);
	MkIf('"${HAVE_DLOPEN}" != "yes"');
		MkPrintN('checking for dlopen() in -ldl...');
		TryCompileFlagsC('HAVE_DLOPEN', '-ldl', $code);
		MkIf('"${HAVE_DLOPEN}" = "yes"');
			MkDefine('DSO_CFLAGS', '');
			MkDefine('DSO_LIBS', '-ldl');
		MkEndif;
	MkEndif;
	
	EndTestHeaders();

	MkSaveMK('DSO_CFLAGS', 'DSO_LIBS');
	MkSaveDefine('DSO_CFLAGS', 'DSO_LIBS');
}

sub Emul
{
	my ($os, $osrel, $machine) = @_;

	if ($os eq 'linux' || $os eq 'darwin' || $os =~ /^(open|net|free)bsd$/) {
		MkDefine('HAVE_DLOPEN', 'yes');
		MkDefine('HAVE_DLFCN_H', 'yes');
		MkSaveDefine('HAVE_DLOPEN');
	} else {
		MkSaveUndef('HAVE_DLFCN_H');
		MkSaveUndef('HAVE_DLOPEN');
	}
	MkDefine('DSO_CFLAGS', '');
	MkDefine('DSO_LIBS', '');
	MkSaveMK('DSO_CFLAGS', 'DSO_LIBS');
	MkSaveDefine('DSO_CFLAGS', 'DSO_LIBS');
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
