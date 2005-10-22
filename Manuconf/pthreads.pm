# $Csoft: opengl.pm,v 1.5 2004/03/10 16:33:36 vedge Exp $
# vim:ts=4
#
# Copyright (c) 2005 CubeSoft Communications, Inc.
# <http://www.csoft.org>
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

my $pthreads_test = << 'EOF';
#include <pthread.h>
#include <signal.h>
void *start_routine(void *arg) { return (NULL); }
int main(int argc, char *argv[])
{
	pthread_mutex_t mutex;
	pthread_t thread;
	pthread_mutex_init(&mutex, NULL);
	pthread_mutex_lock(&mutex);
	pthread_mutex_unlock(&mutex);
	pthread_mutex_destroy(&mutex);
	pthread_create(&thread, NULL, start_routine, NULL);
	return (0);
}
EOF

sub TestPthreadsStd
{
	#
	# Look for the special -pthread compiler flag.
	#
	MkDefine('PTHREADS_CFLAGS', '');
	MkDefine('PTHREADS_LIBS', '-pthread');
	MkCompileC('HAVE_PTHREADS', '', '${PTHREADS_LIBS}', $pthreads_test);
	MkIf('"${HAVE_PTHREADS}" = "yes"');
		MkSaveMK('PTHREADS_CFLAGS', 'PTHREADS_LIBS');
		MkSaveDefine('PTHREADS_CFLAGS', 'PTHREADS_LIBS');
	MkElse();
		#
		# Look for the pthread library.
		#
		MkDefine('PTHREADS_LIBS', '-lpthread');
		MkCompileC('HAVE_PTHREADS', '', '${PTHREADS_LIBS}', $pthreads_test);
		MkIf('"${HAVE_PTHREADS}" = "yes"');
			MkSaveMK('PTHREADS_CFLAGS','PTHREADS_LIBS');
			MkSaveDefine('PTHREADS_CFLAGS','PTHREADS_LIBS');
		MkElse();
			MkSaveUndef('PTHREADS_CFLAGS','PTHREADS_LIBS');
		MkEndif();
	MkEndif();
	return (0);
}

sub TestPthreadMutexRecursive
{
	#
	# Look for the PTHREAD_MUTEX_RECURSIVE flag of the function
	# pthread_mutexattr_settype().
	#
	MkPrintN('checking for PTHREAD_MUTEX_RECURSIVE...');
	MkCompileC('HAVE_PTHREAD_MUTEX_RECURSIVE',
	    '${PTHREADS_CFLAGS}', '${PTHREADS_LIBS}', << 'EOF');
#include <pthread.h>
#include <signal.h>
int main(int argc, char *argv[])
{
	pthread_mutex_t mutex;
	pthread_mutexattr_t mutexattr;
	pthread_mutexattr_settype(&mutexattr, PTHREAD_MUTEX_RECURSIVE);
	pthread_mutex_init(&mutex, &mutexattr);
	return (0);
}
EOF
	MkIf('"${HAVE_PTHREAD_MUTEX_RECURSIVE}" = "yes"');
		MkSaveDefine('HAVE_PTHREAD_MUTEX_RECURSIVE');
	MkElse;
		MkSaveUndef('HAVE_PTHREAD_MUTEX_RECURSIVE');
	MkEndif;
	
	#
	# Look for the PTHREAD_MUTEX_RECURSIVE_NP flag of the function
	# pthread_mutexattr_settype().
	#
	MkPrintN('checking for PTHREAD_MUTEX_RECURSIVE_NP...');
	MkCompileC('HAVE_PTHREAD_MUTEX_RECURSIVE_NP',
	    '${PTHREADS_CFLAGS}', '${PTHREADS_LIBS}', << 'EOF');
#include <pthread.h>
#include <signal.h>
int main(int argc, char *argv[])
{
	pthread_mutex_t mutex;
	pthread_mutexattr_t mutexattr;
	pthread_mutexattr_settype(&mutexattr, PTHREAD_MUTEX_RECURSIVE_NP);
	pthread_mutex_init(&mutex, &mutexattr);
	return (0);
}
EOF
	MkIf('"${HAVE_PTHREAD_MUTEX_RECURSIVE_NP}" = "yes"');
		MkSaveDefine('HAVE_PTHREAD_MUTEX_RECURSIVE_NP');
	MkElse;
		MkSaveUndef('HAVE_PTHREAD_MUTEX_RECURSIVE_NP');
	MkEndif;
	return (0);
}

sub TestPthreadsXOpenExt
{
	MkPrintN('checking for the X/Open Threads Extension...');
	MkCompileC('HAVE_PTHREADS_XOPEN',
	    '${PTHREADS_CFLAGS} -U_XOPEN_SOURCE -D_XOPEN_SOURCE=500', '${PTHREADS_LIBS}', << 'EOF');
#include <pthread.h>
#include <signal.h>

int main(int argc, char *argv[])
{
	pthread_mutex_t mutex;
	pthread_mutexattr_t mutexattr;
	pthread_mutexattr_settype(&mutexattr, PTHREAD_MUTEX_RECURSIVE);
	pthread_mutex_init(&mutex, &mutexattr);
	return (0);
}
EOF
	MkIf('"${HAVE_PTHREADS_XOPEN}" = "yes"');
		MkDefine('PTHREADS_CFLAGS', '${PTHREADS_CFLAGS} -U_XOPEN_SOURCE '.
		                            '-D_XOPEN_SOURCE=500');
		MkSaveMK('PTHREADS_CFLAGS','PTHREADS_LIBS');
		MkSaveDefine('HAVE_PTHREADS_XOPEN', 'PTHREADS_CFLAGS', 'PTHREADS_LIBS');
	MkElse;
		MkSaveUndef('HAVE_PTHREADS_XOPEN');
	MkEndif;
	return (0);
}

sub TestPthreads
{
	TestPthreadsStd();
	TestPthreadsXOpenExt();
	TestPthreadMutexRecursive();
	return (0);
}

BEGIN
{
	$TESTS{'pthreads'} = \&TestPthreads;
	$DESCR{'pthreads'} = 'POSIX threads';
}

;1
