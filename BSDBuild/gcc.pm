# vim:ts=4
#
# Copyright (c) 2012 Hypertriton, Inc. <http://hypertriton.com/>
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
	MkCompileC('HAVE_GCC', '', '', << 'EOF');
int main(int argc, char *argv[]) {
#if !defined(__GNUC__)
# error "Not GCC"
#endif
	return (0);
}
EOF

	MkPrintSN('checking whether the Objective-C compiler is GCC...');
	MkCompileOBJC('HAVE_GCC_OBJC', '', '', << 'EOF');
#import <stdio.h>
int main(int argc, char *argv[]) {
#if !defined(__GNUC__)
# error "Not GCC"
#endif
	return (0);
}
EOF
	
	MkPrintSN('checking whether the C++ compiler is GCC...');
	MkCompileOBJC('HAVE_GCC_CXX', '', '', << 'EOF');
#import <stdio.h>
int main(int argc, char *argv[]) {
#if !defined(__GNUC__)
# error "Not GCC"
#endif
	return (0);
}
EOF
}

sub Emul
{
	my ($os, $osrel, $machine) = @_;

	MkSaveUndef('HAVE_GCC');
	MkSaveUndef('HAVE_GCC_OBJC');
	MkSaveUndef('HAVE_GCC_CXX');
	return (1);
}

BEGIN
{
	$TESTS{'gcc'} = \&Test;
	$EMUL{'gcc'} = \&Emul;
	$DESCR{'gcc'} = 'whether the C compiler is GCC';
}

;1
