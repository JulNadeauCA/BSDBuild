# $Csoft$

my $pre = 0;
while (<STDIN>) {
	$pre++ if (/<pre>/);
	$pre-- if (/<\/pre>/);

	if (!$pre) {
		s/<!--.+-->//g;
		chop;
	}

	print;
}
