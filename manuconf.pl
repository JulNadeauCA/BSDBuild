#!/usr/bin/perl -I%PREFIX%/share/csoft-mk
#
# $Csoft: manuconf.pl,v 1.24 2002/11/28 03:58:54 vedge Exp $
#
# Copyright (c) 2001, 2002 CubeSoft Communications, Inc. <http://www.csoft.org>
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
#
use Manuconf::Core;

sub MDefine;

sub Register;
sub Help;
sub Version;

sub MDefine
{
	my ($def, $val) = @_;

	print
	    Define($def, $val) .
	    MKSave($def);
}

sub Register
{
	my ($arg, $descr) = @_;
	$arg =~ /\"(.*)\"/;
	$arg = $1;
	$descr =~ /\"(.*)\"/;
	$descr = $1;

	my $darg = pack('A' x 30, split('', $arg));
	push @HELP, "echo \"    $darg $descr\"";
}

sub Help
{
    my $prefix_opt = pack('A' x 30, split('', '--prefix'));
    my $prefix_desc = 'Installation prefix [/usr/local]';
    my $srcdir_opt = pack('A' x 30, split('', '--srcdir'));
    my $srcdir_desc = 'Source tree for concurrent builds [.]';

    my $regs = join("\n",
        "echo \"    $prefix_opt $prefix_desc\"",
        "echo \"    $srcdir_opt $srcdir_desc\"",
	@HELP);

    print << "EOF";
echo "Usage: ./configure [args]"
$regs
exit 1
EOF
}

sub Version
{
    print << "EOF";
echo "Csoft-mk ${CSOFT_MK_VERSION}"
exit 1
EOF
}

BEGIN
{
	$INSTALLDIR = '%PREFIX%/share/csoft-mk';
	$CSOFT_MK_VERSION = 	'1.5';

	print << "EOF";
#!/bin/sh
#
# Do not edit!
# File generated from configure.in by csoft-mk ${CSOFT_MK_VERSION}.
#
EOF

	print << 'EOF';
# Copyright (c) 2001, 2002, CubeSoft Communications, Inc. <http://www.csoft.org>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistribution of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Neither the name of CubeSoft Communications, nor the names of
#    its contributors may be used to endorse or promote products derived
#    from this software without specific prior written permission.
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

optarg=
for arg; do
	case "$arg" in
	-*=*)
	    optarg=`echo "$arg" | sed 's/[-_a-zA-Z0-9]*=//'`
	    ;;
	*)
	    optarg=
	    ;;
	esac

	case "$arg" in
	--prefix=*)
	    prefix=$optarg
	    ;;
	--enable-*)
	    option=`echo $arg | sed -e 's/--enable-//' -e 's/=.*//'`
	    option=`echo $option | sed 's/-/_/g'`
	    case "$option" in
	        *=*)
	            eval "enable_${option}='$optarg'"
		    ;;
		*)
	            eval "enable_${option}=yes"
		    ;;
	    esac
	    ;;
	--disable-*)
	    option=`echo $arg | sed -e 's/--disable-//'`;
	    option=`echo $option | sed 's/-/_/g'`
	    eval "enable_${option}=no"
	    ;;
	--with-*)
	    option=`echo $arg | sed -e 's/--with-//' -e 's/=.*//'`
	    option=`echo $option | sed 's/-/_/g'`
	    case "$option" in
	        *=*)
	            eval "with_${option}='$optarg'"
		    ;;
		*)
	            eval "with_${option}=yes"
		    ;;
	    esac
	    ;;
	--without-*)
	    option=`echo $arg | sed -e 's/--without-//'`;
	    option=`echo $option | sed 's/-/_/g'`
	    eval "with_${option}=no"
	    ;;
	--help)
	    help=yes
	    ;;
	--srcdir=*)
	    srcdir=$optarg
	    ;;
	*)
	    echo "invalid argument: $arg"
	    echo "try ./configure --help"
	    exit 1
	    ;;
	esac
done
if [ "${prefix}" != "" ]; then
    PREFIX=$prefix
else
    PREFIX=/usr/local
fi

if [ "${srcdir}" != "" ]; then
	echo "concurrent build (source in ${srcdir})"
	if [ ! -e "${srcdir}" ]; then
		echo "Cannot find source directory: ${srcdir}"
		exit 1
	fi
	if [ ! -e "${srcdir}/configure.in" ]; then
		echo "Invalid source directory: ${srcdir}"
		exit 1
	fi
	SRC=${srcdir}

	perl ${SRC}/mk/mkconcurrent.pl ${SRC}
else
	if [ ! -e "configure.in" ]; then
		echo "Missing --srcdir argument"
		exit 1
	fi
	SRC=`pwd`
fi

echo > config.log

EOF
	while (<STDIN>) {
		chop;
		if (/^#/) {
		    next;
		}
		foreach my $s (split(';')) {
			if ($s =~ /(\w+)\((.*)\)/) {
				my @args = ();
				foreach my $arg (split(',', $2)) {
					$arg =~ s/^\s+//;
					$arg =~ s/\s+$//;
					push @args, $arg;
				}
				$REQUIRE = 0;
				if ($1 eq 'check' or $1 eq 'require') {
					my $app = shift(@args);
					my $mod =
					  "$INSTALLDIR/Manuconf/${app}.pm";
					
					unless (-e $mod) {
						print STDERR "$mod: $!\n";
						exit (1);
					}
					do($mod);
					if ($@) {
						print STDERR $@;
						exit (1);
					}
					my $c = $TESTS{$app};
					die "missing test" unless $c;
					print STDERR
					    "+ $app: $DESCR{$app}\n";

					print NEcho(
					"checking for $DESCR{$app}...");
					
					print Log(
					"checking for $DESCR{$app}...");

					&$c(@args);
				} elsif ($1 eq 'register') {
				    Register(@args);
				} elsif ($1 eq 'help') {
				    Help(@args);
				} elsif ($1 eq 'makeout') {
				    $CONF{'makeout'} = $args[0];
				    print "echo >$CONF{'makeout'}\n";
				} elsif ($1 eq 'mdefine') {
				    MDefine(@args);
				} elsif ($1 eq 'hdefine') {
				    print Define($args[0], $args[1]) .
				          HDefine($args[0]);
				} elsif ($1 eq 'hundef') {
					print HUndef($args[0]);
				} elsif ($1 eq 'inclout') {
				    $CONF{'inclout'} = $args[0];
				    print << "EOF";
if [ ! -e "$CONF{'inclout'}" ]; then
	mkdir $CONF{'inclout'}
	if [ \$? != 0 ]; then
		exit 1
	fi
fi
EOF
				} elsif ($1 eq 'exit') {
				    print "exit $args[0]\n";
				}
			} else {
				print $s, "\n";
			}
		}
	}
	print MKSave('PREFIX'), HDefineString('PREFIX');
	print Echo("Don't forget to run \\\"make depend\\\".");
}

