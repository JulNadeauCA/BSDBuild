# Public domain

sub TEST_sys_types
{
	MkCompileC('_MK_HAVE_SYS_TYPES_H', '', '', << 'EOF');
#include <sys/types.h>
int main(int argc, char *argv[]) {
	int8_t s8 = 2;
	u_int8_t u8 = 2;
	int32_t s32 = 1234;
	u_int32_t u32 = 5678;
	return (s8+u8 == 4 && s32+u32 > 6000 ? 0 : 1);
}
EOF
	MkPrintSN('checking for <stdint.h>...');
	MkCompileC('_MK_HAVE_STDINT_H', '', '', << 'EOF');
#include <stdint.h>
int main(int argc, char *argv[]) {
	int8_t s8 = 2;
	uint8_t u8 = 2;
	int32_t s32 = 1234;
	uint32_t u32 = 5678;
	return (s8+u8 == 4 && s32+u32 > 6000 ? 0 : 1);
}
EOF

	MkIfTrue('${_MK_HAVE_SYS_TYPES_H}');

		MkPrintSN('checking for int64_t type...');
		MkCompileC('HAVE_INT64_T', '', '', << 'EOF');
#include <sys/types.h>
#include <stdio.h>
int main(int argc, char *argv[]) {
	int64_t i64 = 0;
	u_int64_t u64 = 0;
	printf("%lld %llu", (long long)i64, (unsigned long long)u64);
	return (i64 != 0 || u64 != 0);
}
EOF
		MkPrintSN('checking for __int64 type...');
		MkCompileC('HAVE___INT64', '', '', << 'EOF');
#include <sys/types.h>
#include <stdio.h>
int main(int argc, char *argv[]) {
	__int64 i64 = 0;
	printf("%lld", (long long)i64);
	return (i64 != 0);
}
EOF
		MkIfTrue('${HAVE_INT64_T}');
			MkDefine('HAVE_64BIT', "yes");
			MkSaveDefine('HAVE_64BIT');
		MkElse;
			MkIfTrue('${HAVE___INT64}');
				MkDefine('HAVE_64BIT', "yes");
				MkSaveDefine('HAVE_64BIT');
			MkElse;
				MkSaveUndef('HAVE_64BIT');
			MkEndif;
		MkEndif;

	MkElse;

		MkIfTrue('${_MK_HAVE_STDINT_H}');
			MkPrintSN('checking for int64_t type...');
			MkCompileC('HAVE_INT64_T', '', '', << 'EOF');
#include <stdint.h>
#include <stdio.h>
int main(int argc, char *argv[]) {
	int64_t i64 = 0;
	u_int64_t u64 = 0;
	printf("%lld %llu", (long long)i64, (unsigned long long)u64);
	return (i64 != 0 || u64 != 0);
}
EOF
			MkPrintSN('checking for __int64 type...');
			MkCompileC('HAVE___INT64', '', '', << 'EOF');
#include <stdint.h>
#include <stdio.h>
int main(int argc, char *argv[]) {
	__int64 i64 = 0;
	printf("%lld", (long long)i64);
	return (i64 != 0);
}
EOF
			MkIfTrue('${HAVE_INT64_T}');
				MkDefine('HAVE_64BIT', "yes");
				MkSaveDefine('HAVE_64BIT');
			MkElse;
				MkIfTrue('${HAVE___INT64}');
					MkDefine('HAVE_64BIT', "yes");
					MkSaveDefine('HAVE_64BIT');
				MkElse;
					MkSaveUndef('HAVE_64BIT');
				MkEndif;
			MkEndif;
		MkElse;
			MkSaveUndef('HAVE_64BIT');
		MkEndif;
	MkEndif;
}

sub DISABLE_sys_types
{
	MkDefine('_MK_HAVE_SYS_TYPES_H', 'no');
	MkDefine('_MK_HAVE_STDINT_H', 'no');
	MkDefine('HAVE_64BIT', 'no');
	MkDefine('HAVE_INT64_T', 'no');
	MkDefine('HAVE___INT64', 'no');
	MkSaveUndef('_MK_HAVE_SYS_TYPES_H');
	MkSaveUndef('_MK_HAVE_STDINT_H');
	MkSaveUndef('HAVE_64BIT', 'HAVE_INT64_T', 'HAVE___INT64');
}

sub EMUL_sys_types
{
	my ($os, $osrel, $machine) = @_;

	if ($os =~ /^windows/) {
		MkEmulWindowsSYS('_MK_HAVE_SYS_TYPES_H');
		MkEmulWindowsSYS('_MK_HAVE_STDINT_H');
		MkEmulWindowsSYS('64BIT');
		MkEmulWindowsSYS('INT64_T');
		MkEmulWindowsSYS('__INT64');
	} else {
		DISABLE_sys_types();
	}
	return (1);
}

BEGIN
{
	my $n = 'sys_types';

	$DESCR{$n}   = '<sys/types.h>';
	$TESTS{$n}   = \&TEST_sys_types;
	$DISABLE{$n} = \&DISABLE_sys_types;
	$EMUL{$n}    = \&EMUL_sys_types;
	$DEPS{$n}    = 'cc';
}
;1
