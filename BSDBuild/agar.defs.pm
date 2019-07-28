# Public domain
# vim:ts=4

my @core_options = qw(
	ag_debug
	ag_enable_dso
	ag_enable_exec
	ag_enable_string
	have_64bit
	have_float
	have_long_double
    ag_legacy
	ag_namespaces
	ag_serialization
	ag_threads
	ag_timers
	ag_type_safety
	ag_unicode
	ag_user
	ag_verbosity
);
my @core_constants = qw(
	AGAR_MAJOR_VERSION
	AGAR_MINOR_VERSION
	AGAR_PATCHLEVEL
	AG_SMALL
	AG_MEDIUM
	AG_LARGE
	AG_MODEL
	AG_CHAR_MAX
	AG_SIZE_MAX
	AG_OFFS_MAX
	AG_LITTLE_ENDIAN
	AG_BIG_ENDIAN
	AG_BYTEORDER
	AG_PATHNAME_MAX
	AG_FILENAME_MAX
	AG_ARG_MAX
	AG_BUFFER_MIN
	AG_BUFFER_MAX
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
	AG_List
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
	AG_Tree
	AG_TreeItem
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

my @gui_options = qw(
	have_freetype
	have_fontconfig
	have_opengl
	have_jpeg
	have_png
	have_x11
	have_xinerama
	have_glx
	have_sdl
	have_wgl
	have_cocoa
);
my @gui_constants = qw(
	AG_COMPONENT_BITS
	AG_COLOR_FIRST
	AG_COLOR_LAST
	AG_GRAPH_LABEL_MAX
	AG_LABEL_MAX
	AG_LABEL_MAX_POLLPTRS
	AG_NOTEBOOK_LABEL_MAX
	AG_OPAQUE
	AG_STATUSBAR_MAX_LABELS
	AG_STYLE_VALUE_MAX
	AG_TABLE_TXT_MAX
	AG_TABLE_FMT_MAX
	AG_TABLE_COL_NAME_MAX
	AG_TABLE_HASHBUF_MAX
	AG_TEXT_STATES_MAX
	AG_TRANSPARENT
	AG_TLIST_LABEL_MAX
	AG_TOOLBAR_MAX_ROWS
	AG_WINDOW_CAPTION_MAX
	AG_ZOOM_DEFAULT
	AG_ZOOM_RANGE
);
my @gui_sizeofs = (
	'AG_Action',
	'AG_ActionTie',
	'AG_AnimFrame',
	'AG_CachedText',
	'AG_Color',
	'AG_ColorOffset',
	'AG_ConsoleLine',
	'AG_CursorArea',
	'AG_EditableClipboard',
	'AG_EditableBuffer',
	'AG_FileOption',
	'AG_FileType',
	'AG_FixedPlotterItem',
	'AG_FlagDescr',
	'AG_Font',
	'AG_FontSpec',
	'AG_Glyph',
	'AG_GlyphCache',
	'AG_GraphEdge',
	'AG_GraphVertex',
	'AG_MenuItem',
	'AG_Palette',
	'AG_PixelFormat',
	'AG_RadioItem',
	'AG_Rect',
	'AG_RedrawTie',
	'AG_SizeReq',
	'AG_SizeAlloc',
	'AG_StaticFont',
	'AG_StaticIcon',
	'AG_Surface',
	'struct ag_keycode',
	'struct ag_key_composition',
	'struct ag_key_mapping',
	'AG_TableBucket',
	'AG_TableCell',
	'AG_TableCol',
	'AG_TablePopup',
	'AG_TextCacheBucket',
	'AG_TextMetrics',
	'AG_TextState',
	'AG_TlistItem',
	'AG_TlistItemQ',
	'AG_TlistPopup',
	'AG_TreetblCell',
	'AG_TreetblCol',
	'AG_TreetblRow',
	'AG_TreetblRowQ',
	'AG_Unit',
	'AG_VectorElement',
	'AG_Widget',
	'AG_WidgetGL',
	'AG_WidgetPalette',
	'AG_WidgetPvt',
	'AG_Window',
	'AG_WindowPvt'
);

my $mainCode = << 'EOF';
int
main(int argc, char *argv[])
{
	AG_AgarVersion ver;
	AG_CPUInfo cpuinfo;
	unsigned int i;
	FILE *f;

	if ((f = fopen("agar.def", "w")) == NULL) {
		printf("Cannot write agar.def\n");
		return (1);
	}

	AG_InitCore(NULL, 0);

	fprintf(f, "-- Compiled Agar definitions on this system\n-- ex:syn=ada\n--\n");
	fprintf(f, "-- This file was generated by the agar.defs module of a BSDBuild\n");
	fprintf(f, "-- compiled configure script <http://bsdbuild.hypertriton.com>.\n--\n");
	AG_GetVersion(&ver);
	fprintf(f, "-- Agar Version %d.%d.%d\n", ver.major, ver.minor, ver.patch);
	AG_GetCPUInfo(&cpuinfo);
	fprintf(f, "-- Platform: %s (%s, 0x%x)\n--\n", cpuinfo.arch, cpuinfo.vendorID,
	    cpuinfo.ext);
	fprintf(f, "-- Agar Build Definitions\n--\n");
	for (i = 0; i < sizeof(booldefs) / sizeof(booldefs[0]); i++) {
		fprintf(f, "%s := %s\n", booldefs[i].name,
	        strcmp("yes", booldefs[i].value) == 0 ? "True" : "False");
	}
	fprintf(f, "--\n-- Agar Constants\n--\n");
	for (i = 0; i < sizeof(constants) / sizeof(constants[0]); i++) {
#ifdef AG_HAVE_64BIT
		fprintf(f, "%s := %llu\n", constants[i].name, constants[i].value);
#else
		fprintf(f, "%s := %lu\n", constants[i].name, constants[i].value);
#endif
	}
	fprintf(f, "--\n-- Agar Sizes of Things\n--\n");
	for (i = 0; i < sizeof(sizeofs) / sizeof(sizeofs[0]); i++) {
		fprintf(f, "%s := %lu\n", sizeofs[i].name, sizeofs[i].value);
	}
	
	fclose(f);
	AG_Quit();
	return (0);
}
EOF

sub TEST_agar_defs
{
	my ($ver, $pfx) = @_;
	my $testCode = << 'EOF';
#include <stdio.h>
#include <string.h>
#include <agar/core.h>
#include <agar/gui.h>
EOF
	#
	# Build Options
	#
	foreach my $opt (@core_options, @gui_options) {
		$testCode .= '#include <agar/config/' . $opt . ".h>\n";
	}
	$testCode .= << 'EOF';
static const struct {
	const char *name;
	const char *value;
} booldefs[] = {
EOF
	foreach my $opt (@core_options, @gui_options) {
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
	foreach my $con (@core_constants, @gui_constants) {
		$testCode .= << "EOF";
	{ "$con", $con },
EOF
	}
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
	foreach my $szo (@core_sizeofs, @gui_sizeofs) {
		my $szo_uc = uc($szo);
		$szo_uc =~ tr/ /_/;
		$testCode .= << "EOF";
	{ "SIZEOF_$szo_uc", sizeof($szo) },
EOF
	}
	$testCode .= "};\n";

	$testCode .= $mainCode;

	MkExecOutputPfx($pfx, 'agar-config', '--version', 'AGAR_VERSION');
	MkIfFound($pfx, $ver, 'AGAR_VERSION');
		MkPrintSN('checking Agar definitions...');
		MkExecOutputPfx($pfx, 'agar-config', '--cflags', 'AGAR_CFLAGS');
		MkExecOutputPfx($pfx, 'agar-config', '--libs', 'AGAR_LIBS');
		MkCompileAndRunC('HAVE_AGAR_DEFS', '${AGAR_CFLAGS}', '${AGAR_LIBS}',
	                     $testCode);
	MkElse;
		DISABLE_agar_defs();
	MkEndif;
}

sub DISABLE_agar_defs
{
	MkDefine('HAVE_AGAR_DEFS', 'no');
	MkSaveUndef('HAVE_AGAR_DEFS');
}

BEGIN
{
	my $n = 'agar.defs';

	$DESCR{$n}   = 'Agar definitions';
	$URL{$n}     = 'http://libagar.org';

	$TESTS{$n}   = \&TEST_agar_defs;
	$DISABLE{$n} = \&DISABLE_agar_defs;

	$DEPS{$n}    = 'cc';
}
;1
