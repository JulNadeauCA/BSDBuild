# $Csoft: Core.pm,v 1.2 2002/05/13 07:41:37 vedge Exp $
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

sub Obtain
{
    my ($bin, $args, $define) = @_;

	return << "EOF"
$define=""
for i in `echo \$PATH |sed 's/:/ /g'`; do
	if [ -x "\${i}/$bin" ]; then
		$define=`\${i}/$bin $args`
	fi
done
EOF
}

sub Test
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

	return "echo \"$msg\"\n";
}

sub NEcho
{
	my $msg = shift;

	return "echo -n \"$msg\"\n";
}

sub Fail
{
	my $msg = shift;
    
	unless ($REQUIRE) {
		return Nothing();
	}

	return << "EOF";
echo \"ERROR: $msg\"
exit 1
EOF
}

sub MKSave
{
    my $var = shift;
    my $s = '';
   
    if ($CONF{'makeout'}) {
	$s = "echo $var=\$$var >> $CONF{'makeout'}\n";
    } else {
	print STDERR "mdefine: not saving `$var'\n";
    }
    return ($s);
}

sub HSave
{
    my $var = shift;
    my $s = '';

    if ($CONF{'inclout'}) {
	$s = << "EOF"
echo "#ifndef $var" >> $CONF{'inclout'}
echo "#define $var" \$$var >> $CONF{'inclout'}
echo "#endif /* $var */" >> $CONF{'inclout'}
EOF
    } else {
	print STDERR "hdefine: not saving `$var'\n";
    }
    return ($s);
}

sub HSaveS
{
    my $var = shift;
    my $s = '';

    if ($CONF{'inclout'}) {
	$s = << "EOF"
echo "#ifndef $var" >> $CONF{'inclout'}
echo "#define $var \\\"\$$var\\\"" >> $CONF{'inclout'}
echo "#endif /* $var */" >> $CONF{'inclout'}
EOF
    } else {
	print STDERR "mdefine: not saving `$var'\n";
    }
    return ($s);
}

sub Nothing
{
    return "NONE=1\n";
}


BEGIN
{
    require Exporter;
    $| = 1;
    $^W = 0;

    @ISA = qw(Exporter);
    @EXPORT = qw(%TESTS %DESCR Obtain Test Define Require Echo Necho Fail MKSave HSave HSaveS Nothing);
}

;1
