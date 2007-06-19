# Public domain
#
# hstrip.pl: Strip empty lines.
#
while (<STDIN>) {
	chop;
	if (/^$/) {
		next;
	}
	print $_, "\n";
}
