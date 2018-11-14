# Public domain
# vim:ts=4

sub Test_SpamAssassin
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
	return (0);
}

sub Disable_SpamAssassin
{
	MkSaveUndef('HAVE_SPAMASSASSIN');
}

BEGIN
{
	my $n = 'Mail-SpamAssassin';

	$DESCR{$n} = 'the Mail::SpamAssassin module';
	$URL{$n}   = 'http://spamassassin.org';

	$TESTS{$n}   = \&Test_SpamAssassin;
	$DISABLE{$n} = \&Disable_SpamAssassin;

	$DEPS{$n} = 'perl';
}

;1
