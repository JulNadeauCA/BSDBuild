# $Csoft: mkify.pl,v 1.2 2001/12/01 03:30:44 vedge Exp $

sub MKCopy;

sub MKCopy
{
	my ($src, $dest, $dir) = @_;

	unless (-f $src) {
		print STDERR "$src: $!\n";
		exit (1);
	}
	unless (-f $dest) {
		print STDERR "creating $dest\n";
	}

	unless (open(SRC, $src)) {
		print STDERR "$src: $!\n";
		return 0;
	}
	unless (open(DEST, '>', $dest)) {
		print STDERR "$dest: $!\n";
		close(SRC);
		return 0;
	}

	foreach $_ (<SRC>) {
		chop;

		if (/^include .+\/mk\/(.+)$/) {
			print "$src: depends on $1\n";
			push @deps, $1;
			MKCopy(join('/', $dir, $1), join('/', 'mk', $1));
		}
		print DEST $_, "\n";
	}

	close(SRC);
	close(DEST);

	return 1;
}

BEGIN
{
	my $dir = '.';
	my $mk = './mk';

	if ($0 =~ /(\/.+)\/mkify\.pl/) {
		$dir = $1;
	}
	print "dir = $dir\n";

	if (! -d $mk && !mkdir($mk)) {
		print STDERR "$mk: $!\n";
		exit (1);
	}

	foreach my $f (@ARGV) {
		$f = join('.', 'csoft', $f, 'mk');
		my $src = join('/', $dir, $f);
		my $dest = join('/', $mk, $f);

		MKCopy($src, $dest, $dir);
	}
}
