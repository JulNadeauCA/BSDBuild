# Public domain

sub TEST_smpeg
{
	my ($ver, $pfx) = @_;
	
	MkExecOutputPfx($pfx, 'smpeg-config', '--version', 'SMPEG_VERSION');
	MkExecOutputPfx($pfx, 'smpeg-config', '--cflags', 'SMPEG_CFLAGS');
	MkExecOutputPfx($pfx, 'smpeg-config', '--libs', 'SMPEG_LIBS');

	MkIfFound($pfx, $ver, 'SMPEG_VERSION');
		# TODO test
		MkSaveDefine('HAVE_SMPEG');
	MkElse;
		MkDisableNotFound('smpeg');
	MkEndif;
}

sub DISABLE_smpeg
{
	MkDefine('HAVE_SMPEG', 'no') unless $TestFailed;
	MkDefine('SMPEG_CFLAGS', '');
	MkDefine('SMPEG_LIBS', '');
	MkSaveUndef('HAVE_SMPEG');
}

BEGIN
{
	my $n = 'smpeg';

	$DESCR{$n}   = 'the smpeg library';
	$URL{$n}     = 'http://icculus.org/smpeg';
	$TESTS{$n}   = \&TEST_smpeg;
	$DISABLE{$n} = \&DISABLE_smpeg;
	$DEPS{$n}    = 'cc,sdl';
	$SAVED{$n}   = 'SMPEG_CFLAGS SMPEG_LIBS';
}
;1
