# $Csoft: hstrip.pl,v 1.1 2001/09/15 03:17:26 vedge Exp $

my $pre = 0;
while (<STDIN>) {
	$pre++ if (/<pre>/);
	$pre-- if (/<\/pre>/);

	if (!$pre) {
		s/<!--.+-->//g;
		chop;
	}

	print;
	print ' ' if(/\.$/);
}
