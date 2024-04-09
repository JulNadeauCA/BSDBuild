# Public domain

my $testCodeWebp = << 'EOF';
#include <webp/decode.h>
int main(int argc, char *argv[]) {
	return (WebPGetDecoderVersion());
}
EOF

my $testCodeSharpYuv = << 'EOF';
#include <sharpyuv/sharpyuv.h>
int main(int argc, char *argv[]) {
	return (SharpYuvGetVersion());
}
EOF

my $testCodeDemux = << 'EOF';
#include <sharpyuv/sharpyuv.h>
int main(int argc, char *argv[]) {
	return (WebPGetDemuxVersion());
}
EOF

my $testCodeMux = << 'EOF';
#include <sharpyuv/sharpyuv.h>
int main(int argc, char *argv[]) {
	return (WebPGetMuxVersion());
}
EOF


sub TEST_webp
{
	my ($ver, $pfx) = @_;

	MkExecPkgConfig($pfx, 'libwebp', '--modversion', 'WEBP_VERSION');
	MkExecPkgConfig($pfx, 'libwebp', '--cflags', 'WEBP_CFLAGS');
	MkExecPkgConfig($pfx, 'libwebp', '--libs', 'WEBP_LIBS');

	MkIfFound($pfx, $ver, 'WEBP_VERSION');
		MkPrintSN('checking whether libwebp works...');
		MkCompileC('HAVE_WEBP', '${WEBP_CFLAGS}', '${WEBP_LIBS}', $testCodeWebp);
		MkIfTrue('${HAVE_WEBP}');

			MkExecPkgConfig($pfx, 'libsharpyuv', '--modversion', 'SHARPYUV_VERSION');
			MkExecPkgConfig($pfx, 'libsharpyuv', '--cflags', 'SHARPYUV_CFLAGS');
			MkExecPkgConfig($pfx, 'libsharpyuv', '--libs', 'SHARPYUV_LIBS');
			MkPrintSN('checking whether libsharpyuv works...');
			MkCompileC('HAVE_SHARPYUV', '${SHARPYUV_CFLAGS}', '${SHARPYUV_LIBS}', $testCodeSharpYuv);
			MkIfTrue('${HAVE_SHARPYUV}');
				MkSaveDefine('HAVE_SHARPYUV');
			MkElse;
				MkDefine('SHARPYUV_CFLAGS', '');
				MkDefine('SHARPYUV_LIBS', '');
				MkSaveUndef('HAVE_SHARPYUV');
			MkEndif;

			MkExecPkgConfig($pfx, 'libwebpdemux', '--modversion', 'WEBPDEMUX_VERSION');
			MkExecPkgConfig($pfx, 'libwebpdemux', '--cflags', 'WEBPDEMUX_CFLAGS');
			MkExecPkgConfig($pfx, 'libwebpdemux', '--libs', 'WEBPDEMUX_LIBS');
			MkPrintSN('checking whether libwebpdemux works...');
			MkCompileC('HAVE_WEBPDEMUX', '${WEBPDEMUX_CFLAGS}', '${WEBPDEMUX_LIBS}', $testCodeDemux);
			MkIfTrue('${HAVE_WEBPDEMUX}');
				MkSaveDefine('HAVE_WEBPDEMUX');
			MkElse;
				MkDefine('WEBPDEMUX_CFLAGS', '');
				MkDefine('WEBPDEMUX_LIBS', '');
				MkSaveUndef('HAVE_WEBPDEMUX');
			MkEndif;

			MkExecPkgConfig($pfx, 'libwebpmux', '--modversion', 'WEBPMUX_VERSION');
			MkExecPkgConfig($pfx, 'libwebpmux', '--cflags', 'WEBPMUX_CFLAGS');
			MkExecPkgConfig($pfx, 'libwebpmux', '--libs', 'WEBPMUX_LIBS');
			MkPrintSN('checking whether libwebpmux works...');
			MkCompileC('HAVE_WEBPMUX', '${WEBPMUX_CFLAGS}', '${WEBPMUX_LIBS}', $testCodeMux);
			MkIfTrue('${HAVE_WEBPMUX}');
				MkSaveDefine('HAVE_WEBPMUX');
			MkElse;
				MkDefine('WEBPMUX_CFLAGS', '');
				MkDefine('WEBPMUX_LIBS', '');
				MkSaveUndef('HAVE_WEBPMUX');
			MkEndif;

		MkElse;
			MkDisableFailed('webp');
		MkEndif;
	MkElse;
		MkDisableNotFound('webp');
	MkEndif;
	
	MkIfTrue('${HAVE_WEBP}');
		MkDefine('WEBP_PC', 'libwebp');
	MkEndif;
	MkIfTrue('${HAVE_SHARPYUV}');
		MkDefine('SHARPYUV_PC', 'libsharpyuv');
	MkEndif;
	MkIfTrue('${HAVE_WEBPDEMUX}');
		MkDefine('WEBPDEMUX_PC', 'libwebpdemux');
	MkEndif;
	MkIfTrue('${HAVE_WEBPMUX}');
		MkDefine('WEBPMUX_PC', 'libwebpdemux');
	MkEndif;
}

sub DISABLE_webp
{
	MkDefine('HAVE_WEBP', 'no') unless $TestFailed;
	MkDefine('HAVE_SHARPYUV', 'no');
	MkDefine('HAVE_WEBPDEMUX', 'no');
	MkDefine('HAVE_WEBPMUX', 'no');
	MkDefine('WEBP_CFLAGS', '');
	MkDefine('WEBP_LIBS', '');
	MkDefine('SHARPYUV_CFLAGS', '');
	MkDefine('SHARPYUV_LIBS', '');
	MkDefine('WEBPDEMUX_CFLAGS', '');
	MkDefine('WEBPDEMUX_LIBS', '');
	MkDefine('WEBPMUX_CFLAGS', '');
	MkDefine('WEBPMUX_LIBS', '');
	MkSaveUndef('HAVE_WEBP', 'HAVE_SHARPYUV', 'HAVE_WEBPDEMUX', 'HAVE_WEBPMUX');
}

BEGIN
{
	my $n = 'webp';

	$DESCR{$n}   = 'webp';
	$URL{$n}     = 'https://developers.google.com/speed/webp';
	$TESTS{$n}   = \&TEST_webp;
	$DISABLE{$n} = \&DISABLE_webp;
	$DEPS{$n}    = 'cc';
	$SAVED{$n}   = 'WEBP_CFLAGS WEBP_LIBS SHARPYUV_CFLAGS SHARPYUV_LIBS ' .
	               'WEBPDEMUX_CFLAGS WEBPDEMUX_LIBS WEBPMUX_CFLAGS WEBPMUX_LIBS';
}
;1
