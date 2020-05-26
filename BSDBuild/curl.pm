# Public domain

sub TEST_curl
{
	my ($ver, $pfx) = @_;
	
	MkExecOutputPfx($pfx, 'curl-config', '--version', 'CURL_VERSION');

	MkIfFound($pfx, $ver, 'CURL_VERSION');
		MkPrintSN('checking whether libcurl works...');
		MkExecOutputPfx($pfx, 'curl-config', '--cflags', 'CURL_CFLAGS');
		MkExecOutputPfx($pfx, 'curl-config', '--libs', 'CURL_LIBS');
		MkCompileC('HAVE_CURL',
		           '${CURL_CFLAGS}', '${CURL_LIBS}', << 'EOF');
#include <curl/curl.h>

int
main(int argc, char *argv[])
{
	curl_version_info_data *v;
	curl_global_init(CURL_GLOBAL_ALL);
	v = curl_version_info(CURLVERSION_NOW);
	curl_global_cleanup();
	return (0);
}
EOF
		MkIfFalse('${HAVE_CURL}');
			MkDisableFailed('curl');
		MkEndif;
	MkElse;
		MkDisableNotFound('curl');
	MkEndif;
}

sub DISABLE_curl
{
	MkDefine('HAVE_CURL', 'no') unless $TestFailed;
	MkDefine('CURL_CFLAGS', '');
	MkDefine('CURL_LIBS', '');
	MkSaveUndef('HAVE_CURL');
}

BEGIN
{
	my $n = 'curl';

	$DESCR{$n}   = 'libcurl';
	$URL{$n}     = 'http://curl.haxx.se';
	$TESTS{$n}   = \&TEST_curl;
	$DISABLE{$n} = \&DISABLE_curl;
	$DEPS{$n}    = 'cc';
	$SAVED{$n}   = 'CURL_CFLAGS CURL_LIBS';
}
;1
