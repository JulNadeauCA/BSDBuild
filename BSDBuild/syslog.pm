# Public domain

sub TEST_syslog
{
	TryCompile 'HAVE_SYSLOG', << 'EOF';
#include <syslog.h>
#include <stdarg.h>
int
main(int argc, char *argv[])
{
	syslog(LOG_DEBUG, "foo %d", 1);
	return (0);
}
EOF
	
	MkPrintSN('checking for syslog_r()...');
	TryCompile 'HAVE_SYSLOG_R', << 'EOF';
#include <syslog.h>
#include <stdarg.h>
int
main(int argc, char *argv[])
{
	struct syslog_data sdata = SYSLOG_DATA_INIT;
	syslog_r(LOG_ERR, &sdata, "foo %d", 1);
	return (0);
}
EOF

	MkPrintSN('checking for vsyslog()...');
	TryCompile 'HAVE_VSYSLOG', << 'EOF';
#include <syslog.h>
#include <stdarg.h>

void
foofn(const char *fmt, ...)
{
	va_list ap;
	va_start(ap, fmt);
	vsyslog(LOG_DEBUG, fmt, ap);
	va_end(ap);
}
int
main(int argc, char *argv[])
{
	foofn("foo %d", 1);
	return (0);
}
EOF
	
	MkPrintSN('checking for vsyslog_r()...');
	TryCompile 'HAVE_VSYSLOG_R', << 'EOF';
#include <syslog.h>
#include <stdarg.h>

void
foofn(const char *fmt, ...)
{
	va_list ap;
	struct syslog_data sdata = SYSLOG_DATA_INIT;
	va_start(ap, fmt);
	vsyslog_r(LOG_DEBUG, &sdata, fmt, ap);
	va_end(ap);
}
int
main(int argc, char *argv[])
{
	foofn("foo %d", 1);
	return (0);
}
EOF
}

sub DISABLE_syslog
{
	MkDefine('HAVE_SYSLOG', 'no');
	MkDefine('HAVE_SYSLOG_R', 'no');
	MkDefine('HAVE_VSYSLOG', 'no');
	MkDefine('HAVE_VSYSLOG_R', 'no');
	MkSaveUndef('HAVE_SYSLOG', 'HAVE_VSYSLOG', 'HAVE_SYSLOG_R', 'HAVE_VSYSLOG_R');
}

BEGIN
{
	my $n = 'syslog';

	$DESCR{$n}   = 'syslog()';
	$TESTS{$n}   = \&TEST_syslog;
	$DISABLE{$n} = \&DISABLE_syslog;
	$DEPS{$n}    = 'cc';
}
;1
