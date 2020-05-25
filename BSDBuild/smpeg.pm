# vim:ts=4
# Public domain

sub TEST_smpeg
{
	my ($ver, $pfx) = @_;
	
	MkExecOutputPfx($pfx, 'smpeg-config', '--version', 'SMPEG_VERSION');
	MkExecOutputPfx($pfx, 'smpeg-config', '--cflags', 'SMPEG_CFLAGS');
	MkExecOutputPfx($pfx, 'smpeg-config', '--libs', 'SMPEG_LIBS');

	# TODO Test

	MkIfFound($pfx, $ver, 'SMPEG_VERSION');
		MkSave('SMPEG_CFLAGS', 'SMPEG_LIBS');
	MkElse;
		DISABLE_smpeg();
	MkEndif;
}

sub DISABLE_smpeg
{
	MkDefine('HAVE_SMPEG', 'no');
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
}
;1
