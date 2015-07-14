# Public domain
# Strip empty lines from HTML documents (except <pre> contents).
#
my $inPre = 0;
while (<STDIN>) {
	chop;
	if (/<\s*pre[[:print:]]*>/i) {
		$inPre = 1;
	}
	if (/<\s*\/\s*pre\s*>/i) { $inPre = 0; }
	if (!$inPre && /^\s*$/) {
		next;
	}
	print $_, "\n";
}
