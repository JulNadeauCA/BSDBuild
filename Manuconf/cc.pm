# $Csoft: cc.pm,v 1.9 2002/11/28 09:50:42 vedge Exp $
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

echo "$CC -o .cctest .cctest.c" >>config.log
$CC -o .cctest .cctest.c 2>>config.log
if [ $? != 0 -o ! -e .cctest ]; then
    echo "-> failure" >> config.log
    echo "no"
    exit 1
fi

cc_is_gcc=no
if ./.cctest; then
    cc_is_gcc=yes
    echo "-> success: gcc" >> config.log
    echo "yes"
else
    echo "yes"
    echo "-> success" >> config.log
fi

rm -f .cctest .cctest.c
EOF

	# Check for float type.
	print NEcho('checking for float...');
	TryCompile 'HAVE_FLOAT', << 'EOF';
#include <stdio.h>

int
main(int argc, char *argv[])
{
	float f = 0.1;

	printf("%f\n", f);
	return (0);
}
EOF
	
	# Check for double type.
	print NEcho('checking for double...');
	TryCompile 'HAVE_DOUBLE', << 'EOF';
int
main(int argc, char *argv[])
{
	double d = 0.1;
	
	printf("%f\n", d);
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
