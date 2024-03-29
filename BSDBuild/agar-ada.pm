# Public domain

sub TEST_agar_ada
{
	my ($ver, $pfx) = @_;
	
	MkExecOutputPfx($pfx, 'agar-ada-config', '--version', 'AGAR_ADA_VERSION');
	MkIfFound($pfx, $ver, 'AGAR_ADA_VERSION');
		MkPrintSN('checking whether Agar Ada bindings work...');
		MkExecOutputPfx($pfx, 'agar-ada-config', '--cflags', 'AGAR_ADA_CFLAGS');
		MkExecOutputPfx($pfx, 'agar-ada-config', '--libs', 'AGAR_ADA_LIBS');
		MkCompileAda('HAVE_AGAR_ADA',
		           '${AGAR_ADA_CFLAGS} ${AGAR_ADA_CORE_CFLAGS} ${AGAR_CFLAGS}',
		           '${AGAR_ADA_LIBS} ${AGAR_ADA_CORE_LIBS} ${AGAR_LIBS}',
			   << "EOF");
with Agar.Init;
with Agar.Init_GUI;
with Agar.Error;

procedure conftest is
begin
  if not Agar.Init.Init_Core then
    raise program_error with Agar.Error.Get_Error;
  end if;
  if not Agar.Init_GUI.Init_GUI then
    raise program_error with Agar.Error.Get_Error;
  end if;
end conftest;
EOF
		MkIfFalse('${HAVE_AGAR_ADA}');
			MkDisableFailed('agar-ada');
		MkEndif;
	MkElse;
		MkDisableNotFound('agar-ada');
	MkEndif;
}

sub DISABLE_agar_ada
{
	MkDefine('HAVE_AGAR_ADA', 'no') unless $TestFailed;
	MkDefine('AGAR_ADA_CFLAGS', '');
	MkDefine('AGAR_ADA_LIBS', '');
	MkSaveUndef('HAVE_AGAR_ADA');
}

BEGIN
{
	my $n = 'agar-ada';

	$DESCR{$n}   = 'Ada bindings to Agar-GUI';
	$URL{$n}     = 'http://libagar.org';
	$TESTS{$n}   = \&TEST_agar_ada;
	$DISABLE{$n} = \&DISABLE_agar_ada;
	$DEPS{$n}    = 'cc,agar,agar-ada-core';
	$SAVED{$n}   = 'AGAR_ADA_CFLAGS AGAR_ADA_LIBS';
}
;1
