# $Csoft: hstrip.pl,v 1.1 2002/12/02 07:07:31 vedge Exp $

$no++; #if($ARGV[0] eq 'contract.html'); # XXX

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
