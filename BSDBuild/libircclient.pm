# Public domain

use BSDBuild::Core;

my @autoPrefixDirs = (
	'/usr/local',
	'/usr',
	'/usr/pkg',
	'/opt/local',
	'/opt'
);

my $testCode = << 'EOF';
#include <stdio.h>
#include <libircclient.h>
#include <libirc_rfcnumeric.h>

int main(int argc, char *argv[]) {
	irc_callbacks_t cb;
	irc_session_t *sess;
	cb.event_connect = NULL;
	return ((sess = irc_create_session(&cb)) == NULL);
}
EOF

sub TEST_libircclient
{
	my ($ver, $pfx) = @_;
	my @pfxDirs = ();

	# XXX TODO: detect if compiled against openssl

	push @pfxDirs, $pfx if $pfx;
	push @pfxDirs, @autoPrefixDirs;

	foreach my $dir (@pfxDirs) {
		MkIfExists("$dir/include/libircclient.h");
			MkDefine('LIBIRCCLIENT_CFLAGS', "-I$dir/include");
			MkDefine('LIBIRCCLIENT_LIBS', "-L$dir/lib -lircclient");
			MkPrintS('yes');
			MkBreak;
		MkEndif;
	}
	MkIfNE('${LIBIRCCLIENT_CFLAGS}', '');
		MkPrintSN('checking whether libircclient works...');
		MkCompileC('HAVE_LIBIRCCLIENT', '${LIBIRCCLIENT_CFLAGS}',
		           '${LIBIRCCLIENT_LIBS}', $testCode);
		MkIfFalse('${HAVE_LIBIRCCLIENT}');
			MkDisableFailed('libircclient');
		MkEndif;
	MkElse;
		MkPrintS('no');
		MkDisableNotFound('libircclient');
	MkEndif;
}

sub DISABLE_libircclient
{
	MkDefine('HAVE_LIBIRCCLIENT', 'no') unless $TestFailed;
	MkDefine('LIBIRCCLIENT_CFLAGS', '');
	MkDefine('LIBIRCCLIENT_LIBS', '');
	MkSaveUndef('HAVE_LIBIRCCLIENT');
}

BEGIN
{
	my $n = 'libircclient';

	$DESCR{$n}   = 'libircclient';
	$URL{$n}     = 'http://www.ulduzsoft.com/libircclient';
	$TESTS{$n}   = \&TEST_libircclient;
	$DISABLE{$n} = \&DISABLE_libircclient;
	$DEPS{$n}    = 'cc';
	$SAVED{$n}   = 'LIBIRCCLIENT_CFLAGS LIBIRCCLIENT_LIBS';
}
;1
