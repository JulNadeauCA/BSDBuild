# vim:ts=4
#
# Copyright (c) 2002-2007 Hypertriton, Inc. <http://hypertriton.com/>
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

# Read the output of a program into a variable.
# Set an empty string if the binary is not found.
sub ReadOut
{
	my ($bin, $args, $define) = @_;

	return << "EOF";
$define=""
for path in `echo \$PATH | sed 's/:/ /g'`; do
	if [ -x "\${path}/$bin" ]; then
		$define=`\${path}/$bin $args`
	fi
done
EOF
}
sub MkExecOutput { print ReadOut(@_); }

# Return the absolute path name of a binary into a variable.
# Set an empty string if the binary is not found.
sub Which
{
	my ($bin, $args, $define) = @_;

	return << "EOF";
$define=""
for path in `echo \$PATH | sed 's/:/ /g'`; do
	if [ -x "\${path}/$bin" ]; then
		$define=`\${path}/$bin $args`
	fi
done
EOF
}

sub Cond
{
	my ($cond, $yese, $noe) = @_;

	return << "EOF";
if [ $cond ]; then
${yese}else
${noe}fi
EOF
}

sub Define
{
	my ($arg, $val) = @_;

	return "$arg=$val\n";
}

sub MkDefine
{
	my ($arg, $val) = @_;

	print "$arg=\"$val\"\n";
}

sub Echo
{
	my $msg = shift;

	$msg =~ s/["]/\"/g;
	return << "EOF";
echo "$msg"
echo "$msg" >> config.log
EOF
}

sub MkPrint
{
	my $msg = shift;

	$msg =~ s/["]/\"/g;
	print << "EOF";
echo "$msg"
echo "$msg" >> config.log
EOF
}

sub NEcho
{
	my $msg = shift;

	$msg =~ s/["]/\"/g;			# Escape quotes
	return << "EOF";
echo -n "$msg"
echo -n "$msg" >> config.log
EOF
}

sub MkPrintN
{
	my $msg = shift;

	$msg =~ s/["]/\"/g;
	print << "EOF";
echo -n "$msg"
echo -n "$msg" >> config.log
EOF
}

sub Log
{
	my $msg = shift;

	$msg =~ s/["]/\"/g;							# Escape quotes
	return "echo \"$msg\" >> config.log\n";
}

sub Fail
{
	my $msg = shift;
    
	$msg =~ s/["]/\"/g;							# Escape quotes
	return << "EOF";
echo \"$msg\"
exit 1
EOF
}

sub MKSave
{
    my $var = shift;
    my $s = '';
   
	$s = "echo \"$var=\$$var\" >> Makefile.config\n";
    return ($s);
}

sub MkSaveMK
{
	foreach my $var (@_) {
		print "echo \"$var=\$$var\" >> Makefile.config\n";
	}
}

sub HDefine
{
    my $var = shift;
	my $include = 'config/'.lc($var).'.h';

	return << "EOF";
echo "#ifndef $var" > $include
echo "#define $var" \$$var >> $include
echo "#endif" >> $include
EOF
}

sub HDefineBool
{
    my $var = shift;
	my $include = 'config/'.lc($var).'.h';

	return << "EOF";
echo "#ifndef $var" > $include
echo "#define $var 1" >> $include
echo "#endif" >> $include
EOF
}

sub HUndef
{
    my $var = shift;
	my $include = 'config/'.lc($var).'.h';

	return << "EOF";
echo "#undef $var" > $include
EOF
}

sub MkSaveUndef
{
	foreach my $var (@_) {
		my $include = 'config/'.lc($var).'.h';
		print << "EOF";
echo "#undef $var" > $include
EOF
	}
}

sub HDefineStr
{
    my $var = shift;
	my $include = 'config/'.lc($var).'.h';
	return << "EOF";
echo "#ifndef $var" > $include
echo "#define $var \\\"\$$var\\\"" >> $include
echo "#endif" >> $include
EOF
}

sub MkSaveDefine
{
	foreach my $var (@_) {
		my $include = 'config/'.lc($var).'.h';
		print << "EOF";
echo "#ifndef $var" > $include
echo "#define $var \\\"\$$var\\\"" >> $include
echo "#endif" >> $include
EOF
	}
}

sub Nothing
{
    return "NONE=1\n";
}

sub TryCompile
{
	my $def = shift;

	while (my $code = shift) {
		print << "EOF";
cat << EOT > conftest.c
$code
EOT
EOF
		print << 'EOF';
compile="ok"
echo "$CC $CFLAGS $TEST_CFLAGS -o conftest conftest.c" >>config.log
$CC $CFLAGS $TEST_CFLAGS -o conftest conftest.c 2>>config.log
if [ $? != 0 ]; then
	echo "-> failed ($?)" >> config.log
	compile="failed"
fi
rm -f conftest conftest.c
EOF

		my $define = HDefine($def);
		my $undef = HUndef($def);

		print << "EOF";
if [ "\${compile}" = "ok" ]; then
	echo "ok" >> config.log
	$define
	$def="yes"
	echo "yes"
else
    $undef
	$def="no"
	echo "no"
fi
EOF
	}
}

sub MkCompileAndRunC
{
	my $define = shift;
	my $cflags = shift;
	my $libs = shift;
	my $code = shift;

	print << "EOF";
cat << EOT > conftest.c
$code
EOT
EOF
	print << "EOF";
echo "\$CC \$CFLAGS \$TEST_CFLAGS $cflags -o conftest conftest.c $libs" >>config.log
\$CC \$CFLAGS \$TEST_CFLAGS $cflags -o conftest conftest.c $libs 2>>config.log
if [ \$? != 0 ]; then
	echo "-> failed (\$?)" >> config.log
	compile="failed"
else
	compile="ok"
	./conftest >> config.log
	if [ \$? != 0 ]; then
		echo "-> exec failed (\$?)" >> config.log
		$define="no"
	else
		$define="yes"
	fi
fi
rm -f conftest conftest.c
EOF
}

sub TryCompileFlags
{
	my $def = shift;
	my $flags = shift;

	while (my $code = shift) {
		print << "EOF";
cat << EOT > conftest.c
$code
EOT
EOF
		print << "EOF";
compile="ok"
echo "\$CC \$CFLAGS \$TEST_CFLAGS $flags -o conftest conftest.c" >>config.log
\$CC \$CFLAGS \$TEST_CFLAGS $flags -o conftest conftest.c 2>>config.log
if [ \$? != 0 ]; then
	echo "-> failed (\$?)" >> config.log
	compile="failed"
fi
rm -f conftest conftest.c
EOF

		my $define = HDefine($def);
		my $undef = HUndef($def);

		print << "EOF";
if [ "\${compile}" = "ok" ]; then
	echo "ok" >> config.log
	$define
	echo "yes"
else
    $undef
	echo "no"
fi
EOF
	}
}

sub MkIf { print 'if [ ',shift,' ]; then',"\n"; }
sub MkElif { print 'elif [ ',shift,' ]; then',"\n"; }
sub MkElse { print 'else',"\n"; }
sub MkEndif { print 'fi;',"\n"; }

sub MkCompileC
{
	my $def = shift;
	my $cflags = shift;
	my $libs = shift;

	while (my $code = shift) {
		print << "EOF";
cat << EOT > conftest.c
$code
EOT
EOF
		print << "EOF";
compile=\"ok\"
echo "\$CC \$CFLAGS \$TEST_CFLAGS $cflags -o conftest conftest.c $libs" >>config.log
\$CC \$CFLAGS \$TEST_CFLAGS $cflags -o conftest conftest.c $libs 2>>config.log
EOF

		print << 'EOF';
if [ $? != 0 ]; then
	echo "failed ($?)" >> config.log
	compile="failed"
fi
rm -f conftest conftest.c
EOF

		my $hdefine = HDefine($def);
		my $hundefine = HUndef($def);
		my $define = Define($def, 'yes');

		print << "EOF";
if [ "\${compile}" = "ok" ]; then
	echo "ok" >> config.log
	$hdefine
	$define
	echo "yes"
else
	$hundefine
	echo "no"
fi
EOF
	}
}

BEGIN
{
    require Exporter;
    $| = 1;
    $^W = 0;

    @ISA = qw(Exporter);
    @EXPORT = qw(%TESTS %DESCR ReadOut MkExecOutput Which Cond Define Echo Necho Fail MKSave HDefine HDefineStr HDefineBool HUndef Nothing TryCompile MkCompileC MkCompileAndRunC TryCompileFlags Log MkDefine MkIf MkElif MkElse MkEndif MkSaveMK MkSaveDefine MkSaveUndef MkPrint MkPrintN);
}

;1
