# ------------------------------------------------------------------------------
# This Source Code Form is subject to the terms of the Mozilla Public License,
# v. 2.0. If a copy of the MPL was not distributed with this file, You can
# obtain one at http://mozilla.org/MPL/2.0/
#
# Copyright (C) 2010-2015, Peter Johnson (www.delphidabbler.com).
#
# Common code for inclusion in all make files. Defines common macros and rules.
# Files that require Common.mak must include it using the !include directive.
# ------------------------------------------------------------------------------


# The preferred compiler is Delphi XE. If the DELPHIXE environment variable is
# set, it will be used and expected to reference the Delphi XE install
# directory.
# If DELPHIXE is not set then the DELPHIROOT environment variable is examined.
# This can be set to any Delphi compiler. If neither DELPHIXE nor DELPHIROOT is
# set then an error is reported.
!ifdef DELPHIXE
DELPHIROOT = $(DELPHIXE)
!endif

# Requires the following macros:
#   ROOT
#     Set to the root project relative to current directory. Must not have
#     trailing path delimiter.
#   BINREL
#     Set to the directory relative to the base Bin directory that is to
#     receive .res and .dcu output. Must not have trailing path delimiter. May
#     be empty, but must be defined.
#   DELPHIROOT
#     Install directory of Delphi compiler to be used.

# Check for required macros

!ifndef DELPHIROOT
!error DELPHIROOT environment variable required.
!endif

!ifndef ROOT
!error ROOT macro must be defined in calling script.
!endif

!ifndef BINREL
!error BINREL macro must be defined in calling script.
!endif

# Set required directory macros
SRC = $(ROOT)\Src
DOCS = $(ROOT)\Docs
BUILD = $(ROOT)\Build
EXE = $(BUILD)\Exe
BINBASE = $(BUILD)\Bin
BIN = $(BINBASE)\$(BINREL)
RELEASE = $(BUILD)\Release

# Define common macros that access required build tools

MAKE = "$(MAKEDIR)\Make.exe" -$(MAKEFLAGS)
DCC32 = "$(DELPHIROOT)\Bin\DCC32.exe"
BRCC32 = "$(DELPHIROOT)\Bin\BRCC32.exe"
RC = "$(DELPHIROOT)\Bin\RC.exe"
!ifdef VIEDROOT
VIED = "$(VIEDROOT)\VIEd.exe" -makerc
!else
VIED = VIEd.exe -makerc
!endif
!ifdef INNOSETUP
ISCC = "$(INNOSETUP)\ISCC.exe"
!else
ISCC = ISCC.exe
!endif
!ifdef ZIPROOT
ZIP = "$(ZIPROOT)\Zip.exe"
!else
ZIP = Zip.exe
!endif


# Implicit rules
# Delphi projects are assumed to contain required output and search path
# locations in the project options .cfg file.
.dpr.exe:
  @echo +++ Compiling Delphi Project $< +++
  @$(DCC32) $< -B

# Resource files are compiled to the Bin directory using RC.
.rc.res:
  @echo +++ Compiling Resource file $< to $(@F) +++
  @$(RC) -fo$(BIN)\$(@F) $<

# Temporary resource files with special extension .tmp-rcx are compiled to the
# Bin directory using BRCC32.
.tmp-rcx.res:
  @echo +++ Compiling Resource file $< to $(@F) +++
  @$(BRCC32) -fo$(BIN)\$(@F) $<
  -@del $(<B).tmp-rcx

# Version info files are compiled by VIEd to a temporary .tmp-rcx resource file.
.vi.tmp-rcx:
  @echo +++ Compiling Version Info file $< to $(@F) +++
  @$(VIED) .\$<
  -@ren $(@B).rc $(@F)
