#!/usr/bin/perl -I%PREFIX%/share/bsdbuild
#
# Copyright (c) 2009 Hypertriton, Inc. <http://hypertriton.com>
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
# man2mediawiki.pl - Generate a MediaWiki article from a manual page.
#
use strict;
use CGI qw/:standard/;

use Term::ReadLine;
use Getopt::Std;
use MediaWiki::API;

my %opts = ();
my $username = '';
my $password = '';
my $api_url = '';

if (@ARGV < 1) {
	print STDERR "Usage: $0 [-u username] [-p password] [-a api-url] ".
	             "[category]\n";
	exit(1);
}
my $term = new Term::ReadLine('man2mediawiki');
getopt('upa', \%opts);

if ($opts{u}) {
	$username = $opts{u};
} else {
	$username = $term->readline('Username? ');
}
if ($opts{p}) {
	$password = $opts{p};
} else {
	$password = $term->readline('Password (will echo)? ');
}
if ($opts{a}) {
	$api_url = $opts{a};
} else {
	$api_url = $term->readline('API URL? ');
}
my $category = $ARGV[0];

my $mw = MediaWiki::API->new();
if (!defined($mw)) {
	die "MediaWiki::API->new() failed";
}
$mw->{config}->{api_url} = $api_url;

print "Login: $username / $password\n";
print "API URL: $api_url\n";
print "Category: $category\n";

$mw->login({lgname => $username, lgpassword => $password})
    || die $mw->{error}->{code}.':'.$mw->{error}->{details};

# Fetch list of articles in our category.
my $art = $mw->list({
    'action' => 'query',
    'list' => 'categorymembers',
    'cmtitle' => 'Category:'.$category,
    'cmlimit' => 'max' })
    || die $mw->{error}->{code}.':'.$mw->{error}->{details};

foreach my $a (@{$art}) {
	unless ($a->missing) {
		
	}
	print "Article: $a->{title}\n";
}

$mw->logout();
