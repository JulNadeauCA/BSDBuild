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
	
	MkExecPkgConfig($pfx, 'libbsd', '--modversion', 'LIBBSD_VERSION');
	MkExecPkgConfig($pfx, 'libbsd', '--cflags', 'LIBBSD_CFLAGS');
	MkExecPkgConfig($pfx, 'libbsd', '--libs', 'LIBBSD_LIBS');
	MkIfFound($pfx, $ver, 'LIBBSD_VERSION');
		MkPrintN('checking whether libbsd works...');
		MkCompileC('HAVE_LIBBSD',
		           '${LIBBSD_CFLAGS}', '${LIBBSD_LIBS}',
		           $testCode);
		MkSaveIfTrue('${HAVE_LIBBSD}', 'LIBBSD_CFLAGS', 'LIBBSD_LIBS');
	MkElse;
		MkSaveUndef('HAVE_LIBBSD', 'LIBBSD_CFLAGS', 'LIBBSD_LIBS');
	MkEndif;
	return (0);
}

BEGIN
{
	$DESCR{'libbsd'} = 'Libbsd';
	$URL{'libbsd'} = 'http://libbsd.freedesktop.org';

	$TESTS{'libbsd'} = \&Test;
	$DEPS{'libbsd'} = 'cc';
}

;1
