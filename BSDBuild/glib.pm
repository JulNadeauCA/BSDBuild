# vim:ts=4
# Public domain

sub TEST_glib
{
	my ($ver, $pfx) = @_;
	
	MkExecOutputPfx($pfx, 'glib-config', '--version', 'GLIB_VERSION');
	MkExecOutputPfx($pfx, 'glib-config', '--cflags', 'GLIB_CFLAGS');
	MkExecOutputPfx($pfx, 'glib-config', '--libs', 'GLIB_LIBS');
	
	MkIfFound($pfx, $ver, 'GLIB_VERSION');
		MkSave('GLIB_CFLAGS', 'GLIB_LIBS');
	MkElse;
		MkPrintSN("checking for glib 1.2...");
		MkExecOutputPfx($pfx, 'glib12-config', '--version', 'GLIB12_VERSION');
		MkExecOutputPfx($pfx, 'glib12-config', '--cflags', 'GLIB12_CFLAGS');
		MkExecOutputPfx($pfx, 'glib12-config', '--libs', 'GLIB12_LIBS');
		MkIfFound($pfx, $ver, 'GLIB12_VERSION');
			MkDefine('GLIB_CFLAGS', '${GLIB12_CFLAGS}');
			MkDefine('GLIB_LIBS', '${GLIB12_LIBS}');
			MkSave('GLIB_CFLAGS', 'GLIB_LIBS');
		MkElse;
			MkSaveUndef('HAVE_GLIB');
		MkEndif;
	MkEndif;
}

sub DISABLE_glib
{
	MkDefine('HAVE_GLIB', 'no');
	MkDefine('GLIB_CFLAGS', '');
	MkDefine('GLIB_LIBS', '');
	MkDefine('GLIB12_CFLAGS', '');
	MkDefine('GLIB12_LIBS', '');
	MkSaveUndef('HAVE_GLIB');
}

BEGIN
{
	my $n = 'glib';

	$DESCR{$n}   = 'Glib';
	$URL{$n}     = 'http://www.gtk.org';
	$TESTS{$n}   = \&TEST_glib;
	$DISABLE{$n} = \&DISABLE_glib;
	$DEPS{$n}    = 'cc';
}
;1
