# $Csoft$

sub MKCopy;

sub MKCopy
{
	my ($src, $dest) = @_;

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
	unless (open(DEST, '>' ,$dest)) {
		print STDERR "$dest: $!\n";
		close(SRC);
		return 0;
	}

	foreach $_ (<SRC>) {
		chop;

		if (/^include .+\/mk\/(.+)$/) {
			print "$src: depends on $1\n";
			push @deps, $1;
			MKCopy($1, join('/', 'mk', $1));
		}
		print DEST $_, "\n";
	}

	close(SRC);
	close(DEST);

	return 1;
}

BEGIN
{
	my $mk = './mk';
	
	if (! -d $mk && !mkdir($mk)) {
		print STDERR "$mk: $!\n";
		exit (1);
	}

	foreach my $f (@ARGV) {
		my $src = $f;
		my $dest = join('/', $mk, $f);

		MKCopy($src, $dest);
	}
}
