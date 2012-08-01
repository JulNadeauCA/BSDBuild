#!/usr/bin/perl
#
# Public domain
# 
# Search $UMANPATH for a user-installed manual page and write it to
# the standard output (via groff).
#
# Links can also be specified (uman will search BSDBuild-generated
# .manlinks.mk files for them).
#

if (!defined($ENV{'UMANPATH'})) {
	print "The \$UMANPATH environment variable is not set; see uman(1).\n";
	exit(1);
}

# Search these directories for manual page source.
@SRC_DIRS = split(':', $ENV{'UMANPATH'});

# Formatting engine
#$NROFF = 'nroff -Tascii -mandoc';
$NROFF = 'groff -S -P-h -Wall -mtty-char -man -Tascii -P-c -mandoc';

if (@ARGV < 1) { die "Usage: uman [manpage]"; }
my $query = $ARGV[0];
my $pager = 'less';
if (exists($ENV{'PAGER'})) { $pager = $ENV{'PAGER'}; }

sub ReadPage ($)
{
	my $page = shift;
	system("cat $page |$NROFF $page |$pager");
}

# Search a BSDBuild-generated .manlinks.mk file.
sub SearchManlinksMK ($$)
{
	my $path = shift;
	my $q = shift;

	unless (open(ML, $path)) {
		print STDERR "$path: $!; ignoring\n";
		return;
	}
	foreach $_ (<ML>) {
		if (/^MANLINKS\+=([\w\-]+)\.(\d):([\w\-]+)\.(\d)$/) {
			my $from = $1.'.'.$2;

			if (lc($3) eq $q) {
				return ($from);
			}
		}
	}
	close(ML);
	return (undef);
}

# Recursively search a directory.
sub SearchDir ($$$$)
{
	my $dir = shift;
	my $q = lc(shift);
	my $depth = shift;
	my $maxDepth = shift;

	unless (opendir(DIR, $dir)) {
		return;
	}
	foreach my $ent (readdir(DIR)) {
		my $path = $dir.'/'.$ent;
		if ($ent eq '.manlinks.mk') {
			if ((my $rv = SearchManlinksMK($path, $q))) {
				ReadPage($dir.'/'.$rv);
				exit(0);
			}
			next;
		}
		if ($ent =~ /^\./) { next; }
		if ($ent =~ /^([\w\-\.]+)\.(\d)$/) {
			if ($q eq lc($1) ||
			    $q eq lc($1.'.'.$2)) {
				ReadPage($path);
				exit(0);
			}
		}
		if (-d $path && $depth+1 <= $maxDepth) {
			SearchDir($path, $q, $depth+1, $maxDepth);
		}
	}
	closedir(DIR);
}

foreach my $dir (@SRC_DIRS) {
	SearchDir($dir, $query, 1, 10);
}
