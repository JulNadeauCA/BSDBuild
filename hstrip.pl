# $Csoft: hstrip.pl,v 1.4 2001/09/15 12:07:36 vedge Exp $

$no++ if($ARGV[0] eq 'contract.html');

my $pre = 0;
while (<STDIN>) {
	if ($no) {
		print $_;
	} else {
		$pre++ if (/<pre>/);
		$pre-- if (/<\/pre>/);

		if (!$pre) {
			s/<!--.+-->//g;
			chop;
		}

		print;
		print ' ';
	}
}
