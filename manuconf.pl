#!/usr/bin/perl

# $Csoft: mkconf.pl,v 1.1 2002/01/26 19:47:47 vedge Exp $
# vim:ai:sw=4:bs=2:sts=4:syn=perl
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

sub x11;
sub SDL;
sub smpeg;
sub glib;

sub Register;
sub SHEcho;
sub SHNEcho;
sub SHSave;
sub SHDefine;
sub SHObtain;
sub SHTest;

sub x11
{
	my $require = '';
	
	if ($REQUIRE) {
		$require =
		    SHEcho("*** This package requires X11") .
		        SHFail("Cannot find X11");
	}

	print SHNEcho("checking for x11...");
	while ($dir = shift(@_)) {
	    print SHTest("-d $dir",
		SHDefine('XFOUND', $dir) .
		    SHDefine('X11_CFLAGS', "-I$dir/include") .
		    SHDefine('X11_LIBS', "-L$dir/lib"),
		SHDefine('XNOTFOUND', $dir));
	}
	print SHTest('"$XFOUND" != ""',
	    SHEcho('$XFOUND') . 
	        SHSave('X11BASE') . 
	        SHSave('X11_CFLAGS') . 
	        SHSave('X11_LIBS'),
	    SHEcho("missing") .
	        $require);

	return (0);
}

sub SDL
{
	my ($ver) = @_;
	my $require = '';
	
	if ($REQUIRE) {
		$require =
		    SHEcho("*** This package requires SDL >= $ver") . 
		        SHEcho("*** Get it from http://www.libsdl.org/") . 
		        SHFail("Missing SDL");
	}
	
	print SHNEcho("checking for SDL >= $ver...");

	print SHObtain('sdl-config', '--version', 'SDL_VERSION');
	print SHObtain('sdl-config', '--cflags', 'SDL_CFLAGS');
	print SHObtain('sdl-config', '--libs', 'SDL_LIBS');
	print SHObtain('sdl11-config', '--version', 'SDL11_VERSION');
	print SHObtain('sdl11-config', '--cflags', 'SDL11_CFLAGS');
	print SHObtain('sdl11-config', '--libs', 'SDL11_LIBS');

	print SHTest('"$SDL_VERSION" != ""',
	    SHDefine('SDL_FOUND', 'yes') .
	        SHSave('SDL_CFLAGS') .
	        SHSave('SDL_LIBS'),
	    "false\n");
	print SHTest('"$SDL11_VERSION" != ""',
	    SHDefine('SDL_FOUND', 'yes') .
	        SHDefine('SDL_CFLAGS', '$SDL11_CFLAGS') .
	        SHDefine('SDL_LIBS', '$SDL11_LIBS') .
	        SHSave('SDL_CFLAGS') .
	        SHSave('SDL_LIBS'),
	    "false\n");
	print SHTest('"$SDL_FOUND" = "yes"',
	    SHEcho('ok'),
	    SHEcho("missing") .
	        $require);

	return (0);
}

sub smpeg
{
	my ($ver) = @_;
	my $require = '';
	
	if ($REQUIRE) {
		$require =
		    SHEcho("*** This package requires smpeg >= $ver") .
		        SHEcho("*** Get it from http://www.icculus.org/") .
		        SHFail("Missing smpeg");
	}
	
	print SHNEcho("checking for smpeg >= $ver...");

	print SHObtain('smpeg-config', '--version', 'SMPEG_VERSION');
	print SHObtain('smpeg-config', '--cflags', 'SMPEG_CFLAGS');
	print SHObtain('smpeg-config', '--libs', 'SMPEG_LIBS');

	print SHTest('"$SMPEG_VERSION" != ""',
	    SHEcho("ok") . 
	        SHSave('SMPEG_CFLAGS') .
	        SHSave('SMPEG_LIBS'),
	    SHEcho("missing") .
	        $require);

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
	
	print SHTest('"$GLIB_VERSION" != ""',
	    SHDefine('GLIB_FOUND', 'yes') .
	        SHSave('GLIB_CFLAGS') .
	        SHSave('GLIB_LIBS'),
	    "false\n");
	print SHTest('"$GLIB12_VERSION" != ""',
	    SHDefine('GLIB_FOUND', 'yes') .
	        SHDefine('GLIB_CFLAGS', '$GLIB12_CFLAGS') .
	        SHDefine('GLIB_LIBS', '$GLIB12_LIBS') .
	        SHSave('GLIB_CFLAGS') .
	        SHSave('GLIB_LIBS'),
	    "false\n");
	print SHTest('"$GLIB_FOUND" = "yes"',
	    SHEcho('ok'),
	    SHEcho("missing") .
	        $require);

	return (0);
}

sub Register
{
    my ($arg, $descr) = @_;
    $arg =~ /\"(.*)\"/;
    $arg = $1;
    $descr =~ /\"(.*)\"/;
    $descr = $1;
    my $hopt = $arg;

    $hopt =~ s/^\-\-(with|without|enable|disable)\-//;
    $hopt = "$1_$hopt";
    $hopt = uc($hopt);

    $arg = pack('A' x 20, split('', $arg));

    push @HELP, "echo \"    $arg $descr\"";
    print "for OPT in \$@; do\n";
    print SHTest("\"\$OPT\" = \"$arg\"",
        SHDefine($hopt, 1) .
	    SHSave($hopt),
	"false\n");
    print "done\n";
}

sub Help
{
    my $regs = join("\n", @HELP);

    print << "EOF";
echo "Usage: ./configure [args]"
$regs
EOF
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

	return qq{
echo \"ERROR: $msg\"
exit 1
};
}

sub SHSave
{
    my $var = shift;
    my $s = '';
   
    if ($makeout) {
	$s = "echo $var=\$$var >> $makeout\n";
    }
    if ($inclout) {
	$s = q{
echo #ifndef $var
echo #define $var \"\$$var\" >> $inclout";
echo #endif /* $var */
}
    }

    return ($s);
}

sub SHDefine
{
	my ($def, $val) = @_;

	return "$def=$val\n";
}

sub SHObtain
{
	my ($bin, $args, $define) = @_;

	return "$define=`$bin $args 2>/dev/null`\n";
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
	$CHECK{'x11'} = \&x11;
	$CHECK{'SDL'} = \&SDL;
	$CHECK{'glib'} = \&glib;
	$CHECK{'smpeg'} = \&smpeg;

	print "#!/bin/sh\n";
	print "# Do not edit: File generated from configure.in\n";

	while (<STDIN>) {
		chop;
		if (/^#/) {
		    next;
		}
		foreach my $s (split(';')) {
			if ($s =~ /if\s*\((.+)\)\s*\{/) {
			    print "if [ $1 ]; then\n";
			} elsif ($s =~ /^\} else \{$/) {
			    print "else\n";
			} elsif ($s =~ /^\} else if\s*\((.+)\)\s*\{$/) {
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
				} elsif ($1 eq 'makeout') {
				    $makeout = $args[0];
				    print "echo >$makeout\n";
				} elsif ($1 eq 'inclout') {
				    print "echo >$inclout\n";
				} elsif ($1 eq 'exit') {
				    print "exit $args[0]\n";
				}
			}
		}
	}
}

