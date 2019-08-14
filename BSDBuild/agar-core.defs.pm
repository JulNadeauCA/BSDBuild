# Public domain
# vim:ts=4

my @core_options = qw(
	ag_debug
	ag_enable_dso
	ag_enable_exec
	ag_enable_string
    ag_legacy
	ag_namespaces
	ag_serialization
	ag_threads
	ag_timers
	ag_type_safety
	ag_unicode
	ag_user
	ag_verbosity
	have_64bit
	have_float
	have_long_double
);
my @core_constants = qw(
	AG_SMALL
	AG_MEDIUM
	AG_LARGE
	AG_MODEL
	AGAR_MAJOR_VERSION
	AGAR_MINOR_VERSION
	AGAR_PATCHLEVEL
	AG_ARG_MAX
	AG_BIG_ENDIAN
	AG_BYTEORDER
	AG_BUFFER_MIN
	AG_BUFFER_MAX
	AG_CHAR_MAX
	AG_DSONAME_MAX
	AG_EVENT_ARGS_MAX
	AG_EVENT_NAME_MAX
	AG_FILENAME_MAX
	AG_LITTLE_ENDIAN
	AG_LOAD_STRING_MAX
	AG_OBJECT_HIER_MAX
	AG_OBJECT_LIBS_MAX
	AG_OBJECT_NAME_MAX
	AG_OBJECT_PATH_MAX
	AG_OBJECT_TYPE_MAX
	AG_OFFS_MAX
	AG_PATHNAME_MAX
	AG_SIZE_MAX
	AG_TIMER_NAME_MAX
	AG_USER_NAME_MAX
	AG_VARIABLE_NAME_MAX
	AG_VERSION_NAME_MAX
	AG_VERSION_MAX
);
my @core_sizeofs = qw(
	AG_AgarVersion
	AG_CPUInfo
	AG_Cond
	AG_Config
	AG_ConstCoreSource
	AG_CoreSource
	AG_DSO
	AG_DSOSym
	AG_DataSource
	AG_Db
	AG_Dbt
	AG_Dir
	AG_Event
	AG_EventSink
	AG_EventSource
	AG_FileExtMapping
	AG_FileInfo
	AG_FileSource
	AG_FmtString
	AG_FmtStringExt
	AG_Function
	AG_Mutex
	AG_MutexAttr
	AG_Namespace
	AG_NetAcceptFilter
	AG_NetAddr
	AG_NetOps
	AG_NetSocket
	AG_NetSocketSource
	AG_Object
	AG_ObjectClass
	AG_ObjectClassPvt
	AG_ObjectHeader
	AG_ObjectPvt
	AG_Tbl
	AG_TblBucket
	AG_Text
	AG_TextElement
	AG_TextEnt
	AG_Thread
	AG_ThreadKey
	AG_Timer
	AG_TimerPvt
	AG_TimeOps
	AG_User
	AG_UserOps
	AG_Variable
	AG_VariableTypeInfo
);

my $mainCode = << 'EOF';
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
	fprintf(f, "-- This file was generated by the agar-core.defs module of a BSDBuild\n");
	fprintf(f, "-- compiled configure script <http://bsdbuild.hypertriton.com>.\n--\n");
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
	fprintf(f, "--\n-- Agar-Core Sizes of Things\n--\n");
	for (i = 0; i < sizeof(sizeofs) / sizeof(sizeofs[0]); i++) {
		fprintf(f, "%s := %lu\n", sizeofs[i].name, sizeofs[i].value);
	}
	
	fclose(f);
	AG_Quit();
	return (0);
}
EOF

sub TEST_agar_core_defs
{
	my ($ver, $pfx) = @_;
	my $testCode = << 'EOF';
#include <stdio.h>
#include <string.h>
#include <agar/core.h>
EOF
	#
	# Build Options
	#
	foreach my $opt (@core_options) {
		$testCode .= '#include <agar/config/' . $opt . ".h>\n";
	}
	$testCode .= << 'EOF';
static const struct {
	const char *name;
	const char *value;
} booldefs[] = {
EOF
	foreach my $opt (@core_options) {
		my $def = uc($opt);
		$testCode .= << "EOF";
#ifdef $def
	{ "$def", "yes" },
#else
	{ "$def", "no" },
#endif
EOF
	}
	#
	# Constants
	#
	$testCode .= << 'EOF';
};
static const struct {
	const char *name;
#ifdef AG_HAVE_64BIT
	unsigned long long value;
#else
	unsigned long value;
#endif
} constants[] = {
EOF
	foreach my $con (@core_constants) {
		$testCode .= << "EOF";
	{ "$con", $con },
EOF
	};
	$testCode .= "};\n";
	#
	# Sizes of Things
	#
	$testCode .= << 'EOF';
static const struct {
	const char *name;
	unsigned long value;
} sizeofs[] = {
EOF
	foreach my $szo (@core_sizeofs) {
		my $szo_uc = uc($szo);
		$szo_uc =~ tr/ /_/;
		$testCode .= << "EOF";
	{ "SIZEOF_$szo_uc", sizeof($szo) },
EOF
	}
	$testCode .= "};\n";
	$testCode .= $mainCode;
	
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

	$DESCR{$n}   = 'Agar-Core definitions';
	$URL{$n}     = 'http://libagar.org';

	$TESTS{$n}   = \&TEST_agar_core_defs;
	$DISABLE{$n} = \&DISABLE_agar_core_defs;

	$DEPS{$n}    = 'cc';
}
;1
