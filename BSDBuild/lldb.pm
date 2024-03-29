# Public domain

use BSDBuild::Core;

my $testCode = << 'EOF';
#include <stdlib.h>

#ifdef __APPLE__
# include <LLDB/LLDB.h>
#else
# include "lldb/API/SBBreakpoint.h"
# include "lldb/API/SBCommandInterpreter.h"
# include "lldb/API/SBCommandReturnObject.h"
# include "lldb/API/SBCommunication.h"
# include "lldb/API/SBBroadcaster.h"
# include "lldb/API/SBDebugger.h"
# include "lldb/API/SBStructuredData.h"
# include "lldb/API/SBEvent.h"
# include "lldb/API/SBHostOS.h"
# include "lldb/API/SBLanguageRuntime.h"
# include "lldb/API/SBListener.h"
# include "lldb/API/SBProcess.h"
# include "lldb/API/SBStream.h"
# include "lldb/API/SBStringList.h"
# include "lldb/API/SBTarget.h"
# include "lldb/API/SBThread.h"
#endif

#include <string>

using namespace lldb;

class LLDBSentry {
public:
	LLDBSentry() { SBDebugger::Initialize(); }
	~LLDBSentry() { SBDebugger::Terminate(); }
};

int
main(int argc, char const *argv[])
{
	LLDBSentry sentry;
	SBDebugger debugger(SBDebugger::Create());

	return !debugger.IsValid();
}
EOF

my $testCodeUtility = << 'EOF';
#include <stdlib.h>

#include "lldb/API/SBBlock.h"
#include "lldb/API/SBCompileUnit.h"
#include "lldb/API/SBDebugger.h"
#include "lldb/API/SBFunction.h"
#include "lldb/API/SBModule.h"
#include "lldb/API/SBProcess.h"
#include "lldb/API/SBStream.h"
#include "lldb/API/SBSymbol.h"
#include "lldb/API/SBTarget.h"
#include "lldb/API/SBThread.h"

#include "lldb/Utility/Stream.h"
#include "lldb/Utility/StringList.h"
#include "lldb/Utility/ArchSpec.h"

#include "llvm/Support/PrettyStackTrace.h"
#include "llvm/Support/Signals.h"

#include <string>

using namespace lldb;
using namespace lldb_private;

class LLDBSentry {
public:
	LLDBSentry() {
		SBDebugger::Initialize();
	}
	~LLDBSentry() {
		SBDebugger::Terminate();
	}
};

int
main(int argc, char const *argv[])
{
	LLDBSentry sentry;
	SBDebugger debugger(SBDebugger::Create());
	llvm::StringRef name = argv[0];
	llvm::sys::PrintStackTraceOnErrorSignal(name);
	StringList arches;
	unsigned i;

	ArchSpec::ListSupportedArchNames(arches);
	for (i = 0; i < arches.GetSize(); ++i) {
		const char *s = arches.GetStringAtIndex(i);
		if (s == NULL) return (1);
	}
	return !debugger.IsValid();
}
EOF

sub TEST_lldb
{
	my ($ver, $pfx) = @_;
	my $llvmConfigs = 'llvm-config llvm-config15 llvm-config10 llvm-config80 ' .
	                  'llvm-config70 llvm-config60';

	MkFor('llvmconfig', $llvmConfigs);
		MkExecOutputPfx($pfx, '${llvmconfig}', '--prefix', 'LLDB_PREFIX');
		MkIfEQ('${MK_EXEC_FOUND}', 'Yes');
			MkExecOutputPfx($pfx, '${llvmconfig}', '--version', 'LLDB_VERSION');
			MkExecOutputPfx($pfx, '${llvmconfig}', '--cflags',  'LLDB_CFLAGS');
			MkExecOutputPfx($pfx, '${llvmconfig}', '--ldflags', 'LLDB_LDFLAGS');
			MkExecOutputPfx($pfx, '${llvmconfig}', '--libs',    'LLDB_LIBS');
			MkBreak;
		MkEndif;
	MkDone;

	MkCaseIn('${host}');
	MkCaseBegin('*-*-darwin*');
		MkIfEQ('LLDB_BUILD_DIR', '');
			MkDefine('LLDB_BUILD_DIR',
			         '/Applications/Xcode.app/Contents' .
				 '/SharedFrameworks');
		MkEndif;
		MkDefine('LLDB_LIBS', '${LLDB_LDFLAGS} -llldb ${LLDB_LIBS} ' .
		                      '-framework LLDB ' .
 		                      '-Wl,-rpath,"${LLDB_BUILD_DIR}" -lstdc++');
		MkCaseEnd;
	MkCaseBegin('*');
		MkDefine('LLDB_LIBS', '${LLDB_LDFLAGS} -llldb ${LLDB_LIBS} -lstdc++');
		MkCaseEnd;
	MkEsac;

	MkIfFound($pfx, $ver, 'LLDB_VERSION');
		MkPrintSN('checking whether LLDB works...');
		MkCompileCXX('HAVE_LLDB',
		             '${LLDB_CFLAGS}',
		             '${LLDB_LDFLAGS} ${LLDB_LIBS}', $testCode);
		MkIfTrue('${HAVE_LLDB}');
			MkDefine('LLDB_LIBS', '${LLDB_LDFLAGS} ${LLDB_LIBS}');
			MkSaveDefine('HAVE_LLDB');

			MkPrintSN('checking for LLDB Utility library...');
			MkCaseIn('${host}');
			MkCaseBegin('*-*-darwin*');
				MkPrintS('no');
				MkSaveUndef('HAVE_LLDB_UTILITY');
				MkDefine('HAVE_LLDB_UTILITY', 'no');
				MkDefine('LLDB_UTILITY_CFLAGS', '');
				MkDefine('LLDB_UTILITY_LIBS', '');
				MkCaseEnd;
			MkCaseBegin('*');
				MkDefine('LLDB_UTILITY_CFLAGS', '');
				MkCompileCXX('HAVE_LLDB_UTILITY',
				             '${LLDB_CFLAGS} ${LLDB_UTILITY_CFLAGS}',
				             '${LLDB_LDFLAGS} ${LLDB_LIBS} -llldbUtility',
				             $testCodeUtility);
				MkIfTrue('${HAVE_LLDB_UTILITY}');
					MkDefine('LLDB_UTILITY_LIBS', '-llldbUtility');
					MkSaveDefine('HAVE_LLDB_UTILITY');
				MkElse;
					MkSaveUndef('HAVE_LLDB_UTILITY');
				MkEndif;
				MkCaseEnd;
			MkEsac;
		MkElse;
			MkDisableFailed('lldb');
		MkEndif;
	MkElse;
		MkDisableNotFound('lldb');
	MkEndif;
}

sub DISABLE_lldb
{
	MkDefine('HAVE_LLDB', 'no') unless $TestFailed;
	MkDefine('HAVE_LLDB_UTILITY', 'no');
	MkDefine('LLDB_CFLAGS', '');
	MkDefine('LLDB_LIBS', '');
	MkDefine('LLDB_UTILITY_CFLAGS', '');
	MkDefine('LLDB_UTILITY_LIBS', '');
	MkSaveUndef('HAVE_LLDB', 'HAVE_LLDB_UTILITY');
}

BEGIN
{
	my $n = 'lldb';

	$DESCR{$n}   = 'the LLDB debugger';
	$URL{$n}     = 'https://lldb.llvm.org/';
	$TESTS{$n}   = \&TEST_lldb;
	$DISABLE{$n} = \&DISABLE_lldb;
	$DEPS{$n}    = 'cxx';
	$SAVED{$n}   = 'LLDB_CFLAGS LLDB_LIBS LLDB_UTILITY_CFLAGS LLDB_UTILITY_LIBS';
}
;1
