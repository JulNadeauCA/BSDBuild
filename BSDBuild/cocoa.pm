# vim:ts=4
#
# Copyright (c) 2012 Hypertriton Inc. <http://hypertriton.com/>
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
	my ($ver, $pfx) = @_;
	
	MkDefine('COCOA_CFLAGS', '-DTARGET_API_MAC_CARBON ' .
	                         '-DTARGET_API_MAC_OSX ' .
	                         '-falign-loops=16 -force_cpusubtype_ALL '.
							 '-fpascal-strings');
	MkDefine('COCOA_LIBS', '-lobjc '.
	                       '-Wl,framework,Cocoa ' .
	                       '-Wl,framework,Carbon ' .
	                       '-Wl,framework,IOKit');

	MkCompileOBJC('HAVE_COCOA', '${COCOA_CFLAGS}', '${COCOA_LIBS}', << 'EOF');
#import <Cocoa/Cocoa.h>
EOF
	MkSaveIfTrue('${HAVE_COCOA}', 'COCOA_CFLAGS', 'COCOA_LIBS');
	return (0);
}

sub Link
{
	my $lib = shift;

	if ($lib ne 'Cocoa') {
		return (0);
	}
	PmIfHDefined('HAVE_COCOA');
		if ($EmulEnv =~ /^cb-/) {
			PmIncludePath('$(#Cocoa.include)');
			PmLibPath('$(#Cocoa.lib)');
		}
	PmEndif;
	return (1);
}

sub Emul
{
	my ($os, $osrel, $machine) = @_;

	if ($os eq 'darwin') {
		MkDefine('HAVE_COCOA', 'yes');
		MkDefine('COCOA_CFLAGS', '-DTARGET_API_MAC_CARBON ' .
	                             '-DTARGET_API_MAC_OSX ' .
	                             '-falign-loops=16 -force_cpusubtype_ALL '.
							     '-fpascal-strings');
		MkDefine('COCOA_LIBS', '-lobjc '.
		                       '-Wl,framework,Cocoa ' .
		                       '-Wl,framework,Carbon ' .
		                       '-Wl,framework,IOKit');
		MkSave('HAVE_COCOA', 'COCOA_CFLAGS', 'COCOA_LIBS');
	} else {
		MkDefine('HAVE_COCOA', 'no');
		MkSaveUndef('HAVE_COCOA', 'COCOA_CFLAGS', 'COCOA_LIBS');
	}
	return (1);
}

BEGIN
{
	$DESCR{'cocoa'} = 'the Cocoa framework';
	$TESTS{'cocoa'} = \&Test;
	$LINK{'cocoa'} = \&Link;
	$EMUL{'cocoa'} = \&Emul;
	$DEPS{'cocoa'} = 'objc';
}

;1
