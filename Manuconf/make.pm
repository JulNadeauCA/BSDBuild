# $Csoft: make.pm,v 1.2 2002/06/12 23:05:59 vedge Exp $
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
	print << 'EOF';
if [ "$MAKE" = "" ]; then
	for i in `echo $PATH |sed 's/:/ /g'`; do
		if [ -x "${i}/make" ]; then
			MAKE="${i}/make"
		elif [ -x "${i}/make" ]; then
			MAKE="${i}/make"
		fi
	done
fi

cat << 'EOT' > .maketest
ASSIGN= foo
ASSIGN?= foo
ASSIGN+= bar

all: write-test

write-test:
	@echo > .maketest2

.BEGIN:
	@echo -n

TOP=	.
include ${TOP}/.maketest3
EOT

echo >> .maketest3

echo "$MAKE -f .maketest" >>config.log
$MAKE -f .maketest 2>>config.log
if [ $? != 0 -o ! -e .maketest2 ]; then
    echo "-> failure" >> config.log
    echo "no"
    exit 1
else
    echo "yes"
    echo "-> success" >> config.log
fi
rm -f .maketest .maketest2 .maketest3
EOF
}

BEGIN
{
	$TESTS{'make'} = \&Test;
	$DESCR{'make'} = 'a usable make(1)';
}

;1
