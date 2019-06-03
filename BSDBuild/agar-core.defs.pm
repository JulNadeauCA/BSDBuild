# Public domain
# vim:ts=4

my $testCode = << 'EOF';
#include <stdio.h>
#include <string.h>

#include <agar/core.h>

static const struct {
	const char *name;
	const char *value;
} booldefs[] = {
#ifdef AG_DEBUG
	{ "AG_DEBUG", "yes" },
#else
	{ "AG_DEBUG", "no" },
#endif
#ifdef AG_ENABLE_DSO
	{ "AG_ENABLE_DSO", "yes" },
#else
	{ "AG_ENABLE_DSO", "no" },
#endif
#ifdef AG_ENABLE_EXEC
	{ "AG_ENABLE_EXEC", "yes" },
#else
	{ "AG_ENABLE_EXEC", "no" },
#endif
#ifdef AG_ENABLE_STRING
	{ "AG_ENABLE_STRING", "yes" },
#else
	{ "AG_ENABLE_STRING", "no" },
#endif
#ifdef AG_HAVE_64BIT
	{ "AG_HAVE_64BIT", "yes" },
#else
	{ "AG_HAVE_64BIT", "no" },
#endif
#ifdef AG_HAVE_FLOAT
	{ "AG_HAVE_FLOAT", "yes" },
#else
	{ "AG_HAVE_FLOAT", "no" },
#endif
#ifdef AG_HAVE_LONG_DOUBLE
	{ "AG_HAVE_LONG_DOUBLE", "yes" },
#else
	{ "AG_HAVE_LONG_DOUBLE", "no" },
#endif
#ifdef AG_LEGACY
	{ "AG_LEGACY", "yes" },
#else
	{ "AG_LEGACY", "no" },
#endif
#ifdef AG_NAMESPACES
	{ "AG_NAMESPACES", "yes" },
#else
	{ "AG_NAMESPACES", "no" },
#endif
#ifdef AG_SERIALIZATION
	{ "AG_SERIALIZATION", "yes" },
#else
	{ "AG_SERIALIZATION", "no" },
#endif
#ifdef AG_THREADS
	{ "AG_THREADS", "yes" },
#else
	{ "AG_THREADS", "no" },
#endif
#ifdef AG_TIMERS
	{ "AG_TIMERS", "yes" },
#else
	{ "AG_TIMERS", "no" },
#endif
#ifdef AG_TYPE_SAFETY
	{ "AG_TYPE_SAFETY", "yes" },
#else
	{ "AG_TYPE_SAFETY", "no" },
#endif
#ifdef AG_UNICODE
	{ "AG_UNICODE", "yes" },
#else
	{ "AG_UNICODE", "no" },
#endif
#ifdef AG_USER
	{ "AG_USER", "yes" },
#else
	{ "AG_USER", "no" },
#endif
#ifdef AG_VERBOSITY
	{ "AG_VERBOSITY", "yes" },
#else
	{ "AG_VERBOSITY", "no" },
#endif
};

static const struct {
	const char *name;
#ifdef AG_HAVE_64BIT
	unsigned long long value;
#else
	unsigned long value;
#endif
} constants[] = {
	{ "AGAR_MAJOR_VERSION",	AGAR_MAJOR_VERSION },	/* version.h */
	{ "AGAR_MINOR_VERSION",	AGAR_MINOR_VERSION },	/* version.h */
	{ "AGAR_PATCHLEVEL",	AGAR_PATCHLEVEL},		/* version.h */
	{ "AG_SMALL",			AG_SMALL },				/* types.h */
	{ "AG_MEDIUM",			AG_MEDIUM },
	{ "AG_LARGE",			AG_LARGE },
	{ "AG_MODEL",			AG_MODEL },
	{ "AG_CHAR_MAX",		AG_CHAR_MAX },
	{ "AG_SIZE_MAX",		AG_SIZE_MAX },
	{ "AG_OFFS_MAX",		AG_OFFS_MAX },
	{ "AG_LITTLE_ENDIAN",	AG_LITTLE_ENDIAN },		/* core_begin.h */
	{ "AG_BIG_ENDIAN",		AG_BIG_ENDIAN },
	{ "AG_BYTEORDER",		AG_BYTEORDER },
	{ "AG_PATHNAME_MAX",	AG_PATHNAME_MAX },		/* limits.h */
	{ "AG_FILENAME_MAX",	AG_FILENAME_MAX },
	{ "AG_ARG_MAX",			AG_ARG_MAX },
	{ "AG_BUFFER_MIN",		AG_BUFFER_MIN },
	{ "AG_BUFFER_MAX",		AG_BUFFER_MAX },
};

int
main(int argc, char *argv[])
{
	AG_AgarVersion ver;
	AG_CPUInfo cpuinfo;
	unsigned int i;
	FILE *f;

	if ((f = fopen("agar-core.def", "w")) == NULL) {
		printf("Cannot write agar-core.def\n");
		return (1);
	}

	AG_InitCore(NULL, 0);
	fprintf(f, "-- Compiled Agar-Core definitions on this system\n-- ex:syn=ada\n--\n");
	fprintf(f, "-- This file was generated by the agar-core.defs module of a\n");
	fprintf(f, "-- BSDBuild configure script <http://bsdbuild.hypertriton.com>.\n--\n");
	AG_GetVersion(&ver);
	fprintf(f, "-- Agar Version %d.%d.%d\n", ver.major, ver.minor, ver.patch);
	AG_GetCPUInfo(&cpuinfo);
	fprintf(f, "-- Platform: %s (%s, 0x%x)\n--\n", cpuinfo.arch, cpuinfo.vendorID,
	    cpuinfo.ext);
	fprintf(f, "-- Agar-Core Build Definitions\n--\n");
	for (i = 0; i < sizeof(booldefs) / sizeof(booldefs[0]); i++) {
		fprintf(f, "%s := %s\n", booldefs[i].name,
	        strcmp("yes", booldefs[i].value) == 0 ? "True" : "False");
	}
	fprintf(f, "--\n-- Agar-Core Constants\n--\n");
	for (i = 0; i < sizeof(constants) / sizeof(constants[0]); i++) {
#ifdef AG_HAVE_64BIT
		fprintf(f, "%s := %llu\n", constants[i].name, constants[i].value);
#else
		fprintf(f, "%s := %lu\n", constants[i].name, constants[i].value);
#endif
	}
	
	fclose(f);
	AG_Quit();
	return (0);
}
EOF

sub TEST_agar_core_defs
{
	my ($ver, $pfx) = @_;
	
	MkExecOutputPfx($pfx, 'agar-core-config', '--version', 'AGAR_VERSION');
	MkIfFound($pfx, $ver, 'AGAR_VERSION');
		MkPrintSN('checking Agar-Core definitions...');
		MkExecOutputPfx($pfx, 'agar-core-config', '--cflags', 'AGAR_CORE_CFLAGS');
		MkExecOutputPfx($pfx, 'agar-core-config', '--libs', 'AGAR_CORE_LIBS');
		MkCompileAndRunC('HAVE_AGAR_CORE_DEFS', '${AGAR_CORE_CFLAGS}',
		    '${AGAR_CORE_LIBS}', $testCode);
	MkElse;
		DISABLE_agar_core_defs();
	MkEndif;
}

sub DISABLE_agar_core_defs
{
	MkDefine('HAVE_AGAR_CORE_DEFS', 'no');
	MkSaveUndef('HAVE_AGAR_CORE_DEFS');
}

BEGIN
{
	my $n = 'agar-core.defs';

	$DESCR{$n}   = 'Agar-Core preprocessor defs';
	$URL{$n}     = 'http://libagar.org';

	$TESTS{$n}   = \&TEST_agar_core_defs;
	$DISABLE{$n} = \&DISABLE_agar_core_defs;

	$DEPS{$n}    = 'cc';
}
;1
