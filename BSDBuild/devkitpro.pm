# Public domain

my @devkitproArches = ('A64', 'ARM', 'PPC');

my $testCodeOGC = << 'EOF';
#include <stdio.h>
#include <stdlib.h>
#include <gccore.h>
#include <ogcsys.h>

int main(int argc, char *argv[]) {
	GXRModeObj *rmode;
	VIDEO_Init();
	PAD_Init();
	rmode = VIDEO_GetPreferredMode(NULL);
	VIDEO_Flush();
	return (rmode != NULL);
}
EOF

my $testCodeGBA = << 'EOF';
#include <gba_console.h>
#include <gba_video.h>
#include <gba_interrupt.h>
#include <gba_systemcalls.h>
#include <stdio.h>

int main(int argc, char *argv[]) {
	irqInit();
	irqEnable(IRQ_VBLANK);
	iprintf("\x1b[2J");
	return (0);
}
EOF

my $testCodeSwitch = << 'EOF';
#include <string.h>
#include <stdio.h>
#include <switch.h>

int main(int argc, char *argv[]) {
	consoleInit(NULL);
	printf("\x1b[16;20H" "Hello World!");
	while (appletMainLoop()) {
		u64 kd;
		hidScanInput();
		kd = hidKeysDown(CONTROLLER_P1_AUTO);
		if (kd & KEY_PLUS) { break; }
		consoleUpdate(NULL);
	}
	consoleExit(NULL);
	return (0);
}
EOF


sub TEST_devkitpro
{
	my ($ver, $pfx) = @_;

	MkDefine('HAVE_DEVKITPRO', 'no');

	MkIfNE($pfx, '');
		foreach my $arch (@devkitproArches) {
			my $base = $pfx . '/devkit' . $arch;

			MkIfExists($base);
				MkDefine('HAVE_DEVKITPRO', 'yes');
				MkDefine('DEVKIT' . $arch, $base);
			MkEndif;
		}
	MkElse;
		foreach my $arch (@devkitproArches) {
			my $base = '${DEVKITPRO}/devkit' . $arch;

			MkIfExists($base);
				MkDefine('HAVE_DEVKITPRO', 'yes');
				MkDefine('DEVKIT' . $arch, $base);
			MkEndif;
		}
	MkEndif;

	MkIfTrue('${HAVE_DEVKITPRO}');
		MkPrint('yes');

		MkPrintN('checking whether gamecube works...');
		MkCompileC('HAVE_GAMECUBE',
		           '-DGEKKO -mrvl -mcpu=750 -meabi -mhard-float '.
			    '-ffunction-sections -fdata-sections -fmodulo-sched ' .
			   '-I${DEVKITPRO}/libogc/include',
		           '-L${DEVKITPRO}/libogc/lib/cube -logc -lm -lgcc',
			   $testCodeOGC);

		MkPrintN('checking whether gba works...');
		MkCompileC('HAVE_GBA', '-I${DEVKITPRO}/libgba/include',
		           '-L${DEVKITPRO}/libgba/lib -lgba', $testCodeGBA);

		MkPrintN('checking whether switch works...');
		MkCompileC('HAVE_SWITCH',
		           '-D__SWITCH__ -march=armv8-a+crc+crypto ' .
			    '-mtune=cortex-a57 -mtp=soft -fPIE ' .
			    '-ffunction-sections '.
			    '-I${DEVKITPRO}/libnx/include',
		           '-L${DEVKITPRO}/libnx/lib -lnx ' .
			    '-specs=${DEVKITPRO}/libnx/switch.specs',
			   $testCodeSwitch);
	MkElse;
		MkDisableNotFound('devkitpro');
		MkPrint('no');
	MkEndif;
}

sub DISABLE_devkitpro
{
	MkDefine('HAVE_DEVKITPRO', 'no');
	MkDefine('HAVE_GAMECUBE', 'no');
	MkDefine('HAVE_GBA', 'no');
	MkDefine('HAVE_SWITCH', 'no');
	MkDefine('DEVKITPRO', '');
	foreach my $arch (@devkitProArches) {
		MkDefine('DEVKIT' . $arch, '');
	}
	MkSaveUndef('HAVE_GAMECUBE', 'HAVE_GBA', 'HAVE_SWITCH');
}

BEGIN
{
	my $n = 'devkitpro';

	$DESCR{$n}   = 'devkitPro';
	$URL{$n}     = 'https://devkitpro.org';
	$TESTS{$n}   = \&TEST_devkitpro;
	$DISABLE{$n} = \&DISABLE_devkitpro;
	$DEPS{$n}    = 'cc';
	$SAVED{$n}   = 'DEVKITPRO';
	foreach my $arch (@devkitproArches) { $SAVED{$n} .= ' DEVKIT' . $arch; }
}
;1
