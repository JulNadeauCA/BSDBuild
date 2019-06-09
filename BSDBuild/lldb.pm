# vim:ts=4
# Public domain

use BSDBuild::Core;

my $testCode = << 'EOF';
#include <stdlib.h>

#ifdef __APPLE__
# include <LLDB/LLDB.h>
#else
# include "lldb/API/SBBlock.h"
# include "lldb/API/SBCompileUnit.h"
# include "lldb/API/SBDebugger.h"
# include "lldb/API/SBFunction.h"
# include "lldb/API/SBModule.h"
# include "lldb/API/SBProcess.h"
# include "lldb/API/SBStream.h"
# include "lldb/API/SBSymbol.h"
# include "lldb/API/SBTarget.h"
# include "lldb/API/SBThread.h"
#endif

#include <string>

using namespace lldb;

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

	return !debugger.IsValid();
}
EOF

sub Output_LLVM_Config
{
	my $name = shift;

	MkExecOutputPfx($pfx, $name, '--version', 'LLDB_VERSION');
	MkExecOutputPfx($pfx, $name, '--cflags',  'LLDB_CFLAGS');
	MkExecOutputPfx($pfx, $name, '--ldflags', 'LLDB_LDFLAGS');
	MkExecOutputPfx($pfx, $name, '--libs',    'LLDB_LIBS');
}

sub TEST_lldb
{
	my ($ver, $pfx) = @_;

	MkExecOutputPfx($pfx, 'llvm-config', '--prefix', 'LLDB_PREFIX');
	Output_LLVM_Config('llvm-config');

	MkIfEQ('LLDB_PREFIX', '');
		MkExecOutputPfx($pfx, 'llvm80-config', '--prefix', 'LLDB_PREFIX');
		MkIfEQ('LLDB_PREFIX', '');
			MkExecOutputPfx($pfx, 'llvm70-config', '--prefix', 'LLDB_PREFIX');
			MkIfEQ('LLDB_PREFIX', '');
				MkExecOutputPfx($pfx, 'llvm60-config', '--prefix', 'LLDB_PREFIX');
				MkIfNE('LLDB_PREFIX', '');
					Output_LLVM_Config('llvm60-config');
				MkEndif;
			MkElse;
				Output_LLVM_Config('llvm70-config');
			MkEndif;
		MkElse;
			Output_LLVM_Config('llvm80-config');
		MkEndif;
	MkEndif;

	MkCaseIn('${host}');
	MkCaseBegin('*-*-darwin*');
		MkIfEQ('LLDB_BUILD_DIR', '');
			MkDefine('LLDB_BUILD_DIR',
                     '/Applications/Xcode.app/Contents/SharedFrameworks');
		MkEndif;
		MkDefine('LLDB_LIBS', '${LLDB_LDFLAGS} -llldb ${LLDB_LIBS} -framework LLDB '.
                              '-Wl,-rpath,"${LLDB_BUILD_DIR}" -lstdc++');
		MkCaseEnd;
	MkCaseBegin('*');
		MkDefine('LLDB_LIBS', '${LLDB_LDFLAGS} -llldb ${LLDB_LIBS} -lstdc++');
		MkCaseEnd;
	MkEsac;
		
	MkIfFound($pfx, $ver, 'LLDB_VERSION');
		MkPrintSN('checking whether LLDB works...');
		MkLog('LLDB_CFLAGS = ${LLDB_CFLAGS}');
		MkLog('LLDB_LIBS = ${LLDB_LIBS}');
		MkCompileCXX('HAVE_LLDB', '${LLDB_CFLAGS}',
                     '${LLDB_LDFLAGS} ${LLDB_LIBS}', $testCode);
		MkIfTrue('${HAVE_LLDB}');
			MkDefine('LLDB_LIBS', '${LLDB_LDFLAGS} ${LLDB_LIBS}');
			MkSave('LLDB_CFLAGS', 'LLDB_LIBS');
		MkEndif;
	MkElse;
		DISABLE_lldb();
	MkEndif;
}

sub DISABLE_lldb
{
	MkDefine('HAVE_LLDB', 'no');
	MkDefine('LLDB_CFLAGS', '');
	MkDefine('LLDB_LIBS', '');
	MkSaveUndef('HAVE_LLDB', 'LLDB_CFLAGS', 'LLDB_LIBS');
}

BEGIN
{
	my $n = 'lldb';

	$DESCR{$n}   = 'the LLDB debugger';
	$URL{$n}     = 'https://lldb.llvm.org/';
	$TESTS{$n}   = \&TEST_lldb;
	$DISABLE{$n} = \&DISABLE_lldb;
	$EMUL{$n}    = \&EMUL_lldb;
	$DEPS{$n}    = 'cxx';
}
;1
