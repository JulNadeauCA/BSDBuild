# $Csoft: Core.pm,v 1.15 2003/08/07 19:36:11 vedge Exp $
# vim:ts=4
#
# Copyright (c) 2002 CubeSoft Communications, Inc. <http://www.csoft.org>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistribution of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Neither the name of CubeSoft Communications, nor the names of its
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

# Read the output of a program into a variable.
# Set an empty string if the binary is not found.
sub ReadOut
{
	my ($bin, $args, $define) = @_;

	return << "EOF"
$define=""
for path in `echo \$PATH | sed 's/:/ /g'`; do
	if [ -x "\${path}/$bin" ]; then
		$define=`\${path}/$bin $args`
	fi
done
EOF
}

# Return the absolute path name of a binary into a variable.
# Set an empty string if the binary is not found.
sub Which
{
	my ($bin, $args, $define) = @_;

	return << "EOF"
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

sub Echo
{
	my $msg = shift;

	$msg =~ s/["]/\"/g;			# Escape quotes
	return << "EOF";
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

sub HDefine
{
    my $var = shift;
	my $include = 'config/'.lc($var).'.h';

	return << "EOF"
echo "#ifndef $var" > $include
echo "#define $var" \$$var >> $include
echo "#endif /* $var */" >> $include
EOF
}

sub HUndef
{
    my $var = shift;
	my $include = 'config/'.lc($var).'.h';

	return << "EOF"
echo "#undef $var" > $include
EOF
}

sub HDefineString
{
    my $var = shift;
	my $include = 'config/'.lc($var).'.h';
	return << "EOF"
echo "#ifndef $var" > $include
echo "#define $var \\\"\$$var\\\"" >> $include
echo "#endif /* $var */" >> $include
EOF
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
$CC -o conftest conftest.c 2>>config.log
if [ $? != 0 ]; then
	echo "-> failed: non-zero exit status" >> config.log
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

sub TryLibCompile
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
\$CC $cflags -o conftest conftest.c $libs 2>>config.log
EOF

		print << 'EOF';
if [ $? != 0 ]; then
	echo "failed" >> config.log
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
    @EXPORT = qw(%TESTS %DESCR ReadOut Which Cond Define Echo Necho Fail MKSave HDefine HDefineString HUndef Nothing TryCompile Log);
}

;1
