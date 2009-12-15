#!/usr/bin/perl -I%PREFIX%/share/bsdbuild
#
# Copyright (c) 2007-2009 Hypertriton, Inc. <http://hypertriton.com>
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
#
# manreader.cgi - CGI interface to ManReader.
#
use strict;
use CGI qw/:standard/;

use ManReader::Mdoc;

my $HEADER_FILE = 'header.html.en';
my $FOOTER_FILE = 'footer.html.en';
my $HEADER_PRINTABLE = 'header_pr.html.en';
my $FOOTER_PRINTABLE = 'footer_pr.html.en';
my $COLOR_FILE = 'base/colors.m4';
my $ROOT_DIR = '/home/vedge/src';

# These directories will be scanned for mdoc source files.
my @MANPATH = (
    'agar/agarpaint',
    'agar/agarrcsd',
    'agar/core',
    'agar/dev',
    'agar/gui',
    'agar/map',
    'agar/math',
    'agar/net',
    'agar/rg',
    'agar/vg',
    'agar/p5-Agar',
    'agar/p5-Agar/Agar',
);

our $SCRIPTURL = 'manreader.cgi';
our $SCRIPTARGS = '';

# Path to the menu file if any.
our $MENU_FILE = 'menu.html.en';

# Path to the style sheet.
our $CSS = '/style.css';

my @lines = ();

my $man = param('man');
my $printable = param('printable');
if ($printable) {
	$HEADER_FILE = $HEADER_PRINTABLE;
	$FOOTER_FILE = $FOOTER_PRINTABLE;
	$SCRIPTARGS .= '&printable=y';
}

print 'Content-type: text/html; charset=UTF-8', "\n\n";

unless ($man =~ /^([\w\-]{1,64})\.([\d\w])$/) {
	$man = 'AG_Intro.3';
}

sub SearchMan
{
	my $man = shift;
	my $file;

	foreach my $dir (@MANPATH) {
		$file = $ROOT_DIR.'/'.$dir.'/'.$man;
		if (-e $file) {
			return ($file);
		}
	}
	foreach my $dir (@MANPATH) {
		$file = $ROOT_DIR.'/'.$dir.'/.manlinks.mk';
		if (-e $file && open(MLINKS, $file)) {
			foreach my $ml (<MLINKS>) {
				chop($ml);
				if ($ml =~
				    /^MANLINKS\+\=([\w\-\.]+):([\w\-\.]+)$/){
					if ($2 eq $man) {
						my $fn = '#'.(split(/\./, $2))[0];
						print "<meta http-equiv='refresh' content='0;url=$SCRIPTURL?man=$1$SCRIPTARGS$fn'/>";
						return ($ROOT_DIR.'/'.$dir.'/'.
						        $1);
					}
				}
			}
			close(MLINKS);
		}
	}
	return (undef);
}

my $file = SearchMan($man);
unless ($file) {
	print << "EOF";
Sorry, the manual contains no entry named \&quot;<b>$man</b>\&quot;.
EOF
	exit(0);
}
unless (open(MANPAGE, $file)) {
	print "$file: $!";
	exit(0);
}

while (<MANPAGE>) {
	chop;
	my $out = ManReader::Mdoc::Preprocess($_);
	push @lines, $out if $out;
}
close(MANPAGE);

my $pgtitle = $man;
$pgtitle =~ s/(.+)\.\d/$1/;

if (open(HEADER, $HEADER_FILE)) {
	print <HEADER>;
	close(HEADER);
} else {
	print STDERR "$HEADER_FILE: $!\n";
}

ManReader::Mdoc::ParseToHTML(@lines);

if (open(FOOTER, $FOOTER_FILE)) {
	print <FOOTER>;
	close(FOOTER);
} else {
	print STDERR "$FOOTER_FILE: $!\n";
}
