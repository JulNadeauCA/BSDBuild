#!/usr/bin/perl
#
# $Csoft: manuconf.pl,v 1.9 2002/02/25 08:51:20 vedge Exp $
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

sub cc;
sub x11;
sub SDL;
sub smpeg;
sub glib;
sub c64bit;

sub MDefine;
sub HDefine;

sub Register;
sub Help;
sub Version;
sub SHEcho;
sub SHNEcho;
sub SHMKSave;
sub SHHSave;
sub SHHSaveS;
sub SHDefine;
sub SHObtain;
sub SHTest;

sub cc
{
	print SHNEcho("checking for gcc...");
	print << 'EOF';
if [ "$CC" = "" ]; then
    CC=cc
fi
cat << 'EOT' > .gcctest.c
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
$CC -o .gcctest .gcctest.c
if ./.test; then
    GCC=Yes
    echo "yes"
else
    echo "no"
fi
rm -f .gcctest .gcctest.c
EOF
	return (0);
}

sub x11
{
	print SHNEcho("checking for x11...");
	while ($dir = shift(@_)) {
	    print
	        SHTest("-d $dir",
		SHDefine('X11BASE', $dir) .
		    SHDefine('CONF_X11', 1) .
		    SHDefine('X11_CFLAGS', "-I$dir/include") .
		    SHDefine('X11_LIBS', "-L$dir/lib"),
		SHNothing());
	}
	print
	    SHTest('"$X11BASE" != ""',
	    SHEcho('$X11BASE') .
		SHHSave('CONF_X11') .
	        SHMKSave('X11BASE') .
	        SHMKSave('X11_CFLAGS') .
	        SHMKSave('X11_LIBS'),
	    SHRequire('X11R6', '3', 'http://www.xfree86.org/'));

	return (0);
}

sub SDL
{
	my ($ver) = @_;

	print SHNEcho("checking for SDL >= $ver...");

	print SHObtain('sdl-config', '--version', 'SDL_VERSION');
	print SHObtain('sdl-config', '--cflags', 'SDL_CFLAGS');
	print SHObtain('sdl-config', '--libs', 'SDL_LIBS');
	print SHObtain('sdl11-config', '--version', 'SDL11_VERSION');
	print SHObtain('sdl11-config', '--cflags', 'SDL11_CFLAGS');
	print SHObtain('sdl11-config', '--libs', 'SDL11_LIBS');

	print
	    SHTest('"$SDL_VERSION" != ""',
	    SHDefine('SDL_FOUND', 'yes') .
	        SHMKSave('SDL_CFLAGS') .
	        SHMKSave('SDL_LIBS'),
	    SHNothing());
	print
	    SHTest('"$SDL11_VERSION" != ""',
	    SHDefine('SDL_FOUND', 'yes') .
	        SHDefine('SDL_CFLAGS', '$SDL11_CFLAGS') .
	        SHDefine('SDL_LIBS', '$SDL11_LIBS') .
	        SHMKSave('SDL_CFLAGS') .
	        SHMKSave('SDL_LIBS'),
	    SHNothing());
	print
	    SHTest('"$SDL_FOUND" = "yes"',
	    SHEcho('ok'),
	    SHRequire('SDL', $ver, 'http://www.libsdl.org/'));

	return (0);
}

sub smpeg
{
	my ($ver) = @_;
	
	print SHNEcho("checking for smpeg >= $ver...");

	print SHObtain('smpeg-config', '--version', 'SMPEG_VERSION');
	print SHObtain('smpeg-config', '--cflags', 'SMPEG_CFLAGS');
	print SHObtain('smpeg-config', '--libs', 'SMPEG_LIBS');

	print
	    SHTest('"$SMPEG_VERSION" != ""',
	    SHEcho("ok") . 
	    	SHHSave('CONF_SMPEG') .
	        SHMKSave('SMPEG_CFLAGS') .
	        SHMKSave('SMPEG_LIBS'),
	    SHRequire('smpeg', $ver, 'http://www.icculus.org/'));

	return (0);
}

sub glib
{
	my ($ver) = @_;
	my $require = '';
	
	if ($REQUIRE) {
		$require =
		    SHEcho("*** This package requires glib >= $ver") .
		    SHEcho("*** Get it from http://www.gtk.org/") .
		    SHFail("Missing glib");
	}
	
	print SHNEcho("checking for glib >= $ver...");

	print SHObtain('glib-config', '--version', 'GLIB_VERSION');
	print SHObtain('glib-config', '--cflags', 'GLIB_CFLAGS');
	print SHObtain('glib-config', '--libs', 'GLIB_LIBS');
	print SHObtain('glib12-config', '--version', 'GLIB12_VERSION');
	print SHObtain('glib12-config', '--cflags', 'GLIB12_CFLAGS');
	print SHObtain('glib12-config', '--libs', 'GLIB12_LIBS');
	
	print
	    SHTest('"$GLIB_VERSION" != ""',
	    SHDefine('GLIB_FOUND', 'yes') .
	        SHMKSave('GLIB_CFLAGS') .
	        SHMKSave('GLIB_LIBS'),
	    SHNothing());
	print
	    SHTest('"$GLIB12_VERSION" != ""',
	    SHDefine('GLIB_FOUND', 'yes') .
	        SHDefine('GLIB_CFLAGS', '$GLIB12_CFLAGS') .
	        SHDefine('GLIB_LIBS', '$GLIB12_LIBS') .
	        SHMKSave('GLIB_CFLAGS') .
	        SHMKSave('GLIB_LIBS'),
	    SHNothing());
	print
	    SHTest('"$GLIB_FOUND" = "yes"',
	    SHEcho('ok'),
	    SHEcho("missing") .
	        $require);

	return (0);
}

sub c64bit
{
	# mega XXX
	print SHObtain('uname', '', 'UNAME');
	print
	    SHTest('"$UNAME" = "IRIX64"',
	    SHDefine('ARCH64', '1') .
	        SHHSave('ARCH64') ,
	    SHNothing());

	print SHObtain('uname', '-m', 'UNAME');
	print
	    SHTest('"$UNAME" = "sparc64"',
	    SHDefine('ARCH64', '1') .
	        SHHSave('ARCH64') ,
	    SHNothing());
}

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

sub SHRequire
{
    my ($pkg, $ver, $home) = @_;

    unless ($REQUIRE) {
	return SHNothing();
    }
    
    my $s = SHEcho("*** $pkg >= $ver is required") . 
	    SHEcho("*** Get it from $home") . 
	    SHFail("$pkg >= $ver is missing");

    return ($s);
}

sub SHEcho
{
	my $msg = shift;

	return "echo \"$msg\"\n";
}

sub SHNEcho
{
	my $msg = shift;

	return "echo -n \"$msg\"\n";
}

sub SHFail
{
	my $msg = shift;

	return << "EOF";
echo \"ERROR: $msg\"
exit 1
EOF
}

sub SHMKSave
{
    my $var = shift;
    my $s = '';
   
    if ($makeout) {
	$s = "echo $var=\$$var >> $makeout\n";
    } else {
	print STDERR "SHMKSave: not saving `$var'\n";
    }
    return ($s);
}

sub SHHSave
{
    my $var = shift;
    my $s = '';

    if ($inclout) {
	$s = << "EOF"
echo "#ifndef $var" >> $inclout
echo "#define $var \$$var" >> $inclout
echo "#endif /* $var */" >> $inclout
EOF
    } else {
	print STDERR "SHMKSave: not saving `$var'\n";
    }
    return ($s);
}

sub SHHSaveS
{
    my $var = shift;
    my $s = '';

    if ($inclout) {
	$s = << "EOF"
echo "#ifndef $var" >> $inclout
echo "#define $var \\\"\$$var\\\"" >> $inclout
echo "#endif /* $var */" >> $inclout
EOF
    } else {
	print STDERR "SHMKSave: not saving `$var'\n";
    }
    return ($s);
}

sub SHNothing
{
    return "NONE=1\n";
}

sub SHDefine
{
    my ($arg, $val) = @_;

    return "$arg=$val\n";
}

sub SHObtain
{
    my ($bin, $args, $define) = @_;

	return << "EOF"
if [ -x "`which $bin`" ]; then
$define=`$bin $args`
else
$define=""
fi
EOF
}

sub SHTest
{
	my ($cond, $yese, $noe) = @_;

	return << "EOF";
if [ $cond ]; then
${yese}else
${noe}fi
EOF
}

BEGIN
{
    	$VERSION = '1.1';

	$CHECK{'cc'} = \&cc;
	$CHECK{'x11'} = \&x11;
	$CHECK{'SDL'} = \&SDL;
	$CHECK{'glib'} = \&glib;
	$CHECK{'smpeg'} = \&smpeg;
	$CHECK{'64bit'} = \&c64bit;

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
					my $c = $CHECK{$app};
					if ($c) {
						if ($1 eq 'require') {
							$REQUIRE++;
						}
						&$c(@args);
					} else {
						print "$app: unknown\n";
						exit (1);
					}
				} elsif ($1 eq 'register') {
				    Register(@args);
				} elsif ($1 eq 'help') {
				    Help(@args);
				} elsif ($1 eq 'version') {
				    Version(@args);
				} elsif ($1 eq 'makeout') {
				    $makeout = $args[0];
				    print "echo >$makeout\n";
				} elsif ($1 eq 'mdefine') {
				    MDefine(@args);
				} elsif ($1 eq 'hdefine') {
				    HDefine(@args);
				} elsif ($1 eq 'inclout') {
				    $inclout = $args[0];
				    print "echo >$inclout\n";
				} elsif ($1 eq 'exit') {
				    print "exit $args[0]\n";
				}
			}
		}
	}
	print SHMKSave('PREFIX'), SHHSaveS('PREFIX');
#	print SHEcho("Don't forget to run \\\"make depend\\\".");
}

