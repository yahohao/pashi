# ------------------------------------------------------------------------------
# This Source Code Form is subject to the terms of the Mozilla Public License,
# v. 2.0. If a copy of the MPL was not distributed with this file, You can
# obtain one at http://mozilla.org/MPL/2.0/
#
# Copyright (C) 2010-2015, Peter Johnson (www.delphidabbler.com).
#
# Makefile for the PasHiGUI project.
# ------------------------------------------------------------------------------

# Set required output paths for Common.mak
ROOT = ..\..
BINREL = GUI


# Include common macros and rules
!include ..\Common.mak

# Default target is to configure and build the executable program
everything: config resources pascal

# Configure source folders
config:
  @echo Configuring PasHiGUI
  # Create .cfg file from templates
  @copy /Y PasHiGUI.cfg.tplt PasHiGUI.cfg
  # Create build folders
  @if not exist $(BUILD) @mkdir $(BUILD)
  @if not exist $(BINBASE) @mkdir $(BINBASE)
  @if not exist $(BIN) @mkdir $(BIN)
  @if not exist $(EXE) @mkdir $(EXE)

# Compiles the resources
resources: VersionInfo.res Resources.res

# Builds PasHiGUI pascal files and links program
pascal: PasHiGUI.exe
