# /****************************************************************
# Copyright (C) Lucent Technologies 1997
# All Rights Reserved
#
# Permission to use, copy, modify, and distribute this software and
# its documentation for any purpose and without fee is hereby
# granted, provided that the above copyright notice appear in all
# copies and that both that the copyright notice and this
# permission notice and warranty disclaimer appear in supporting
# documentation, and that the name Lucent Technologies or any of
# its entities not be used in advertising or publicity pertaining
# to distribution of the software without specific, written prior
# permission.
#
# LUCENT DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE,
# INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS.
# IN NO EVENT SHALL LUCENT OR ANY OF ITS ENTITIES BE LIABLE FOR ANY
# SPECIAL, INDIRECT OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER
# IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION,
# ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF
# THIS SOFTWARE.
# ****************************************************************/

CFLAGS = /nologo /MD /O2 /W3 /TC /DNDEBUG /DWIN32 /D_CONSOLE \
         /D_CRT_SECURE_NO_WARNINGS /D_SECURE_CRT_NO_DEPRECATE

# compiler options
#CC = gcc -Wall -g -Wwrite-strings
#CC = gcc -O4 -Wall -pedantic -fno-strict-aliasing
#CC = gcc -fprofile-arcs -ftest-coverage # then gcov f1.c; cat f1.c.gcov
CC = cl

# By fiat, to make our lives easier, yacc is now defined to be bison.
# If you want something else, you're on your own.
YACC = E:\build\win_flex_bison-2.5.25\win_bison.exe -d

OFILES = b.obj main.obj parse.obj proctab.obj tran.obj lib.obj run.obj lex.obj \
         missing95.obj

SOURCE = awk.h awkgram.tab.c awkgram.tab.h proto.h awkgram.y lex.c b.c main.c \
	maketab.c parse.c lib.c run.c tran.c proctab.c missing95.c

LISTING = awk.h proto.h awkgram.y lex.c b.c main.c maketab.c parse.c \
	lib.c run.c tran.c missing95.c

SHIP = README LICENSE FIXES $(SOURCE) awkgram.tab.[ch].bak makefile  \
	 awk.1

awk.exe:	awkgram.tab.obj $(OFILES)
	link /nologo /out:awk.exe /machine:x86 /incremental:no /subsystem:console \
    awkgram.tab.obj $(OFILES) $(ALLOC) setargv.obj

%.obj: %.c
	$(CC) $(CFLAGS) /c /Fo$@ $<

$(OFILES):	awk.h awkgram.tab.h proto.h

awkgram.tab.c awkgram.tab.h:	awk.h proto.h awkgram.y
	$(YACC) $(YFLAGS) awkgram.y

proctab.c:	maketab.exe
	.\maketab.exe awkgram.tab.h > proctab.c

maketab.exe:	awkgram.tab.h maketab.c
	$(CC) $(CFLAGS) /Femaketab.exe maketab.c

bundle:
	@cp awkgram.tab.h awkgram.tab.h.bak
	@cp awkgram.tab.c awkgram.tab.c.bak
	@bundle $(SHIP)

tar:
	@cp awkgram.tab.h awkgram.tab.h.bak
	@cp awkgram.tab.c awkgram.tab.c.bak
	@bundle $(SHIP) >awk.shar
	@tar cf awk.tar $(SHIP)
	gzip awk.tar
	ls -l awk.tar.gz
	@zip awk.zip $(SHIP)
	ls -l awk.zip

gitadd:
	git add README LICENSE FIXES \
           awk.h proto.h awkgram.y lex.c b.c main.c maketab.c parse.c \
	   lib.c run.c tran.c \
	   makefile awk.1 testdir

gitpush:
	# only do this once:
	# git remote add origin https://github.com/onetrueawk/awk.git
	git push -u origin master

names:
	@echo $(LISTING)

test check:
	./REGRESS

clean:
	del /q awk.exe a.out *.o *.obj maketab maketab.exe *.bb *.bbg *.da *.gcov *.gcno *.gcda # proctab.c

cleaner:
	del /q awk.exe a.out *.o *.obj maketab maketab.exe *.bb *.bbg *.da *.gcov *.gcno *.gcda proctab.c awkgram.tab.*

# This is a bit of a band-aid until we can invest some more time
# in the test suite.
testclean:
	cd testdir; rm -fr arnold-fixes beebe devnull echo foo* \
		glop glop1 glop2 lilly.diff tempbig tempsmall time

# For the habits of GNU maintainers:
distclean: cleaner
