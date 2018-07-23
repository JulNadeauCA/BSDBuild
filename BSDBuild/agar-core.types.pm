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

static const struct {
	const char *name;
	unsigned    value;
} constants[] = {
	{ "AG_OBJECT_NAME_MAX",		AG_OBJECT_NAME_MAX },		/* object.h */
	{ "AG_OBJECT_TYPE_MAX",		AG_OBJECT_TYPE_MAX },
	{ "AG_OBJECT_HIER_MAX",		AG_OBJECT_HIER_MAX },
	{ "AG_OBJECT_PATH_MAX",		AG_OBJECT_PATH_MAX },
	{ "AG_OBJECT_LIBS_MAX",		AG_OBJECT_LIBS_MAX },
	{ "AG_DSONAME_MAX",			AG_DSONAME_MAX },			/* dso.h */
	{ "AG_EVENT_ARGS_MAX",		AG_EVENT_ARGS_MAX },		/* event.h */
	{ "AG_EVENT_NAME_MAX",		AG_EVENT_NAME_MAX },
	{ "AG_PATHNAME_MAX",		AG_PATHNAME_MAX },			/* limits.h */
	{ "AG_FILENAME_MAX",		AG_FILENAME_MAX },
	{ "AG_LOAD_STRING_MAX",		AG_LOAD_STRING_MAX },		/* load_string.h */
	{ "AG_VERSION_NAME_MAX",	AG_VERSION_NAME_MAX },		/* load_version.h */
	{ "AG_VERSION_MAX",			AG_VERSION_MAX },
	{ "AG_TIMER_NAME_MAX",		AG_TIMER_NAME_MAX },		/* time.h */
	{ "AG_USER_NAME_MAX",		AG_USER_NAME_MAX },			/* user.h */
	{ "AG_VARIABLE_NAME_MAX",	AG_VARIABLE_NAME_MAX },		/* variable.h */
};

static const struct {
	const char *name;
	size_t      size;
} nonobject_types[] = {
	{ "AG_AgarVersion",		sizeof(AG_AgarVersion),		},
	{ "AG_CPUInfo",			sizeof(AG_CPUInfo),			},
	{ "AG_Cond",			sizeof(AG_Cond),			},
	{ "AG_CoreSource",		sizeof(AG_CoreSource),		},
	{ "AG_ConstCoreSource",	sizeof(AG_ConstCoreSource),	},
	{ "AG_DSO",				sizeof(AG_DSO),				},
	{ "AG_DSOSym",			sizeof(AG_DSOSym),			},
	{ "AG_DataSource",		sizeof(AG_DataSource),		},
	{ "AG_Dbt",				sizeof(AG_Dbt),				},
	{ "AG_Dir",				sizeof(AG_Dir),				},
	{ "AG_Event",			sizeof(AG_Event),			},
	{ "AG_EventQ",			sizeof(AG_EventQ),			},
	{ "AG_EventSink",		sizeof(AG_EventSink),		},
	{ "AG_EventSource",		sizeof(AG_EventSource),		},
	{ "AG_FileExtMapping",	sizeof(AG_FileExtMapping),	},
	{ "AG_FileInfo",		sizeof(AG_FileInfo),		},
	{ "AG_FileSource",		sizeof(AG_FileSource),		},
	{ "AG_FmtString",		sizeof(AG_FmtString),		},
	{ "AG_FmtStringExt",	sizeof(AG_FmtStringExt),	},
	{ "AG_Function",		sizeof(AG_Function),		},
	{ "AG_List",			sizeof(AG_List),			},
	{ "AG_Mutex",			sizeof(AG_Mutex),			},
	{ "AG_MutexAttr",		sizeof(AG_MutexAttr),		},
	{ "AG_Namespace",		sizeof(AG_Namespace),		},
	{ "AG_NetAcceptFilter",	sizeof(AG_NetAcceptFilter),	},
	{ "AG_NetAddr",			sizeof(AG_NetAddr),			},
	{ "AG_NetOps",			sizeof(AG_NetOps),			},
	{ "AG_NetSocket",		sizeof(AG_NetSocket),		},
	{ "AG_NetSocketSource",	sizeof(AG_NetSocketSource),	},
	{ "AG_ObjectClass",		sizeof(AG_ObjectClass),		},
	{ "AG_ObjectClassPvt",	sizeof(AG_ObjectClassPvt),	},
	{ "AG_ObjectDep",		sizeof(AG_ObjectDep),		},
	{ "AG_ObjectHeader",	sizeof(AG_ObjectHeader),	},
	{ "AG_ObjectPvt",		sizeof(AG_ObjectPvt),		},
	{ "AG_Tbl",				sizeof(AG_Tbl),				},
	{ "AG_TblBucket",		sizeof(AG_TblBucket),		},
	{ "AG_Tree",			sizeof(AG_Tree),			},
	{ "AG_TreeItem",		sizeof(AG_TreeItem),		},
	{ "AG_Text",			sizeof(AG_Text),			},
	{ "AG_TextElement",		sizeof(AG_TextElement),		},
	{ "AG_TextEnt",			sizeof(AG_TextEnt),			},
	{ "AG_Thread",			sizeof(AG_Thread),			},
	{ "AG_ThreadKey",		sizeof(AG_ThreadKey),		},
	{ "AG_Timer",			sizeof(AG_Timer),			},
	{ "AG_TimerPvt",		sizeof(AG_TimerPvt),		},
	{ "AG_TimeOps",			sizeof(AG_TimeOps),			},
	{ "AG_User",			sizeof(AG_User),			},
	{ "AG_UserOps",			sizeof(AG_UserOps),			},
	{ "AG_Variable",		sizeof(AG_Variable),		},
	{ "AG_VariableTypeInfo",sizeof(AG_VariableTypeInfo),},
};

static void
PrintClass(FILE *f, AG_ObjectClass *C)
{
	AG_ObjectClass *Csub;

	fprintf(f, "# %s [%s]: %u.%u%s%s\n", C->name, C->hier,
	    C->ver.major, C->ver.minor,
		(C->pvt.libs[0] != '\0') ? " @" : "", C->pvt.libs);
	fprintf(f, "%s:%lu\n", C->name, (unsigned long)C->size);

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

	if ((f = fopen("agar-core.types", "w")) == NULL) {
		printf("Cannot write agar-core.types\n");
		return (1);
	}

	AG_InitCore("conf-test", 0);
	fprintf(f, "# Compiled Agar-Core type sizes on this system\n#\n");
	fprintf(f, "# This file was generated by the agar-core.types module of a BSDBuild\n");
	fprintf(f, "# based ./configure script <http://bsdbuild.hypertriton.com>.\n#\n");
	AG_GetVersion(&ver);
	fprintf(f, "# Agar Version %d.%d.%d\n", ver.major, ver.minor, ver.patch);
	AG_GetCPUInfo(&cpuinfo);
	fprintf(f, "# Platform: %s (%s, 0x%x)\n#\n", cpuinfo.arch, cpuinfo.vendorID,
	    cpuinfo.ext);
	fprintf(f, "# Agar-Core constants\n#\n");
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
	
	MkExecOutputPfx($pfx, 'agar-core-config', '--version', 'AGAR_VERSION');
	MkIfFound($pfx, $ver, 'AGAR_CORE_VERSION');
		MkPrintSN('checking Agar-Core type sizes...');
		MkExecOutputPfx($pfx, 'agar-core-config', '--cflags', 'AGAR_CORE_CFLAGS');
		MkExecOutputPfx($pfx, 'agar-core-config', '--libs', 'AGAR_CORE_LIBS');
		MkCompileAndRunC('HAVE_AGAR_CORE_TYPES', '${AGAR_CORE_CFLAGS}',
		    '${AGAR_CORE_LIBS}', $testCode);
	MkEndif;
	return (0);
}

BEGIN
{
	$DESCR{'agar-core.types'} = 'Agar-Core types';
	$URL{'agar-core.types'} = 'http://libagar.org';
	$TESTS{'agar-core.types'} = \&Test;
	$DEPS{'agar-core.types'} = 'cc';
}

;1
