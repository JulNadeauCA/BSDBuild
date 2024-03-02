# Public domain

sub TEST_agar_ada_core
{
	my ($ver, $pfx) = @_;
	
	MkExecOutputPfx($pfx, 'agar-ada-core-config', '--version', 'AGAR_ADA_CORE_VERSION');
	MkIfFound($pfx, $ver, 'AGAR_ADA_CORE_VERSION');
		MkPrintSN('checking whether Agar-Core Ada bindings work...');
		MkExecOutputPfx($pfx, 'agar-ada-core-config', '--cflags', 'AGAR_ADA_CORE_CFLAGS');
		MkExecOutputPfx($pfx, 'agar-ada-core-config', '--libs', 'AGAR_ADA_CORE_LIBS');
		MkCompileAda('HAVE_AGAR_ADA_CORE',
		             '${AGAR_ADA_CORE_CFLAGS} ${AGAR_CORE_CFLAGS}',
		             '${AGAR_ADA_CORE_LIBS} ${AGAR_CORE_LIBS}', << "EOF");
with Agar;
with Agar.Init;
with Agar.Error;

procedure conftest is
begin
  if not Agar.Init.Init_Core then
    raise program_error with Agar.Error.Get_Error;
  end if;
end conftest;
EOF
		MkIfFalse('${HAVE_AGAR_ADA_CORE}');
			MkDisableFailed('agar-ada-core');
		MkEndif;
	MkElse;
		MkDisableNotFound('agar-ada-core');
	MkEndif;
}

sub DISABLE_agar_ada_core
{
	MkDefine('HAVE_AGAR_ADA_CORE', 'no') unless $TestFailed;
	MkDefine('AGAR_ADA_CORE_CFLAGS', '');
	MkDefine('AGAR_ADA_CORE_LIBS', '');
	MkSaveUndef('HAVE_AGAR_ADA_CORE');
}

BEGIN
{
	my $n = 'agar-ada-core';

	$DESCR{$n}   = 'Ada bindings to Agar-Core';
	$URL{$n}     = 'http://libagar.org';
	$TESTS{$n}   = \&TEST_agar_ada_core;
	$DISABLE{$n} = \&DISABLE_agar_ada_core;
	$DEPS{$n}    = 'cc';
	$SAVED{$n}   = 'AGAR_ADA_CORE_CFLAGS AGAR_ADA_CORE_LIBS';
}
;1
