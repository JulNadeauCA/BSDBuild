# $Csoft: hstrip.pl,v 1.1 2002/12/02 07:07:31 vedge Exp $

while (<STDIN>) {
	chop;
	if (/^$/) {
		next;
	}
	print $_, "\n";
}
