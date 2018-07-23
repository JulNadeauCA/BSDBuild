# vim:ts=4
#
# Copyright (c) 2018 Julien Nadeau Carriere <vedge@hypertriton.com>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
# USE OF THIS SOFTWARE EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

my $testCode = << 'EOF';
#include <stdio.h>

#include <agar/core.h>
#include <agar/gui.h>

static const struct {
	const char *name;
	unsigned    value;
} constants[] = {
	{ "AG_CONSOLE_LINE_MAX",	AG_CONSOLE_LINE_MAX },		/* console.h */
	{ "AG_CURSOR_MAX_W",		AG_CURSOR_MAX_W },			/* cursors.h */
	{ "AG_CURSOR_MAX_H",		AG_CURSOR_MAX_H },			/* cursors.h */
	{ "AG_GRAPH_LABEL_MAX",		AG_GRAPH_LABEL_MAX },		/* graph.h */
	{ "AG_LABEL_MAX",			AG_LABEL_MAX },				/* label.h */
	{ "AG_LABEL_MAX_POLLPTRS",	AG_LABEL_MAX_POLLPTRS },	/* label.h */
	{ "AG_NOTEBOOK_LABEL_MAX",	AG_NOTEBOOK_LABEL_MAX },	/* notebook.h */
	{ "AG_STATUSBAR_MAX_LABELS",AG_STATUSBAR_MAX_LABELS },	/* statusbar.h */
	{ "AG_STYLE_VALUE_MAX",		AG_STYLE_VALUE_MAX },		/* stylesheet.h */
	{ "AG_TABLE_TXT_MAX",		AG_TABLE_TXT_MAX },			/* table.h */
	{ "AG_TABLE_FMT_MAX",		AG_TABLE_FMT_MAX },			/* table.h */
	{ "AG_TABLE_COL_NAME_MAX",	AG_TABLE_COL_NAME_MAX },	/* table.h */
	{ "AG_TABLE_HASHBUF_MAX",	AG_TABLE_HASHBUF_MAX },		/* table.h */
	{ "AG_TEXT_STATES_MAX",		AG_TEXT_STATES_MAX },		/* text.h */
	{ "AG_TLIST_LABEL_MAX",		AG_TLIST_LABEL_MAX },		/* tlist.h */
	{ "AG_TLIST_ARGS_MAX",		AG_TLIST_ARGS_MAX },		/* tlist.h */
	{ "AG_TOOLBAR_MAX_ROWS",	AG_TOOLBAR_MAX_ROWS },		/* toolbar.h */
	{ "AG_TREETBL_LABEL_MAX",	AG_TREETBL_LABEL_MAX },		/* treetbl.h */
	{ "AG_WINDOW_CAPTION_MAX",	AG_WINDOW_CAPTION_MAX },	/* window.h */
};

static const struct {
	const char *name;
	size_t      size;
} nonobject_types[] = {
	{ "AG_ConsoleLine",			sizeof(AG_ConsoleLine) },		/* console.h */
	{ "AG_EditableBuffer",		sizeof(AG_EditableBuffer) },	/* editable.h */
	{ "AG_EditableClipboard",	sizeof(AG_EditableClipboard) },
	{ "AG_FileOption",			sizeof(AG_FileOption) },		/* file_dlg.h */
	{ "AG_FileType",			sizeof(AG_FileType) },
	{ "AG_FixedPlotterItem",	sizeof(AG_FixedPlotterItem) },	/* fixed_plotter.h */
	{ "AG_GraphVertex",			sizeof(AG_GraphVertex) },		/* graph.h */
	{ "AG_GraphEdge",			sizeof(AG_GraphEdge) },
	{ "AG_StaticIcon",			sizeof(AG_StaticIcon) },		/* iconmgr.h */
	{ "struct ag_keycode",		sizeof(struct ag_keycode) },	/* keymap.h */
	{ "struct ag_key_composition", sizeof(struct ag_key_composition) },
	{ "struct ag_key_mapping",	sizeof(struct ag_key_mapping) },
	{ "AG_MenuItem",			sizeof(AG_MenuItem) },			/* menu.h */
	{ "AG_RadioItem",			sizeof(AG_RadioItem) },			/* radio.h */
	{ "AG_TablePopup",			sizeof(AG_TablePopup) },		/* table.h */
	{ "AG_TableCell",			sizeof(AG_TableCell) },
	{ "AG_TableBucket",			sizeof(AG_TableBucket) },
	{ "AG_TableCol",			sizeof(AG_TableCol) },
	{ "AG_FontSpec",			sizeof(AG_FontSpec) },			/* text.h */
	{ "AG_Glyph",				sizeof(AG_Glyph) },
	{ "AG_TextState",			sizeof(AG_TextState) },
	{ "AG_StaticFont",			sizeof(AG_StaticFont) },
	{ "AG_TextMetrics",			sizeof(AG_TextMetrics) },
	{ "AG_GlyphCache",			sizeof(AG_GlyphCache) },
	{ "AG_CachedText",			sizeof(AG_CachedText) },		/* text_cache.h */
	{ "AG_TextCacheBucket",		sizeof(AG_TextCacheBucket) },
	{ "AG_TlistPopup",			sizeof(AG_TlistPopup) },		/* tlist.h */
	{ "AG_TlistItem",			sizeof(AG_TlistItem) },
	{ "AG_TlistItemQ",			sizeof(AG_TlistItemQ) },
	{ "AG_TreetblCol",			sizeof(AG_TreetblCol) },		/* treetbl.h */
	{ "AG_TreetblRowQ",			sizeof(AG_TreetblRowQ) },
	{ "AG_TreetblCell",			sizeof(AG_TreetblCell) },
	{ "AG_TreetblRow",			sizeof(AG_TreetblRow) },
	{ "AG_Unit",				sizeof(AG_Unit) },				/* units.h */
	{ "AG_SizeReq",				sizeof(AG_SizeReq) },			/* widget.h */
	{ "AG_SizeAlloc",			sizeof(AG_SizeAlloc) },
	{ "AG_WidgetClass",			sizeof(AG_WidgetClass) },
	{ "AG_FlagDescr",			sizeof(AG_FlagDescr) },
	{ "AG_Action",				sizeof(AG_Action) },
	{ "AG_ActionTie",			sizeof(AG_ActionTie) },
	{ "AG_RedrawTie",			sizeof(AG_RedrawTie) },
	{ "AG_CursorArea",			sizeof(AG_CursorArea) },
	{ "AG_WidgetPalette",		sizeof(AG_WidgetPalette) },
};

static void
PrintClass(FILE *f, AG_ObjectClass *C)
{
	AG_ObjectClass *Csub;

	fprintf(f, "%17s[%36s]: %lu: %u.%u",
	    C->name, C->hier, (unsigned long)C->size,
		C->ver.major, C->ver.minor);
	if (C->pvt.libs[0] != '\0') {
		fprintf(f, ": %s", C->pvt.libs);
	}
	fprintf(f, "\n");
	AG_TAILQ_FOREACH(Csub, &C->pvt.sub, pvt.subclasses)
		PrintClass(f, Csub);
}

int
main(int argc, char *argv[])
{
	AG_AgarVersion ver;
	AG_CPUInfo cpuinfo;
	unsigned int i;
	FILE *f;

	if ((f = fopen("agar.types", "w")) == NULL) {
		printf("Cannot write agar.types\n");
		return (1);
	}

	AG_InitCore("conf-test", 0);
	if (AG_InitGUIGlobals() == -1 ||
	    AG_InitGUI(0) == -1) {
		fclose(f);
		return (1);
	}

	fprintf(f, "# Compiled Agar-GUI type sizes on this system\n#\n");
	fprintf(f, "# This file was generated by the agar.types module of a BSDBuild\n");
	fprintf(f, "# based ./configure script <http://bsdbuild.hypertriton.com>.\n#\n");
	AG_GetVersion(&ver);
	fprintf(f, "# Agar Version %d.%d.%d\n", ver.major, ver.minor, ver.patch);
	AG_GetCPUInfo(&cpuinfo);
	fprintf(f, "# Platform: %s (%s, 0x%x)\n#\n", cpuinfo.arch, cpuinfo.vendorID,
	    cpuinfo.ext);
	fprintf(f, "# Agar-GUI constants\n#\n");
	for (i = 0; i < sizeof(constants) / sizeof(constants[0]); i++)
		fprintf(f, "%s:%u\n", constants[i].name, constants[i].value);

	fprintf(f, "#\n# Size of AG_Object(3) derived classes\n#\n");
	PrintClass(f, agClassTree);
		
	fprintf(f, "#\n# Size of other types\n#\n");
	for (i = 0; i < sizeof(nonobject_types) / sizeof(nonobject_types[0]); i++)
		fprintf(f, "%s:%lu\n", nonobject_types[i].name, nonobject_types[i].size);
	
	fclose(f);
	AG_Quit();
	return (0);
}
EOF

sub Test
{
	my ($ver, $pfx) = @_;
	
	MkExecOutputPfx($pfx, 'agar-config', '--version', 'AGAR_VERSION');
	MkIfFound($pfx, $ver, 'AGAR_VERSION');
		MkPrintSN('checking Agar type sizes...');
		MkExecOutputPfx($pfx, 'agar-config', '--cflags', 'AGAR_CFLAGS');
		MkExecOutputPfx($pfx, 'agar-config', '--libs', 'AGAR_LIBS');
		MkCompileAndRunC('HAVE_AGAR_TYPES', '${AGAR_CFLAGS}', '${AGAR_LIBS}',
				         $testCode);
	MkEndif;
	return (0);
}

BEGIN
{
	$DESCR{'agar.types'} = 'Agar types';
	$URL{'agar.types'} = 'http://libagar.org';

	$TESTS{'agar.types'} = \&Test;
	$DEPS{'agar.types'} = 'cc';
}

;1
