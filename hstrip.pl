# $Csoft: hstrip.pl,v 1.3 2001/09/15 04:11:51 vedge Exp $

exit(0) if($ARGV[0] eq 'contract.html');

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
