#!/usr/bin/perl
#
# Copyright (c) 2003-2012 Hypertriton, Inc. <http://hypertriton.com/>
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
#

use Cwd;
#use Errno qw(EEXIST);

$COOKIE = ".mkconcurrent_$$";
@DIRS = ();
$BUILD = '';
@MKFILES = (
	'Makefile.proj',
	'Makefile.prog',
	'\.mk$',
	'\.inc$',
	'^mkdep$',
	'^install-includes.sh$',
	'^config\.(guess|sub)$',
	'^configure$',
	'^configure\.in$',
	'^ltconfig$',
	'^ltmain\.sh$',
	'^manlinks\.pl$',
	'^hstrip\.pl$',
	'^cmpfiles\.pl$',
	'^cleanfiles\.pl$',
	'^gen-includes\.pl$',
	'^gen-includelinks\.pl$',
	'^gen-declspecs\.pl$',
	'^install-manpages\.sh$',
);
my %V = ();

sub Debug
{
	print STDERR @_, "\n";
}

# Return a Makefile's contents, with lines expanded and variables substituted.
sub ProcessedMakefile ($$)
{
	my $path = shift;
	my $dir = shift;

	if (!open(MF, $path)) {
		return ();
	}
	my @lines = ();
	foreach $_ (<MF>) {
		chop;

		if (/^(.+)\\$/) {			# Expansion
			$line .= $1;
		} else {				# New line
			if ($line) {
				push @lines, $line . $_;
				$line = '';
			} else {
				push @lines, $_;
			}
		}
	}
	foreach $_ (@lines) {
		if (/^\s*#/) { next; }
		if (/^\t/) { next; }
		s/\$\{(\w+)\}/$V{$1}/g;
		if (/^\s*(\w+)\s*=\s*"(.+)"$/ ||
		    /^\s*(\w+)\s*=\s*(.+)$/) {
			$V{$1} = $2;
		} elsif (/^\s*(\w+)\s*\+=\s*"(.+)"$/ ||
		         /^\s*(\w+)\s*\+=\s*(.+)$/) {
			if (exists($V{$1}) && $V{$1} ne '') {
				$V{$1} .= ' '.$2;
			} else {
				$V{$1} = $2;
			}
		}
		if (/^\s*include\s+(.+)$/) {
			my $incl = $1;
			if ($incl =~ /Makefile\.config$/) {
				# Special case: configure-generated file
				ProcessedMakefile($BUILD.'/'.$dir.'/'.$incl, $BUILD);
			} else {
				ProcessedMakefile($dir.'/'.$incl, $dir);
			}
		}
	}
	close(MF);

#	if (open(FOUT, ">>processed.txt")) {
#		print FOUT "======================= $path (in $dir) ====================================\n";
#		print FOUT join("\n", @lines), "\n";
#		close(FOUT);
#	}
	return (@lines);
}

sub ConvertMakefile
{
	my ($dir, $ndir, $ent) = @_;
	my @lines;

	open(DSTMAKEFILE, ">$BUILD/$ndir/$ent") ||
	    die "dest: $BUILD/$ndir/$ent: $!";

	%V = ();
	@lines = ProcessedMakefile($dir.'/'.$ent, $dir);
	unless (@lines) {
		return;
	}

	print DSTMAKEFILE << "EOF";
#
# This file was automatically generated by mkconcurrent.pl (BSDbuild)
# for concurrent building.
#
SRC=$SRC
BUILD=$BUILD
BUILDREL=$dir

EOF

	my @deps = ();
	my @objs = ();
	my @shobjs = ();
	my %catman;
	my %psman;
	my $libtool = 1;
	my $shared = 0;
	my $static = 1;
	my $module = 1;
	my $isProg = 0;
	my $isLib = 0;

	foreach $_ (@lines) {
		my @srcs = ();

		if (/^\s*PROG\s*=/) { $isProg = 1; }
		if (/^\s*LIB\s*=/) { $isLib = 1; }
		if (/^\s*USE_LIBTOOL\s*=\s*No\s*$/) { $libtool = 0; }
		if (/^\s*LIB_SHARED\s*=\s*Yes\s*$/) { $shared = 1; }
		if (/^\s*LIB_STATIC\s*=\s*No\s*$/) { $static = 0; }
		if (/^\s*LIB_MODULE\s*=\s*Yes\s*$/) { $module = 1; }
		if (/^\s*(SRCS|MAN\d|MOS)\s*=\s*(.+)$/) {
			my $type = $1;

			foreach my $src (split(/\s/, $2)) {
				unless ($src) {
					next;
				}
				my $obj = $src;
				my $shobj = $src;

				if ($type eq 'SRCS') {
					if ($isLib && $libtool) {
						$shobj =~
						    s/\.(c|cc|l|y|m)$/\.lo/;
						push @shobjs, $shobj;
					} else {
						$obj =~ s/\.(c|cc|l|y|m)$/\.o/;
						push @objs, $obj;
					}
				} elsif ($type =~ /MAN(\d)/) {
					$obj =~ s/\.(\d)$//;
					$catman{$1} .= " $obj.cat$1";
					$psman{$1} .= " $obj.ps$1";
				} elsif ($type =~ /MOS/) {
					$src =~ s/\.mo$/\.po/g;
				}

				# SYNC with build.{prog,lib}.mk
				if ($src =~ /\.[cly]$/) { # C/Lex/Yacc
					if ($isLib && $libtool) {
						push @deps,
						    "$shobj: $SRC/$ndir/$src";
						push @deps, << 'EOF';
	${LIBTOOL} --mode=compile ${CC} ${LIBTOOLFLAGS} ${CFLAGS} ${CPPFLAGS} -c $<

EOF
					} else {
						push @deps,
						    "$obj: $SRC/$ndir/$src";
						push @deps, << 'EOF',
	${CC} ${CFLAGS} ${CPPFLAGS} -c $<

EOF
					}
				} elsif ($src =~ /\.cc$/) { # C++
					if ($isLib && $libtool) {
						push @deps,
						    "$shobj: $SRC/$ndir/$src";
						push @deps, << 'EOF';
	${LIBTOOL} --mode=compile ${CC} ${LIBTOOLFLAGS} ${CXXFLAGS} ${CPPFLAGS} -c $<

EOF
					} else {
						push @deps,
						    "$obj: $SRC/$ndir/$src";
						push @deps, << 'EOF',
	${CC} ${CXXFLAGS} ${CPPFLAGS} -c $<

EOF
					}
				} elsif ($src =~ /\.m$/) { # C+Objective-C
					if ($isLib && $libtool) {
						push @deps,
						    "$shobj: $SRC/$ndir/$src";
						push @deps, << 'EOF';
	${LIBTOOL} --mode=compile ${OBJC} ${LIBTOOLFLAGS} ${CFLAGS} ${OBJCFLAGS} ${CPPFLAGS} -c $<

EOF
					} else {
						push @deps,
						    "$obj: $SRC/$ndir/$src";
						push @deps, << 'EOF',
	${CC} ${CFLAGS} ${OBJCFLAGS} ${CPPFLAGS} -c $<

EOF
					}
				} elsif ($type =~ /MAN(\d)/) {
					# Nroff -> ASCII
					# -> Sync with build.man.mk.
					push @deps,
					    "$obj.cat$1: $SRC/$ndir/$src";
					push @deps, << 'EOF';
	@echo "${NROFF} -Tascii -mandoc $< > $@"
	@(cat $< | \
	  sed 's,\$$SYSCONFDIR,${SYSCONFDIR},' | \
	  sed 's,\$$PREFIX,${PREFIX},' | \
	  sed 's,\$$SHAREDIR,${SHAREDIR},' | \
	  ${NROFF} -Tascii -mandoc > $@) || (rm -f $@; true)

EOF
					# Nroff -> PostScript
					# -> Sync with build.man.mk.
					push @deps,
					    "$obj.ps$1: $SRC/$ndir/$src";
					push @deps, << 'EOF';
	@echo "${NROFF} -Tps -mandoc $< > $@"
	@(cat $< | \
	  sed 's,\$$SYSCONFDIR,${SYSCONFDIR},' | \
	  sed 's,\$$PREFIX,${PREFIX},' | \
	  sed 's,\$$SHAREDIR,${SHAREDIR},' | \
	  ${NROFF} -Tps -mandoc > $@) || (rm -f $@; true)

EOF
				} elsif ($type =~ /MOS/) {
					# Portable object -> machine object
					# -> Sync with build.po.mk.
					push @deps, "$obj: $SRC/$ndir/$src";
					push @deps, << 'EOF';
	@if [ "${ENABLE_NLS}" = "yes" -a "${HAVE_GETTEXT}" = "yes" ]; then \
		echo "${MSGFMT} -o $@ $<"; \
		${MSGFMT} -o $@ $<; \
	else \
		echo "skipping $@ (no gettext)"; \
	fi

EOF
				}
			}
		}
		if (/^\s*(SRCS|MAN\d|XCF|TTF|POS)\s*=\s*(.+)$/) {
			my $type = $1;
			my $srclist = $2;

			foreach my $src (split(/\s/, $srclist)) {
				unless ($src) {
					next;
				}
				push @srcs, $src;
			}
			my $i = 0;
			foreach my $src (@srcs) {
				$srcs[$i] = "$SRC/$ndir/$srcs[$i]";
				$i++;
			}
			print DSTMAKEFILE $type . '=' . join(' ', @srcs), "\n";
		} else {
			if (/^\s*include.+\/build\.(lib|prog|po)\.mk\s*$/) {
				print DSTMAKEFILE "# Generated objects:\n";
				if ($isLib && $libtool) {
					print DSTMAKEFILE "SHOBJS=@shobjs\n";
				} else {
					print DSTMAKEFILE "OBJS=@objs\n";
				}
				print DSTMAKEFILE "CATMAN1=$catman{1}\n";
				print DSTMAKEFILE "CATMAN2=$catman{2}\n";
				print DSTMAKEFILE "CATMAN3=$catman{3}\n";
				print DSTMAKEFILE "CATMAN4=$catman{4}\n";
				print DSTMAKEFILE "CATMAN5=$catman{5}\n";
				print DSTMAKEFILE "CATMAN6=$catman{6}\n";
				print DSTMAKEFILE "CATMAN7=$catman{7}\n";
				print DSTMAKEFILE "CATMAN8=$catman{8}\n";
				print DSTMAKEFILE "CATMAN9=$catman{9}\n";
				print DSTMAKEFILE "PSMAN1=$psman{1}\n";
				print DSTMAKEFILE "PSMAN2=$psman{2}\n";
				print DSTMAKEFILE "PSMAN3=$psman{3}\n";
				print DSTMAKEFILE "PSMAN4=$psman{4}\n";
				print DSTMAKEFILE "PSMAN5=$psman{5}\n";
				print DSTMAKEFILE "PSMAN6=$psman{6}\n";
				print DSTMAKEFILE "PSMAN7=$psman{7}\n";
				print DSTMAKEFILE "PSMAN8=$psman{8}\n";
				print DSTMAKEFILE "PSMAN9=$psman{9}\n";
				print DSTMAKEFILE "\n";
			}
			print DSTMAKEFILE $_, "\n";
		}

	}
	
	if (@deps) {
		print DSTMAKEFILE 'CFLAGS+=-I${BUILD}', "\n";
		print DSTMAKEFILE "\n", join("\n", @deps), "\n";
		print DSTMAKEFILE 'include .depend'."\n";
	}

	close(DSTMAKEFILE);

	# Prevent make from complaining.
	open(DSTDEPEND, ">$BUILD/$ndir/.depend") or
	    die "$BUILD/$ndir/.depend: $!";
	print DSTDEPEND "\n";
	close(DSTDEPEND);
}

sub Scan
{
	my $dir = shift;

	opendir(DIR, $dir) || die "$dir: $!";
	ENTRY: foreach my $ent (readdir(DIR)) {
		if ($ent eq '.' || $ent eq '..' ||
		    $ent eq 'CVS' || $ent eq '.svn') {
			next ENTRY;
		}
		my $dent = join('/',$dir,$ent);
		my $ndir = $dir;
		$ndir =~ s/^\.\///;
		my $ndent = join('/', $BUILD,$ndir,$ent);

		if ((! -l $dent) && (-d $dent && ! -e "$dent/$COOKIE")) {
			mkdir($ndent, 0755);
			Scan($dent);
		} else {
			if ($ent eq 'Makefile') {
				ConvertMakefile($dir, $ndir, $ent);
			} else {
				foreach my $pat (@MKFILES) {
					if ($ent =~ $pat) {
						open(OLDMK, $dent) ||
						    die "$dent: $!";
						open(NEWMK, ">$ndent") ||
						    die "$ndent: $!";
						print NEWMK <OLDMK>;
						close(NEWMK);
						close(OLDMK);
						last;
					}
				}
			}
		}
	}
	closedir(DIR);
}

$SRC = $ARGV[0];

unless ($SRC) {
	print STDERR "Usage: $0 [source-directory-path]\n";
	exit (0);
}

unless (-d $SRC) {
	print STDERR "$SRC: $!\n";
	exit(1);
}
if (-e 'INSTALL') {
	print STDERR "Cannot perform concurrent build in source directory\n";
	exit(1);
}

$BUILD = getcwd();
chdir($SRC) || die "$SRC: $!";

open(COOKIE, ">$BUILD/$COOKIE") || die "$BUILD/COOKIE: $!";
Scan('.');
close(COOKIE);

END
{
	unlink("$BUILD/$COOKIE");
}

