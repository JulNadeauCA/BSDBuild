# $Csoft: hstrip.pl,v 1.2 2001/09/15 04:10:11 vedge Exp $

my $pre = 0;
while (<STDIN>) {
	$pre++ if (/<pre>/);
	$pre-- if (/<\/pre>/);

	if (!$pre) {
		s/<!--.+-->//g;
		chop;
	}

	print;
	print ' ';
}
