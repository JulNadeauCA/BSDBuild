#!/usr/bin/env perl -I..
#
# Generate the mother of all BSDBuild configure scripts,
# in order to test all test modules.
#

use BSDBuild::Core;
use BSDBuild::Builtins;

$MODULEDIR = '../BSDBuild';

print << 'EOF';
# Auto-generated BSDBuild configure.in to exercise all test modules.
# vim:syn=bsdbuild

package("bsdbuild-test")
release("Dummy test")
config_guess("../mk/config.guess")
config_cache(no)

register_section("Test options:")
register("--with-foo=SOMETHING", "Some description [auto]")
register("--enable-warnings", "Enable compiler warnings [no]")

default_dir(DATADIR, "$PREFIX/share/bsdbuild")

register_env_var(FOOVARIABLE, "Foo variable description")

mdefine(MYMAKEDEFINE, "my make define")
hdefine(MYMAKEDEFINE, "my header define")

c_define(_MY_C_DEFINE)
c_no_secure_warnings()

if [ "${enable_warnings}" = 'yes' ]; then
	c_option(-Wall)
	c_option(-Werror)
fi

echo "Building for host: ${host}"

# All built-in BSDBuild test modules
EOF

my %satisfied_deps = ();
opendir(DIR, $MODULEDIR) || die "$MODULEDIR: $!";
foreach my $file (readdir(DIR)) {
	if (index($file,'.') == 0) { next; }
	my ($base, $ext) = split(/\./, $file);
	if ($base =~ /^(Builtins|Core|Makefile)$/ || $ext ne 'pm') {
		next;
	}
	do($MODULEDIR.'/'.$file);
	if ($DEPS{$base}) {
		foreach my $dep (split(',', $DEPS{$base})) {
			if (exists($satisfied_deps{$dep})) {
				next;
			}
			print "# $base depends on $dep:\n";
			print 'check('.$dep.")\n";
			$satisfied_deps{$dep} = 1;
		}
	}
	print 'check(' . $base . ")\n";
	print 'disable(' . $base . ")\n";
}
closedir(DIR);
