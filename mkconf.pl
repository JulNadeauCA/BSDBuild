#!/usr/bin/perl

# $Csoft$
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
		    SHEcho("*** This package requires X11") . "\n " .
		    SHFail("Cannot find X11");
	}

	print SHNEcho("checking for x11..."), "\n";
	while ($dir = shift(@_)) {
	    print SHTest("-d $dir",
		SHDefine('XFOUND', $dir) . ' ' .
		SHDefine('X11_CFLAGS', "'-I $dir/include'") . ' ' .
		SHDefine('X11_LIBS', "'-L $dir/lib'"),
		SHDefine('XNOTFOUND', $dir));
	}
	print SHTest('"$XFOUND" != ""',
	    SHEcho('$XFOUND') . "\n " .
	        SHSave('X11BASE') . ' ' .
	        SHSave('X11_CFLAGS') . ' ' .
	        SHSave('X11_LIBS'),
	    SHEcho("missing") . $require);

	return (0);
}

sub SDL
{
	my ($ver) = @_;
	my $require = '';
	
	if ($REQUIRE) {
		$require =
		    SHEcho("*** This package requires SDL >= $ver") . "\n " .
		    SHEcho("*** Get it from http://www.libsdl.org/") . "\n " .
		    SHFail("Missing SDL");
	}
	
	print SHNEcho("checking for SDL >= $ver..."), "\n";

	print SHObtain('sdl-config', '--version', 'SDL_VERSION');
	print SHObtain('sdl-config', '--cflags', 'SDL_CFLAGS');
	print SHObtain('sdl-config', '--libs', 'SDL_LIBS');

	print SHTest('"$SDL_VERSION" != ""',
	    SHEcho("ok"),
	    SHEcho("missing") . "\n " . $require);

	return (0);
}

sub smpeg
{
	my ($ver) = @_;
	my $require = '';
	
	if ($REQUIRE) {
		$require =
		    SHEcho("*** This package requires smpeg >= $ver") . "\n " .
		    SHEcho("*** Get it from http://www.icculus.org/") . "\n " .
		    SHFail("Missing smpeg");
	}
	
	print SHNEcho("checking for smpeg >= $ver..."), "\n";

	print SHObtain('smpeg-config', '--version', 'SMPEG_VERSION');
	print SHObtain('smpeg-config', '--cflags', 'SMPEG_CFLAGS');
	print SHObtain('smpeg-config', '--libs', 'SMPEG_LIBS');

	print SHTest('"$SMPEG_VERSION" != ""',
	    SHEcho("ok"),
	    SHEcho("missing") . "\n " . $require);

	return (0);
}

sub glib
{
	my ($ver) = @_;
	my $require = '';
	
	if ($REQUIRE) {
		$require =
		    SHEcho("*** This package requires glib >= $ver") . "\n " .
		    SHEcho("*** Get it from http://www.gtk.org/") . "\n " .
		    SHFail("Missing glib");
	}
	
	print SHNEcho("checking for glib >= $ver..."), "\n";

	print SHObtain('glib-config', '--version', 'GLIB_VERSION');
	print SHObtain('glib-config', '--cflags', 'GLIB_CFLAGS');
	print SHObtain('glib-config', '--libs', 'GLIB_LIBS');

	print SHTest('"$GLIB_VERSION" != ""',
	    SHEcho("ok") . "\n " .
	        SHSave('GLIB_CFLAGS') . "\n " .
		SHSave('GLIB_LIBS'),
	    SHEcho("missing") . "\n " . $require);

	return (0);
}

sub SHEcho
{
	my $msg = shift;

	return "echo \"$msg\";";
}

sub SHNEcho
{
	my $msg = shift;

	return "echo -n \"$msg\";";
}

sub SHFail
{
	my $msg = shift;

	return "echo \"ERROR: $msg\";\n exit 1";
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

    return $s;
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

	return qq{
if [ $cond ]; then
 $yese
else
 $noe
fi
};
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
			if ($s =~ /(\w+)\((.+)\)/) {
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
				} elsif ($1 eq 'makeout') {
				    $makeout = $args[0];
				    if (open(MOUT, ">$makeout")) {
					print MOUT
					    "# Generated: do not edit.\n";
					close(MOUT);
				    }
				} elsif ($1 eq 'inclout') {
				    $inclout = $args[0];
				    if (open(MOUT, ">$inclout")) {
					print MOUT
					    "/* Generated: do not edit. */\n";
					close(MOUT);
				    }
				}
			}
		}
	}
}

