# $Csoft: mkify.pl,v 1.3 2001/12/01 03:36:28 vedge Exp $

sub MKCopy;

sub MKCopy
{
	my ($src, $dir) = @_;
	my $destmk = join('/', 'mk', $src);
	my $srcmk = join('/', $dir, $src);
	my @deps = ();

	unless (-f $srcmk) {
		print STDERR "$src: $!\n";
		exit (1);
	}
	unless (-f $destmk) {
		print STDERR "creating $destmk\n";
	}

	unless (open(SRC, $srcmk)) {
		print STDERR "$srcmk: $!\n";
		return 0;
	}
	chop(@src = <SRC>);
	close(SRC);

	unless (open(DEST, '>', $destmk)) {
		print STDERR "$destmk: $!\n";
		close(SRC);
		return 0;
	}
	foreach $_ (@src) {
		print DEST $_, "\n";

		if (/^include .+\/mk\/(.+)$/) {
			print "$src: depends on $1\n";
			push @deps, $1;
		}
	}
	close(DEST);

	foreach my $dep (@deps) {
		MKCopy($dep, $dir);
	}

	return 1;
}

BEGIN
{
	my $dir = '.';
	my $mk = './mk';

	if ($0 =~ /(\/.+)\/mkify\.pl/) {
		$dir = $1;
	}

	if (! -d $mk && !mkdir($mk)) {
		print STDERR "$mk: $!\n";
		exit (1);
	}

	foreach my $f (@ARGV) {
		$f = join('.', 'csoft', $f, 'mk');
		my $dest = join('/', $mk, $f);

		MKCopy($f, $dir);
	}
}
