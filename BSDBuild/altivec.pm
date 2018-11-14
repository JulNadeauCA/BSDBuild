# Public domain
# vim:ts=4

sub Test_Altivec
{
	my ($ver) = @_;
	my $testCode = << 'EOF';
float a[4] = { 1,2,3,4 };
float b[4] = { 5,6,7,8 };
float c[4];

int
main(int argc, char *argv[])
{
	vector float *va = (vector float *)a;
	vector float *vb = (vector float *)b;
	vector float *vc = (vector float *)c;

	*vc = vec_add(*va, *vb);
	return (0);
}
EOF

	print << 'EOF';
case "$host" in
powerpc-*-darwin*)
	ALTIVEC_CFLAGS='-faltivec -maltivec'
	ALTIVEC_CHECK_CFLAGS='-D_DARWIN_C_SOURCE'
	echo "ALTIVEC_CHECK_CFLAGS=${ALTIVEC_CHECK_CFLAGS}" >> Makefile.config
	;;
*)
	ALTIVEC_CFLAGS='-mabi=altivec -maltivec'
	ALTIVEC_CHECK_CFLAGS=''
	echo "ALTIVEC_CHECK_CFLAGS=" >> Makefile.config
	;;
esac
EOF

	MkCompileC('HAVE_ALTIVEC', '${CFLAGS} ${ALTIVEC_CFLAGS}', '',
	    '#include <altivec.h>'."\n".
		$testCode);
	MkIfTrue('${HAVE_ALTIVEC}');
	    MkSaveMK('ALTIVEC_CFLAGS');
		MkDefine('HAVE_ALTIVEC_H');
		MkSaveDefine('ALTIVEC_CFLAGS', 'HAVE_ALTIVEC_H');
	MkElse;
		MkPrintSN('checking for AltiVec (without <altivec.h>)...');
		MkCompileC('HAVE_ALTIVEC', '${CFLAGS} ${ALTIVEC_CFLAGS}', '', $testCode);
		MkIfTrue('${HAVE_ALTIVEC}');
	   		MkSave('ALTIVEC_CFLAGS');
		MkElse;
			MkSaveUndef('ALTIVEC_CFLAGS');
			MkDefine('ALTIVEC_CFLAGS', '');
			MkSaveMK('ALTIVEC_CFLAGS');
		MkEndif;
		MkSaveUndef('HAVE_ALTIVEC_H');
	MkEndif;

	return (0);
}

sub Disable_Altivec
{
	MkDefine('HAVE_ALTIVEC', 'no');
	MkDefine('HAVE_ALTIVEC_H', 'no');
	MkDefine('ALTIVEC_CFLAGS', '');

	MkSaveUndef('HAVE_ALTIVEC', 'HAVE_ALTIVEC_H', 'ALTIVEC_CFLAGS');
}

sub Emul
{
	my ($os, $osrel, $machine) = @_;

	Disable();
	return (1);
}

BEGIN
{
	my $n = 'altivec';

	$DESCR{$n} = 'AltiVec (with <altivec.h>)';

	$TESTS{$n}   = \&Test_Altivec;
	$DISABLE{$n} = \&Disable;
	$EMUL{$n}    = \&Emul;
	
	$DEPS{$n} = 'cc';
}
;1
