#!/usr/bin/perl
#
# Extract manual links from mdoc source.
# Public domain
#

my $man = $ARGV[0];
my $section = $ARGV[1];
my $ns = 0;

unless ($man && $section) {
	print STDERR "Usage: $0 [man] [section]\n";
	exit 1;
}

$man =~ s/.+\/([\w\-\.]+)$/$1/;

while (<STDIN>) {
	if (/^\.nr nS 1/) { $ns = 1; }
	elsif (/^\.nr nS 0/ || /^\.\\" NOMANLINK/) { $ns = 0; }
	next unless $ns;
	if (/^\.Fn ([\w\-]+)\s+/ && $1.'.'.$section ne $man) {
		print "MANLINKS+=$man:$1.$section\n";
	}
}
