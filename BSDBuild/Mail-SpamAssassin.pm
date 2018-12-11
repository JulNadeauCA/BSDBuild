# Public domain
# vim:ts=4

sub TEST_spamassassin
{
	MkRunPerl('HAVE_SPAMASSASSIN', '', << 'EOF');
use strict;
use Fcntl;
use Sys::Hostname;
use Mail::SpamAssassin;

our $Assassin = Mail::SpamAssassin->new({
    'home_dir_for_helpers' => '.',
    'local_tests_only' => 1});

require Mail::SpamAssassin::DBBasedAddrList;
our $AddrListFactory = Mail::SpamAssassin::DBBasedAddrList->new();
$Assassin->set_persistent_address_list_factory($AddrListFactory);

$AddrListFactory->finish();
$Assassin->finish();
EOF
}

sub DISABLE_spamassassin
{
	MkDefine('HAVE_SPAMASSASSIN', 'no');
	MkSaveUndef('HAVE_SPAMASSASSIN');
}

BEGIN
{
	my $n = 'Mail-SpamAssassin';

	$DESCR{$n}   = 'Mail::SpamAssassin';
	$URL{$n}     = 'http://spamassassin.org';
	$TESTS{$n}   = \&TEST_spamassassin;
	$DISABLE{$n} = \&DISABLE_spamassassin;
	$DEPS{$n}    = 'perl';
}
;1
