#!/usr/bin/perl -I/home/vedge/src/csoft-mk
#
# $Csoft: manuconf.pl,v 1.13 2002/05/05 23:42:14 vedge Exp $
#
# Copyright (c) 2001 CubeSoft Communications, Inc.
# <http://www.csoft.org>
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
use Manuconf::Core;

sub MDefine;
sub HDefine;

sub Register;
sub Help;
sub Version;

sub MDefine
{
	my ($def, $val) = @_;

	print
	    SHDefine($def, $val) .
	    SHMKSave($def);
}

sub HDefine
{
	my ($def, $val) = @_;

	print
	    SHDefine($def, $val) .
	    SHHSave($def);
}

sub Register
{
	my ($arg, $descr) = @_;
	$arg =~ /\"(.*)\"/;
	$arg = $1;
	$descr =~ /\"(.*)\"/;
	$descr = $1;

	my $darg = pack('A' x 20, split('', $arg));
	push @HELP, "echo \"    $darg $descr\"";
}

sub Help
{
    my $darg = pack('A' x 20, split('', '--prefix'));
    my $descr = 'Installation prefix [/usr/local]';
    my $regs = join("\n", "echo \"    $darg $descr\"", @HELP);

    print << "EOF";
echo "Usage: ./configure [args]"
$regs
exit 1
EOF
}

sub Version
{
    print << "EOF";
echo "Manuconf v${VERSION}"
exit 1
EOF
}

BEGIN
{
    	$VERSION = '1.1';
	$INSTALLDIR = '/home/vedge/src/csoft-mk';

	print << "EOF";
#!/bin/sh
#
# Do not edit!
# File generated from configure.in by manuconf v${VERSION}.
#
EOF

	print << 'EOF';
# Copyright (c) 2001, 2002, CubeSoft Communications, Inc.
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
# 3. Neither the name of CubeSoft Communications, nor the names of
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

mc_last_arg=
mc_optarg=
for mc_arg; do
	if test -n "$mc_last_arg"; then
		eval "$mc_last_arg=\$mc_arg"
		mc_last_arg=
		continue
	fi
	case "$mc_arg" in
	-*=*)
	    mc_optarg=`echo "$mc_arg" | sed 's/[-_a-zA-Z0-9]*=//'`
	    ;;
	*)
	    mc_optarg=
	    ;;
	esac

	case "$mc_arg" in
	--prefix=*)
	    mc_prefix=$mc_optarg
	    ;;
	--enable-*)
	    mc_option=`echo $mc_arg | sed -e 's/--enable-//' -e 's/=.*//'`
	    mc_option=`echo $mc_option | sed 's/-/_/g'`
	    case "$mc_option" in
	        *=*)
	            eval "enable_${mc_option}='$mc_optarg'"
		    ;;
		*)
	            eval "enable_${mc_option}=yes"
		    ;;
	    esac
	    ;;
	--disable-*)
	    mc_option=`echo $mc_arg | sed -e 's/--disable-//'`;
	    mc_option=`echo $mc_option | sed 's/-/_/g'`
	    eval "enable_${mc_option}=no"
	    ;;
	--with-*)
	    mc_option=`echo $mc_arg | sed -e 's/--with-//' -e 's/=.*//'`
	    mc_option=`echo $mc_option | sed 's/-/_/g'`
	    case "$mc_option" in
	        *=*)
	            eval "with_${mc_option}='$mc_optarg'"
		    ;;
		*)
	            eval "with_${mc_option}=yes"
		    ;;
	    esac
	    ;;
	--without-*)
	    mc_option=`echo $mc_arg | sed -e 's/--without-//'`;
	    mc_option=`echo $mc_option | sed 's/-/_/g'`
	    eval "with_${mc_option}=no"
	    ;;
	--help)
	    help=yes
	    ;;
	--version)
	    version=yes
	    ;;
	*)
	    echo "invalid argument: $mc_arg"
	    echo "try ./configure --help"
	    exit 1
	    ;;
	esac
done
if [ "${mc_prefix}" != "" ]; then
    PREFIX=$mc_prefix
else
    PREFIX=/usr/local
fi
EOF
	print SHObtain('pwd', '', 'S');
	while (<STDIN>) {
		chop;
		if (/^#/) {
		    next;
		}
		foreach my $s (split(';')) {
			if ($s =~ /if\s*\((.+)\)\s*\{/) {
			    print "if [ $1 ]; then\n";
			} elsif ($s =~ /^\}\s*else\s*\{$/) {
			    print "else\n";
			} elsif ($s =~ /^\}\s*else if\s*\((.+)\)\s*\{$/) {
			    print "elif [ $1 ]\n";
			} elsif ($s =~ /^\}$/) {
			    print "fi\n";
			}
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
					my $req = 0;
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
					print STDERR
					    "+ $app: $DESCR{$app}\n";

					if ($1 eq 'require') {
						$req++;
					}
					print SHNEcho(
					"checking for $DESCR{$app}...");
					&$c($req, @args);
				} elsif ($1 eq 'register') {
				    Register(@args);
				} elsif ($1 eq 'help') {
				    Help(@args);
				} elsif ($1 eq 'version') {
				    Version(@args);
				} elsif ($1 eq 'makeout') {
				    $CONF{'makeout'} = $args[0];
				    print "echo >$CONF{'makeout'}\n";
				} elsif ($1 eq 'mdefine') {
				    MDefine(@args);
				} elsif ($1 eq 'hdefine') {
				    HDefine(@args);
				} elsif ($1 eq 'inclout') {
				    $CONF{'inclout'} = $args[0];
				    print "echo >$CONF{'inclout'}\n";
				} elsif ($1 eq 'exit') {
				    print "exit $args[0]\n";
				}
			}
		}
	}
	print SHMKSave('PREFIX'), SHHSaveS('PREFIX');
#	print SHEcho("Don't forget to run \\\"make depend\\\".");
}

