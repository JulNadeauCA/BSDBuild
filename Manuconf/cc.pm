# $Csoft: cc.pm,v 1.13 2003/03/14 22:39:54 vedge Exp $
# vim:ts=4
#
# Copyright (c) 2002 CubeSoft Communications <http://www.csoft.org>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistribution of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistribution in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 3. Neither the name of CubeSoft Communications, nor the names of its
#    contributors may be used to endorse or promote products derived from
#    this software without specific prior written permission.
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
	# Look for a compiler.
	print << 'EOF';
if [ "$CC" = "" ]; then
	for i in `echo $PATH |sed 's/:/ /g'`; do
		if [ -x "${i}/cc" ]; then
			CC="${i}/cc"
		elif [ -x "${i}/gcc" ]; then
			CC="${i}/gcc"
		fi
	done
	if [ "$CC" = "" ]; then
		echo "Could not find a C compiler, try setting CC."
		echo "CC is unset and cc/gcc is not in PATH." >> config.log
		exit 1
	fi
fi

cat << 'EOT' > cc-test.c
int
main(int argc, char *argv[])
{
	return (0);
}
EOT

$CC -o cc-test cc-test.c 2>>config.log
if [ $? != 0 ]; then
    echo "no"
	echo "The test C program failed to compile."
	rm -f cc-test cc-test.c
    exit 1
fi
echo "yes"

rm -f cc-test cc-test.c
EOF

	# Check for IEEE floating point support.
	# XXX incomplete
	print NEcho('checking for IEEE 754 floating point...');
	TryCompile 'HAVE_IEEE754', << 'EOF';
#include <stdio.h>

int
main(int argc, char *argv[])
{
	float f = 1.5;
	double d = 2.5;

	printf("%f %d\n", f, d);
	return (0);
}
EOF
	
	# Check for long double type.
	print NEcho('checking for long double...');
	TryCompile 'HAVE_LONG_DOUBLE', << 'EOF';
int
main(int argc, char *argv[])
{
	long double ld = 0.1;
	
	printf("%Lf\n", ld);
	return (0);
}
EOF
}

BEGIN
{
	$TESTS{'cc'} = \&Test;
	$DESCR{'cc'} = 'a usable C compiler';
}

;1
