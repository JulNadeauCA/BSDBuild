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

#
# Uses: ${CC}
# Defines: ${GCC} if ${CC} is gcc.
#
sub Test
{
	my $require = shift;

	print << 'EOF';
# $Csoft$

if [ "$CC" = "" ]; then
    if [ -x "`which cc`" ]; then
        CC=cc
    elif [ -x "`which gcc`" ]; then
        CC=gcc
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

$CC -o .cctest .cctest.c
if [ $? != 0 -o ! -e .cctest ]; then
    echo "no"
    rm -f .cctest .cctest.c
    exit 1
fi

if ./.cctest; then
    GCC=Yes
    echo "yes, gcc"
else
    echo "yes"
fi

rm -f .cctest .cctest.c
EOF
}

BEGIN
{
	$TESTS{'cc'} = \&Test;
	$DESCR{'cc'} = 'a usable C compiler';
}

;1
