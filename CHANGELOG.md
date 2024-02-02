# Changelog

All notable changes to BSDBuild will be documented in this file. This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [3.2] - 2022-

### Added

- Add support for [cmake](https://cmake.org). Add `--output-cmake` option to [**mkconfigure**](https://bsdbuild.hypertriton.com/man1/mkconfigure) to output macros usable from cmake.
- [**build.prog.mk**](https://bsdbuild.hypertriton.com/man5/build.prog.mk) & [**build.lib.mk**](https://bsdbuild.hypertriton.com/man5/build.lib.mk): Add support for compiling to wasm (WebAssembly) with Emscripten (https://emscripten.org).
- [**build.prog.mk**](https://bsdbuild.hypertriton.com/man5/build.prog.mk) & [**build.lib.mk**](https://bsdbuild.hypertriton.com/man5/build.lib.mk): Add support for the Ada language. Introduce `$ADA`, `$ADABIND`, `$ADALINK` and `$LINKER_TYPE`. Introduce `${PROG_BUNDLE}`, `${LIB_BUNDLE}` and `gen-bundle.pl` for generating platform-specific application bundles (currently "OSX" or "iOS").
- [**build.www.mk**](https://bsdbuild.hypertriton.com/man5/build.www.mk): Introduce the mlproc(1) multilanguage preprocessor. Define `${MLPROC}`, `${MLPROCFLAGS}`, `${MINIFIER}`, `${MINIFIERFLAGS}` and `${MINIFIERFLAGSCSS}`.
- [**mkconfigure**](https://bsdbuild.hypertriton.com/man1/mkconfigure): New directives: `Ada_option()`, `Ada_bflag()`, `Hdefine_if()`. Export LDFLAGS to Makefile.config. Fix `Ld_Option()`. New directive `Pkgconfig_Module()` for integrated pkg-config module generation. Add `$PKGCONFIG_LIBDIR` setting to simplify the installation of .pc modules. Introduce `--keep-conftest` configure option (preserve output test files).
- **ada**: New test for Ada toolchain.
- **agar-ada**: New test module for Ada bindings to Agar-GUI.
- **agar-ada-core**: New test module for Ada bindings to Agar-Core.
- **agar.types**: New test modules to generate tables of definitions and struct sizes for an installed Agar build. Intended to simplify the implementation of thin and variable-thickness bindings to different languages.
- **cc**: Add support for [cc65](https://cc65.github.io). Add `$CC_COMPILE`. Don't assume the compiler understands "-c" or "-O2".
- **imagemagick**: New test for ImageMagick 6 and 7.
- **lldb**: New test for lldb interface library.
- **sdl2**: New test for SDL 2.0 series.
- **tcl**: New test for Tcl. Thanks Chuck!

### Removed

- [**build.man.mk**](https://bsdbuild.hypertriton.com/man5/build.man.mk): Removed support for catman (`.cat*`) file auto-generation.
- **freesg**: Module replaced by **agar-sg**.

### Changed

- [**build.lib.mk**](https://bsdbuild.hypertriton.com/man5/build.lib.mk): Disable use of Libtool by default. Generate .la files even when `USE_LIBTOOL=No`. Handle .dylib and .dll files directly.
- [**build.prog.mk**](https://bsdbuild.hypertriton.com/man5/build.prog.mk) & [**build.lib.mk**](https://bsdbuild.hypertriton.com/man5/build.lib.mk): Use ``{LIB,PROG}_PROFILE`` instead of separate .po targets. Merge the "depend" from [**build.dep.mk**](https://bsdbuild.hypertriton.com/man5/build.dep.mk). Include support for cc65 compiler.
- [**mkconfigure**](https://bsdbuild.hypertriton.com/man1/mkconfigure): Make the generated config.log a runnable shell script containing all test code and compilation commands (so individual tests can be reproduced easily by copy/pasting from it). Fix quoting of arguments in config.status.
- [**mkconfigure**](https://bsdbuild.hypertriton.com/man1/mkconfigure): Show influential environment variables in generated "--help" output. Introduce `Register_env_var()` directive. Use `$IFS` instead of sed for path traversals. Add test for `$PATH_SEPARATOR`. Use expr to validate `--with-*` and `--enable-*` arguments. Honor `${EXECSUFFIX}` in `$PATH` searches. Don't invoke config.guess unnecessarily if --build is provided.
- **mkconcurrent** script: Extract and cache make target fragments directly from an installed build.\*.mk so we no longer need to maintain a copy of them in the script.
- **cc**: Define `HAVE_CC_GCC` and `HAVE_CC_CLANG`.
- **x11**: Honor `--x-includes=*` and `--x-libraries=*` configure arguments. If XKB is not found then fallback to libXf86misc.
- **pthreads**: Add subtests `HAVE_PTHREAD_{MUTEX,COND,}_T_POINTER` to determine whether `pthread_mutex_t`, `pthread_cond_t` and `pthread_t` are pointer types or not. Needed for `_Pure_Attribute_If_Unthreaded` in agar.
- Update config.guess to 2015-03-04. Add [FabBSD](https://FabBSD.org).
- Don't imply "all" in the "install" target.
- In "install" target, create `${DESTDIR}` if needed.
- Updates to the manual pages.

### Fixed

- [**mkconfigure**](https://bsdbuild.hypertriton.com/man1/mkconfigure): Handle string literals containing "," and ";" in directives. Thanks Chuck!
- [**mkconfigure**](https://bsdbuild.hypertriton.com/man1/mkconfigure): When testing for the presence of executables, make sure they are not directories. Thanks Kristof!
- **freetype**: Check with pkgconfig also. Thanks enthus1ast!
- Don't include non-file args in "nothing to do" evaluation in bundled mkdep script.

## [3.1] - 2015-07-14

### Added

- [**build.man.mk**](https://bsdbuild.hypertriton.com/man5/build.man.mk): Add support for the new [OpenBSD](https://openbsd.org) [mandoc](https://man.openbsd.org/mandoc). Add support for PDF and HTML format output. Introduce new target "lint".
- **csidl**: New test for Windows CSIDL interface.
- **kqueue**: New test for [**kqueue(2)**](https://www.freebsd.org/cgi/man.cgi?kqueue) kernel event notification mechanism.
- **nanosleep**: New test for nanosleep(2) interface.
- **rand48**: New test for rand48() PRNG routines.
- **timerfd**: New test for timerfd on Linux.
- **uim**: New test for uim input method framework.
- **x11**: Add /usr/local/include, /usr/include to fallback test.
- **x11**: Added test for XKB extension (`HAVE_XKB`).
- **xbox**: New test for xbox XDK.

### Removed

- [**mkconfigure**](https://bsdbuild.hypertriton.com/man1/mkconfigure): No longer include the `--cache` support code by default in order to make generated scripts smaller since caching is mostly advantageous on slower systems. Use `CONFIG_CACHE(yes)` to re-enable. Generate **config.status** files.
- **cxx**, **objc**: Remove unnecessary tests for Cygwin, long long and long double.
- **sse**: Remove unnecessary test code.

### Changed

- [**build.prog.mk**](https://bsdbuild.hypertriton.com/man5/build.prog.mk): Allow `${PROG_TYPE}`-dependent LDFLAGS to be defined.
- [**build.lib.mk**](https://bsdbuild.hypertriton.com/man5/build.lib.mk): Updated bundled libtool to 2.4.2. Use the `LIB_{CURRENT,REVISION,AGE}` versioning scheme.
- [**build.www.mk**](https://bsdbuild.hypertriton.com/man5/build.www.mk): Multi-lingual document targets are now specified as `${HTML}` elements with the .html.var extension (as opposed to .html). Write charset variants into `${CHARSETS}` directory.
- **cc**, **cxx**, **objc**: When cross-compiling, autodetect `${host}-cc` et al.
- **opengl**: On MacOS X, prefer "-framework OpenGL" to -lGL where available.
- **sdl**: On MacOS X, fallback to trying `-framework SDL` if **sdl-config** fails.
- **sdl**: On Windows, prefer linking to SDL.dll wherever possible.

### Fixed

- Honor `${DESTDIR}`. Thanks bonsaikitten!
- Handle some new compiler warnings correctly.
- **pthreads**: Dragonfly doesn't require extra `PTHREAD_XOPEN_CFLAGS`. Thanks varialus!
- **getpwuid**: Don't reference non-portable fields in test.
- **portaudio**: Fixed test for portaudio2.
- **math_c99**: Disable under `*-pc-mingw32`, to work around a bug in libmingwex causing linker errors if single-precision variants of the math routines (e.g., fabsf()) are used.
- **jpeg**: Remove `_WIN32` exception (there are workarounds the `<windows.h>` issue).
- **perl**: Fix compiler warnings in test (due to myPerl -> my\_perl).

## [3.0] - 2012-08-10

### Added

- [**mkconfigure**](https://bsdbuild.hypertriton.com/man1/mkconfigure): New directives `MAPPEND()`, `CHECK_PERL_MODULE()`, `DEFAULT_DIR()`. Introduced new configure options `--moduledir`, `--statedir` and `--libexecdir` (and others for autoconf compatibility).
- **cc_attributes**: New test for C compiler attributes (formerly in cc).
- **cocoa**: New test for Cocoa framework in OSX.
- **crypt**: New test for `crypt()` function.
- **getpwnam_r**: New test for `getpwnam_r()` function.
- **gethostname**: New test for `gethostname()` function.
- **gcc**: New test for GCC.
- **fontconfig**: New test for the [fontconfig](https://www.fontconfig.org) library.
- **mysql**: New test for MySQL client library.
- **objc**: New test for Objective C compiler.
- **portaudio**: New test for Portaudio library.
- **siocgifconf**: New test for `SIOCGIFCONF` ioctl.
- **sockopts**: New test for platform-specific socket options.
- **winsock**: New test for Winsock under Windows.

### Changed

- It is now possible to control conditional compilation from configure (i.e., a Makefile's `${SRCS}` definition may safely reference configure-defined variables). In separate builds, the mkconcurrent script is now invoked at the very end of configure, and it now performs more extensive parsing of Makefiles as well.
- Prevent redundant Makefile.config definitions from being produced.
- [**mkconfigure**](https://bsdbuild.hypertriton.com/man1/mkconfigure): Allow use of terminating backslash to escape long line breaks in input scripts.
- Simplifed handling of `Emul()` in test modules. Remove redundant code.
- Renamed `${SHAREDIR}` -> `${DATADIR}` and `${SHARE}` -> `${DATAFILES}`.

### Fixed

- Avoid using system **libtool** if it's not GNU libtool.
- The **mkdep** script now passes any "-m" cflags to the compiler.
- [**build.prog.mk**](https://bsdbuild.hypertriton.com/man5/build.prog.mk) & [**build.lib.mk**](https://bsdbuild.hypertriton.com/man5/build.lib.mk): Honor `${OBJC}`.
- Fix `${DESTDIR}` handling in modules.

## [2.9] - 2011-06-20

### Added

- [**mkconfigure**](https://bsdbuild.hypertriton.com/man1/mkconfigure): Introduce `TEST_DIR()` directive for specifying location to third-party test module directory.
- [**build.www.mk**](https://bsdbuild.hypertriton.com/man5/build.www.mk): Introduce `${LIB_MODULE}` setting (set "Yes" to build a dlopen()able module).
- **agar_au**: New test for Agar-AU.
- **clock_win32**: New test for Windows clock API.
- **xinerama**: New test for Xinerama.
- **sdl_ttf**: New test for [SDL\_ttf](https://www.libsdl.org/projects/SDL_ttf) (thanks markand!)

### Changed

- Default to using the system libtool where available.
- In various tests, try pkg-config first before scanning for paths.

### Fixed

- Fix default "make -j" behavior. Honor `${DESTDIR}`. Thanks reinoud!
- Tweaked test code to work around GCC 4.6 "-Wall" warnings.
- Various fixes for tests under [NetBSD](https://netbsd.org). Thanks reinoud!

## [2.8] - 2011-01-24

### Added

- [**mkconfigure**](https://bsdbuild.hypertriton.com/man1/mkconfigure): Added directives `CONFIG_SCRIPT()`, `PACKAGE()`, `VERSION()`, `RELEASE()` and `REGISTER_SECTION()`. Improved `configure --help` output. Items are now sorted. Added `--verbose` and `--without-catman` option.
- [**mkconfigure**](https://bsdbuild.hypertriton.com/man1/mkconfigure): Added directives `CHECK_HEADER()`, `CHECK_HEADER_OPTS()`, `CHECK_FUNC()` and `CHECK_FUNC_OPTS()` and `HDEFINE_UNQUOTED()` variant. Thanks rhaamo!

### Changed

- [**mkconfigure**](https://bsdbuild.hypertriton.com/man1/mkconfigure): Added optional version argument to `REQUIRE()` directive, to indicate a minimum required version.
- Improved Cygnus/GNU compatibility for generated configure scripts.

### Fixed

- [**build.lib.mk**](https://bsdbuild.hypertriton.com/man5/build.lib.mk): Fix dependency of `${SHOBJS}` against `${LIBTOOL_COOKIE}`. Thanks Bill Randle!
- *cxx*: Run C++ compiler tests against libstdc++.

## [2.7] - 2010-04-07

### Added

- Added wikitext output to manreader.cgi script. Introduced [man2wiki](https://bsdbuild.hypertriton.com/man1/man2wiki) utility.
- Added [uman](https://bsdbuild.hypertriton.com/man1/uman) uninstalled manual page viewer utility.
- [**mkconfigure**](https://bsdbuild.hypertriton.com/man1/mkconfigure): Added `C_INCDIR_CONFIG()`. Internal code cleanup.
- **alsa**: New test for ALSA audio interface.
- **wgl**: New test for the WGL interface in Windows.
- **glx**: New test for the GLX interface with X11.
- **png**: New test for [libpng](http://www.libpng.org/pub/png/libpng.html)

### Removed

- **freesg_m**: Library no longer exists.
- Removed less commonly used profiles from default `${PROJFILES}` "bsd:cb-gcc", "windows:vs6", "windows:vs2002" and "windows:vs2003".

### Changed

- **agar**: Updated test for Agar 1.4.

### Fixed

- Fixed incorrect version checking in `REQUIRE()`.

## [2.5] - 2009-06-03

### Added

- Implement handling of `${DESTDIR}`. It is prepended to installation targets at "make install".
- Implemented scanning of Makefiles for those requiring .depend files (from ./configure). This eliminates the need for keeping annoying empty .depend files on source code repositories.
- [**build.lib.mk**](https://bsdbuild.hypertriton.com/man5/build.lib.mk): Introduce `${CONF}` and `${CONFDIR}`.
- **cc**: New tests for compiler attributes: `aligned`, `const`, `deprecated`, `noreturn`, `pure` and `warn_unused_result`.
- **cracklib**: Update test for latest version of library.
- **glob**: New test for `glob()` function.
- **syslog**: New test for `syslog()` interface.
- **db**: New test for Berkeley DB.
- **gettimeofday**: New test for `gettimeofday()` call.
- Added [FabBSD](https://FabBSD.org/) to target platforms.

## Removed

- [**build.proj.mk**](https://bsdbuild.hypertriton.com/man5/build.proj.mk): Removed `${PROJINCLUDES}`.

## Changed

- [**build.proj.mk**](https://bsdbuild.hypertriton.com/man5/build.proj.mk): Simplified project file generation. Rewrite of mkprojfiles to implement proper parsing of Makefile variables.
- **percgi**: Update test for version of PerCGI.

## [2.4] - 2008-11-14

### Added

- [**mkconfigure**](https://bsdbuild.hypertriton.com/man1/mkconfigure): Added `C_INCPREP()` directive to preprocess C header files and insert visibility keywords in `__BEGIN_DECLS` sections). Added `LD_OPTION()` directive.
- [**mkconfigure**](https://bsdbuild.hypertriton.com/man1/mkconfigure): Introduced configure options `--includes`, `--cache`, `--with-ctags`.
- [**build.www.mk**](https://bsdbuild.hypertriton.com/man5/build.www.mk): Added `${HTML_INSTSOURCE}. Added manual page.
- **curl**: New test for curl library.
- **edacious**: New test for [Edacious](https://edacious.org/).
- **dlopen**: New test for `dlopen()` call.
- **dyld**: New test for dyld interface.
- **shl_load**: New test for `shl_load()` interface.
- **float_h**: New test for `float.h`.
- **percgi**: New test for PerCGI library.
- **agar-math**: New tests for ag_math extension library.
- Added h2mandoc utility (create mandoc templates from C header files).

### Changed

- [**build.proj.mk**](https://bsdbuild.hypertriton.com/man5/build.proj.mk): Improvements in project file generation. Avoid redundant files in project file packages. Determine the default Premake "package language" from the contents of `$SRCS`. Better handling of dependencies when generating project files for Code::Blocks (use the recommended global variables).
- When scanning for executables (such as **foo-config** scripts), warn user if the program appears multiple times in $PATH.
- **cc**: Fix unwanted behavior when multiple cc and c++ appear in $PATH.
- **iconv**: Test for const-correct version of API (sets `HAVE_ICONV_CONST`).
- Rewrite of the [mkify](https://bsdbuild.hypertriton.com/man1/mkify) utility.

## Fixed

- [**build.prog.mk**](https://bsdbuild.hypertriton.com/man5/build.prog.mk) & [**build.lib.mk**](https://bsdbuild.hypertriton.com/man5/build.lib.mk): Fix dependencies with non-current build under GNU make. Thanks Antoine Levitt!
- **pthreads**: Search for pthreadsGC\* from pthreads-win32. Thanks Ryan Lindeman!
- Fixed portability problems against some versions of **sh**.

