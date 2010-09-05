my $testCode = << 'EOF';
#include <bsd/bsd.h>

int main(int argc, char *argv[]) {
  int size;
  char dst[4];
  char src[3] = "foo";
  size = strlcpy(dst, src, 4);
  if (size < sizeof(src))
    return (1);
  else
    return (0);
}
EOF

sub Test
{
	my ($ver, $pfx) = @_;
	
	MkExecPkgConfig($pfx, 'libbsd', '--version', 'LIBBSD_VERSION');
	MkExecPkgConfig($pfx, 'libbsd', '--cflags', 'LIBBSD_CFLAGS');
	MkExecPkgConfig($pfx, 'libbsd', '--libs', 'LIBBSD_LIBS');
	MkIfNE('${LIBBSD_VERSION}', '');
		MkFoundVer($pfx, $ver, 'LIBBSD_VERSION');
		MkPrintN('checking whether libbsd works...');
		MkCompileC('HAVE_LIBBSD',
		           '${LIBBSD_CFLAGS}', '${LIBBSD_LIBS}',
		           $testCode);
		MkSaveIfTrue('${HAVE_LIBBSD}', 'LIBBSD_CFLAGS', 'LIBBSD_LIBS');
	MkElse;
		MkNotFound($pfx);
		MkSaveUndef('HAVE_LIBBSD', 'LIBBSD_CFLAGS', 'LIBBSD_LIBS');
	MkEndif;
	return (0);
}

BEGIN
{
	$TESTS{'libbsd'} = \&Test;
	$DESCR{'libbsd'} = 'Libbsd (http://libbsd.freedesktop.org/)';
	$DEPS{'libbsd'} = 'cc';
}

;1