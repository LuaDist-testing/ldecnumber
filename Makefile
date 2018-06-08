# makefile for decNumber library for Lua
#
# Created September 3, 2006 by e
# This version of the Makefile has been used on WinXP with MinGW/MSYS
# Subversion is used for version control 
#   and generation of version info for headers and file names
# Be sure to "make install" before "make testall"

#AK(30-Sep-06):
# - adopted for OS X (and generalized a bit while at it..)
# - adopted for pkg-config (as an alternative for manually giving the paths)

ifneq "$(shell pkg-config --version)" ""
  # automagic setup (OS X fink, Linux apt-get, ..)
  #
  LUAINC= $(shell pkg-config --cflags lua)
  LUALIB= $(shell pkg-config --libs lua)
  LUAEXE= lua
  #
  # Now, we actually want to _not_ push in stuff to the distro Lua CMOD directory,
  # way better to play within /usr/local/lib/lua/5.1/
  #
  #LUACMOD= $(shell pkg-config --variable=INSTALL_CMOD lua)
  LUACMOD= /usr/local/lib/lua/5.1/
else
  # manual setup (change these to reflect your Lua installation)
  #
  BASE= /usr/local
  LUAINC= -I$(BASE)/include
  LUALIB= -L$(BASE)/lib -llua51
  LUAEXE= $(BASE)/bin/lua.exe
#  LUACMOD= $(BASE)/lib/lua/5.1/
#  Windows' LUA_CDIR is the Lua executable's directory...
  LUACMOD= $(BASE)/bin
  POD2HTML= perl -x -S doc/pod2html.pl
endif

TMP=./tmp
DISTDIR=./archive

# OS detection
#
SHFLAGS=-shared
VCHECK=
UNAME= $(shell uname)
ifeq "$(UNAME)" "Linux"
  _SO=so
  SHFLAGS= -fPIC
endif
ifneq "" "$(findstring BSD,$(UNAME))"
  _SO=so
endif
ifeq "$(UNAME)" "Darwin"
  _SO=bundle
  SHFLAGS= -bundle
endif
ifneq "" "$(findstring msys,$(OSTYPE))"		# 'msys'
  _SO=dll
  VCHECK=SubWCRev `pwd` version.in version.h
endif

ifndef _SO
  $(error $(UNAME))
  $(error Unknown OS)
endif

# no need to change anything below here - HAH!
CFLAGS= $(INCS) $(DEFS) $(WARN) -O2 $(SHFLAGS)
WARN= -Wall #-ansi -pedantic -Wall
INCS= $(LUAINC) -IdecNumber
LIBS= $(LUALIB)

MYNAME= decNumber
MYLIB= l$(MYNAME)
VER=$(shell svnversion -c . | sed 's/.*://')
TARFILE = $(DISTDIR)/$(MYLIB)-$(VER).tar.gz

OBJS= $(MYLIB).o decNumber/decNumber.o decNumber/decContext.o
T= $(MYLIB).$(_SO)

TESTLIBS=test/lperformance.$(_SO)

all: $T

$T:	version.h $(OBJS)
	$(CC) $(SHFLAGS) -o $@ -shared $(OBJS) $(LIBS)

$(MYLIB).o: version.h

version.h: vcheck

vcheck:
	$(VCHECK)

test: $T
	cd test; $(LUAEXE) ldecNumberUnitTest.lua
	cd test; $(LUAEXE) ldecNumberThreadsTest.lua
	cd test; $(LUAEXE) ldecNumberTestDriver.lua

# testall will only work on Windows unless you remove/rewrite performance tests

testall: $T $(TESTLIBS) test
	cd test; $(LUAEXE) ldecNumberPerf.lua

# Note: This is Windows specific anyways... :((((((
#
test/lperformance.$(_SO):	test/lperformance.o
	$(CC) $(SHFLAGS) -o $@ -shared test/lperformance.o $(LIBS)

install:
	cp $T $(LUACMOD)

clean:
	rm -f $(OBJS) $T core core.* a.out

html:
	$(POD2HTML) --title="Lua decNumber" --infile=doc/ldecNumber.pod --outfile=doc/ldecNumber.html

td:
	touch $(MYLIB)-$(VER).tar.gz

dist: vcheck html
	echo 'Exporting...'
	mkdir -p $(TMP)
	mkdir -p $(DISTDIR)
	svn export -r HEAD . $(TMP)/$(MYLIB)-$(VER)
	cp -p version.h $(TMP)/$(MYLIB)-$(VER)
	cp -p doc/decNumber.pdf $(TMP)/$(MYLIB)-$(VER)/doc
	cp -p doc/ldecNumber.pdf $(TMP)/$(MYLIB)-$(VER)/doc
	cp -p doc/ldecNumber.html $(TMP)/$(MYLIB)-$(VER)/doc
	echo 'Compressing...'
	tar -zcf $(TARFILE) -C $(TMP) $(MYLIB)-$(VER)
	rm -fr $(TMP)/$(MYLIB)-$(VER)
	echo 'Done.'

.PHONY: all vcheck test testall clean html td dist install

