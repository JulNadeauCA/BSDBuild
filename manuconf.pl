#!/usr/bin/perl -I/home/vedge/src/csoft-mk
#
# $Csoft: manuconf.pl,v 1.11 2002/02/25 10:18:19 vedge Exp $
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
	my $hopt = $arg;

	$hopt =~ s/^\-\-//;
	if ($hopt =~ /^(with|without|enable|disable)/) {
		$hopt =~ s/^(with|without|enable|disable)\-//;
		$hopt = "$1_$hopt";
	}
	$hopt = uc($hopt);

	my $darg = pack('A' x 20, split('', $arg));

	push @HELP, "echo \"    $darg $descr\"";
	print "for OPT in \$@; do\n";
	print
	    SHTest("\"\$OPT\" = \"$arg\"",
	    SHDefine($hopt, 1) .
	        SHMKSave($hopt),
	    SHNothing());
	print "done\n";
}

sub Help
{
    my $darg = pack('A' x 20, split('', '--prefix'));
    my $descr = 'Installation prefix [/usr/local]';
    my $regs = join("\n", "echo \"    $darg $descr\"", @HELP);

    print << "EOF";
echo "Usage: ./configure [args]"
$regs
EOF
}

sub Version
{
    print << "EOF";
echo "Manuconf v${VERSION}"
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
# Copyright (c) 2001, CubeSoft Communications, Inc.
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
for D in \$@; do
LPREFIX="`echo \$D | awk -F= '{ print \$1 }'`"
RPREFIX="`echo \$D | awk -F= '{ print \$2 }'`"
if [ "\$LPREFIX" = "--prefix" ]; then
PREFIX=\$RPREFIX
fi
done
if [ "\$PREFIX" = "" ]; then
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

