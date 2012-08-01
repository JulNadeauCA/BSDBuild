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
	MkDefine('DSO_CFLAGS', '');
	MkDefine('DSO_LIBS', '');

	BeginTestHeaders();
	DetectHeaderC('HAVE_MACH_O_DYLD_H',	'<mach-o/dyld.h>');

	TryCompile 'HAVE_DYLD', << 'EOF';
#ifdef HAVE_MACH_O_DYLD_H
#include <mach-o/dyld.h>
#endif
int
main(int argc, char *argv[])
{
	NSObjectFileImage img;
	NSObjectFileImageReturnCode rv;

	rv = NSCreateObjectFileImageFromFile("foo", &img);
	return (rv == NSObjectFileImageSuccess);
}
EOF

	MkIfTrue('${HAVE_DYLD}');
		MkPrint('checking for NSLINKMODULE_OPTION_RETURN_ON_ERROR');
		TryCompile 'HAVE_DYLD_RETURN_ON_ERROR', << 'EOF';
#ifdef HAVE_MACH_O_DYLD_H
#include <mach-o/dyld.h>
#endif
int
main(int argc, char *argv[])
{
	NSObjectFileImage img;
	NSObjectFileImageReturnCode rv;
	void *handle;

	rv = NSCreateObjectFileImageFromFile("foo", &img);
	handle = (void *)NSLinkModule(img, "foo",
	    NSLINKMODULE_OPTION_RETURN_ON_ERROR|
		NSLINKMODULE_OPTION_NONE);
	if (handle == NULL) {
		NSLinkEditErrors errs;
		int n;
		const char *f, *s = NULL;
		NSLinkEditError(&errs, &n, &f, &s);
	}
	return (0);
}
EOF
	MkElse;
		MkDefine('HAVE_DYLD_RETURN_ON_ERROR', 'no');
		MkSaveUndef('HAVE_DYLD_RETURN_ON_ERROR');
	MkEndif;

	EndTestHeaders();
	
	MkSave('DSO_CFLAGS', 'DSO_LIBS');
}

sub Emul
{
	my ($os, $osrel, $machine) = @_;
	
	MkEmulUnavail('DSO');
	MkEmulUnavailSYS('MACH_O_DYLD_H', 'DYLD', 'DYLD_RETURN_ON_ERROR');
	return (1);
}

BEGIN
{
	$DESCR{'dyld'} = 'dyld interface';
	$TESTS{'dyld'} = \&Test;
	$EMUL{'dyld'} = \&Emul;
	$DEPS{'dyld'} = 'cc';
}

;1
