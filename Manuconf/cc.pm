# $Csoft: cc.pm,v 1.12 2003/03/13 22:50:37 vedge Exp $
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
cc_is_gcc=no
cc_is_gcc3=no

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

cat << 'EOT' > .cctest.c
int
main(int argc, char *argv[])
{
#ifdef __GNUC__
	return (0);
#else
	return (1);
#endif
}
EOT

$CC -o .cctest .cctest.c 2>>config.log
if [ $? != 0 -o ! -e .cctest ]; then
    echo "no"
	echo "The test C program failed to compile or run."
    exit 1
fi

if ./.cctest; then
    cc_is_gcc=yes
	$CC -Wno-system-headers -o .cctest .cctest.c 2>>config.log
	if [ $? = 0 ]; then
		cc_is_gcc3=yes
    	echo "gcc3" >> config.log
	else
    	echo "gcc" >> config.log
	fi
else
    echo "ok" >> config.log
fi
echo "yes"

rm -f .cctest .cctest.c
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
