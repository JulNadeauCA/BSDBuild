# $Csoft: hstrip.pl,v 1.9 2003/06/21 21:19:18 vedge Exp $
# Public domain

while (<STDIN>) {
	chop;
	if (/^$/) {
		next;
	}
	print $_, "\n";
}
