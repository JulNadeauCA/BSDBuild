# $Csoft: hstrip.pl,v 1.6 2001/10/09 04:50:51 vedge Exp $
# Public domain

$no++ if($ARGV[0] eq 'contract.html'); # XXX

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
