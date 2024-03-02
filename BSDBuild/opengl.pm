# Public domain

my @autoIncludeDirs = (
	'/usr/include/X11',
	'/usr/include/X11R6',
	'/usr/include/X11R7',
	'/usr/local/X11/include',
	'/usr/local/X11R6/include',
	'/usr/local/X11R7/include',
	'/usr/local/include/X11',
	'/usr/local/include/X11R6',
	'/usr/local/include/X11R7',
	'/usr/X11/include',
	'/usr/X11R6/include',
	'/usr/X11R7/include',
	'/usr/local/include',
);

my @autoLibDirs = (
	'/usr/local/X11/lib',
	'/usr/local/X11R6/lib',
	'/usr/local/X11R7/lib',
	'/usr/X11/lib',
	'/usr/X11R6/lib',
	'/usr/X11R7/lib',
	'/usr/local/lib',
);
	
my $testCode = << 'EOF';
#ifdef _USE_OPENGL_FRAMEWORK
# include <OpenGL/gl.h>
#else
# include <GL/gl.h>
#endif
int main(int argc, char *argv[]) {
	glFlush();
	glLoadIdentity();
	return (0);
}
EOF

my $testCodeGLEXT = << 'EOF';
#define GL_GLEXT_PROTOTYPES
#ifdef _USE_OPENGL_FRAMEWORK
# include <OpenGL/gl.h>
# include <OpenGL/glext.h>
#else
# include <GL/gl.h>
# include <GL/glext.h>
#endif

static void
DebugMessageCallback(GLenum source, GLenum type, GLuint id, GLenum severity,
    GLsizei length, const GLchar *message, const void *userParam)
{ }

int main(int argc, char *argv[]) {
	glEnable(GL_DEBUG_OUTPUT);
	glDebugMessageCallback(DebugMessageCallback, 0);
	return (0);
}
EOF

my $testCodeGLX = << 'EOF';
#include <X11/Xlib.h>
#include <X11/Xutil.h>
#ifdef __APPLE__
# include <OpenGL/gl.h>
# include <OpenGL/glx.h>
#else
# include <GL/gl.h>
# include <GL/glx.h>
#endif
int main(int argc, char *argv[]) {
	Display *d;
	XVisualInfo *xvi;
	int glxAttrs[] = { GLX_RGBA, GLX_RED_SIZE,1, GLX_DEPTH_SIZE,1, None };
	GLXContext glxCtx;
	int err, ev, s;

	d = XOpenDisplay(NULL);
	(void)glXQueryExtension(d, &err, &ev);
	s = DefaultScreen(d);
	if ((xvi = glXChooseVisual(d, s, glxAttrs)) == NULL) { return (1); }
	if ((glxCtx = glXCreateContext(d, xvi, 0, GL_FALSE)) == NULL) { return (1); }
	return (0);
}
EOF

my $testCodeWGL = << 'EOF';
#include <windows.h>

int main(int argc, char *argv[]) {
	HWND hwnd;
	HDC hdc;
	HGLRC hglrc;

	hwnd = CreateWindowEx(0, "a", "a", WS_OVERLAPPEDWINDOW, CW_USEDEFAULT,
	    CW_USEDEFAULT, 0,0, NULL, NULL, GetModuleHandle(NULL), NULL);
	hdc = GetDC(hwnd);
	hglrc = wglCreateContext(hdc);
	SwapBuffers(hdc);
	wglDeleteContext(hglrc);
	ReleaseDC(hwnd, hdc);
	DestroyWindow(hwnd);
	return (0);
}
EOF

sub TEST_opengl
{
	my ($ver, $pfx) = @_;

	MkDefine('GL_CFLAGS', '');
	MkDefine('GL_LIBS', '');
	MkDefine('GL_FOUND', '');

	MkIfNE($pfx, '');
		MkIfExists("$pfx/include");
			MkDefine('GL_CFLAGS', "-I$pfx/include");
			MkDefine('GL_LIBS', "\${GL_LIBS} -L$pfx/lib");
			MkSetTrue('GL_FOUND');
		MkEndif;
	MkElse;
		MkCaseIn('${host}');
		MkCaseBegin('*-*-darwin*');
			MkPrintSN('framework...');
			MkDefine('OPENGL_CFLAGS', '-D_USE_OPENGL_FRAMEWORK');
			MkDefine('OPENGL_LIBS', '-framework OpenGL');
			MkSetTrue('GL_FOUND');
			MkCaseEnd;
		MkCaseBegin('*');
			foreach my $dir (@autoIncludeDirs) {
				MkIfExists("$dir/GL");
					MkDefine('GL_CFLAGS', "-I$dir");
					MkSetTrue('GL_FOUND');
				MkEndif;
			}
			foreach my $dir (@autoLibDirs) {
				MkIfExists($dir);
					MkDefine('GL_LIBS', "\${GL_LIBS} -L$dir");
					MkSetTrue('GL_FOUND');
				MkEndif;
			}
			MkCaseEnd;
		MkEsac;
	MkEndif;

	MkIfTrue('${GL_FOUND}');
		MkPrintS('yes');

		MkCaseIn('${host}');
		MkCaseBegin('*-*-darwin*');
			MkCaseEnd;
		MkCaseBegin('*-*-cygwin* | *-*-mingw32*');
			MkPrintSN('checking whether -lopengl32 works...');
			MkCompileC('HAVE_LIBOPENGL32',
			           '${OPENGL_CFLAGS}', '-lopengl32', $testCode);
			MkIfTrue('${HAVE_LIBOPENGL32}');
				MkDefine('OPENGL_LIBS', '${GL_LIBS} -lopengl32');
			MkElse;
				MkDefine('OPENGL_LIBS', '${GL_LIBS} -lGL');
			MkEndif;
			MkCaseEnd;
		MkCaseBegin('*');
			MkDefine('OPENGL_CFLAGS', '${GL_CFLAGS}');
			MkDefine('OPENGL_LIBS', '${GL_LIBS} -lGL');
			MkCaseEnd;
		MkEsac;

		MkPrintSN('checking whether OpenGL works...');
		MkCompileC('HAVE_OPENGL', '${OPENGL_CFLAGS}', '${OPENGL_LIBS}',
		           $testCode);
		MkIfFalse('${HAVE_OPENGL}');
			MkPrintSN('checking whether -lGL requires -lm...');
			MkDefine('OPENGL_LIBS', '${OPENGL_LIBS} -lm');
			MkCompileC('HAVE_OPENGL',
			           '${OPENGL_CFLAGS}', '${OPENGL_LIBS}',
			           $testCode);
			MkIfFalse('${HAVE_OPENGL}');
				MkDisableFailed('opengl');
			MkEndif;
		MkEndif;

		MkPrintSN('checking whether OpenGL has glext...');
		MkCompileC('HAVE_GLEXT',
		           '${OPENGL_CFLAGS}', '${OPENGL_LIBS}',
		           $testCodeGLEXT);
	MkElse;
		MkPrintS('no');
		MkDisableNotFound('opengl');
	MkEndif;

	MkIfTrue('${HAVE_OPENGL}');
		MkDefine('OPENGL_PC', 'gl');
	MkEndif;
}

sub CMAKE_opengl
{
	my $codeWGL = MkCodeCMAKE($testCodeWGL);
	my $codeGLEXT = MkCodeCMAKE($testCodeGLEXT);

        return << "EOF";
macro(Check_OpenGL)
	set(OPENGL_CFLAGS "")
	set(OPENGL_LIBS "")

	set(OpenGL_GL_PREFERENCE "LEGACY")
	include(FindOpenGL)
	if(OPENGL_FOUND)
		set(HAVE_OPENGL ON)

		if(OPENGL_INCLUDE_DIR)
			list(APPEND OPENGL_CFLAGS "-I\${OPENGL_INCLUDE_DIR}")
		endif()
		foreach(opengllib \${OPENGL_glu_LIBRARY} \${OPENGL_gl_LIBRARY})
			list(APPEND OPENGL_LIBS "\${opengllib}")
		endforeach()

		BB_Save_Define(HAVE_OPENGL)
	else()
		set(HAVE_OPENGL OFF)
		BB_Save_Undef(HAVE_OPENGL)
	endif()

	if(OpenGL_GLU_FOUND)
		set(HAVE_GLU ON)
		BB_Save_Define(HAVE_GLU)
	else()
		set(HAVE_GLU OFF)
		BB_Save_Undef(HAVE_GLU)
	endif()

	if(OpenGL_GLX_FOUND)
		set(HAVE_GLX ON)
		BB_Save_Define(HAVE_GLX)
	else()
		set(HAVE_GLX OFF)
		BB_Save_Undef(HAVE_GLX)
	endif()

	set(ORIG_CMAKE_REQUIRED_FLAGS \${CMAKE_REQUIRED_FLAGS})
	set(ORIG_CMAKE_REQUIRED_LIBRARIES \${CMAKE_REQUIRED_LIBRARIES})

	set(CMAKE_REQUIRED_FLAGS "\${CMAKE_REQUIRED_FLAGS} \${OPENGL_CFLAGS}")
	set(CMAKE_REQUIRED_LIBRARIES "\${CMAKE_REQUIRED_LIBRARIES} \${OPENGL_LIBS}")

	check_c_source_compiles("
$codeGLEXT" HAVE_GLEXT)
	if(HAVE_GLEXT)
		BB_Save_Define(HAVE_GLEXT)
	else()
		BB_Save_Undef(HAVE_GLEXT)
	endif()

	set(CMAKE_REQUIRED_LIBRARIES "\${ORIG_CMAKE_REQUIRED_LIBRARIES} \${OPENGL_LIBS} -lgdi32")

	check_c_source_compiles("
$codeWGL" HAVE_WGL)
	if(HAVE_WGL)
		BB_Save_Define(HAVE_WGL)
		set(OPENGL_LIBS "\${OPENGL_LIBS} -lgdi32")
	else()
		BB_Save_Undef(HAVE_WGL)
	endif()

	set(CMAKE_REQUIRED_FLAGS \${ORIG_CMAKE_REQUIRED_FLAGS})
	set(CMAKE_REQUIRED_LIBRARIES \${ORIG_CMAKE_REQUIRED_LIBRARIES})

	BB_Save_MakeVar(OPENGL_CFLAGS "\${OPENGL_CFLAGS}")
	BB_Save_MakeVar(OPENGL_LIBS "\${OPENGL_LIBS}")
endmacro()

macro(Disable_OpenGL)
	set(HAVE_OPENGL OFF)
	set(HAVE_GLU OFF)
	set(HAVE_GLX OFF)
	set(HAVE_GLEXT OFF)
	set(HAVE_WGL OFF)
	BB_Save_Undef(HAVE_OPENGL)
	BB_Save_Undef(HAVE_GLU)
	BB_Save_Undef(HAVE_GLX)
	BB_Save_Undef(HAVE_GLEXT)
	BB_Save_Undef(HAVE_WGL)
	BB_Save_MakeVar(OPENGL_CFLAGS "")
	BB_Save_MakeVar(OPENGL_LIBS "")
endmacro()
EOF
}

sub DISABLE_opengl
{
	MkDefine('HAVE_OPENGL', 'no') unless $TestFailed;
	MkDefine('HAVE_GLEXT', 'no');
	MkDefine('OPENGL_CFLAGS', '');
	MkDefine('OPENGL_LIBS', '');
	MkSaveUndef('HAVE_OPENGL', 'HAVE_GLEXT');
}

BEGIN
{
	my $n = 'opengl';

	$DESCR{$n}   = 'OpenGL';
	$URL{$n}     = 'http://www.OpenGL.org';
	$TESTS{$n}   = \&TEST_opengl;
	$CMAKE{$n}   = \&CMAKE_opengl;
	$DISABLE{$n} = \&DISABLE_opengl;
	$DEPS{$n}    = 'cc';
	$SAVED{$n}   = 'OPENGL_CFLAGS OPENGL_LIBS OPENGL_PC';
}
;1
