@rem ---------------------------------------------------------------------------
@rem Script used to build the DelphiDabbler PasHGUI project
@rem
@rem Copyright (C) Peter Johnson (www.delphidabbler.com), 2006
@rem
@rem v1.0 of 17 Jun 2006 - First version
@rem
@rem Requires:
@rem   Borland Delphi 2006
@rem   Borland BRCC32 from Delphi 2006 installation
@rem   DelphiDabbler Version Information Editor from www.delphidabbler.com
@rem
@rem Also requires the following environment variables:
@rem   DELPHI2006 to be set to the install directory of Delphi 7
@rem
@rem Switches: exactly one of the following must be provided
@rem   all - build everything
@rem   res - build binary resource files only
@rem   tlb - build type library from IDL and associated .pas file
@rem   pas - build Delphi Pascal project only
@rem   help - build help file
@rem   setup - build setup file
@rem
@rem ---------------------------------------------------------------------------

@echo off

setlocal


rem ----------------------------------------------------------------------------
rem Sign on
rem ----------------------------------------------------------------------------

echo DelphiDabbler PasHGUI Build Script
echo ----------------------------------
goto Config

rem ----------------------------------------------------------------------------
rem Configure script per command line parameter
rem ----------------------------------------------------------------------------

:Config
echo Configuring script
rem reset all config variables

set BuildResources=
set BuildPascal=

rem check switch

if "%~1" == "all" goto Config_BuildAll
if "%~1" == "res" goto Config_BuildResources
if "%~1" == "pas" goto Config_BuildPascal
set ErrorMsg=Unknown switch "%~1"
if "%~1" == "" set ErrorMsg=No switch specified
goto Error

rem set config variables

:Config_BuildAll
set BuildResources=1
set BuildPascal=1
set BuildSetup=1
goto Config_OK

:Config_BuildResources
set BuildResources=1
goto Config_OK

:Config_BuildPascal
set BuildPascal=1
goto Config_OK


rem script configured OK

:Config_OK
echo Done.
goto CheckEnvVars


rem ----------------------------------------------------------------------------
rem Check that required environment variables exist
rem ----------------------------------------------------------------------------

:CheckEnvVars

echo Checking predefined environment environment variables
if not defined DELPHI2006 goto BadDELPHI2006Env
echo Done.
echo.
goto SetEnvVars

rem we have at least one undefined env variable

:BadDELPHI2006Env
set ErrorMsg=DELPHI2006 Environment variable not defined
goto Error


rem ----------------------------------------------------------------------------
rem Set up required environment variables
rem ----------------------------------------------------------------------------

:SetEnvVars
echo Setting Up Environment
rem set up environment for MS SDK

rem directories

rem full path to this file
set BuildDir=%~dp0
rem source directory
set SrcDir=.\
rem binary files directory
set BinDir=..\Bin\
rem executable files directory
set ExeDir=..\Exe\

rem executable programs

rem Delphi 2006 Win32 - use full path since maybe multple installations
set DCC32Exe="%DELPHI2006%\Bin\DCC32.exe"
rem Borland Resource Compiler - use full path since maybe multple installations
set BRCC32Exe="%DELPHI2006%\Bin\BRCC32.exe"
rem DelphiDabbler Version Information Editor - assumed to be on the path
set VIEdExe=VIEd.exe

echo Done.
echo.


rem ----------------------------------------------------------------------------
rem Start of build process
rem ----------------------------------------------------------------------------

:Build
echo BUILDING ...
echo.

goto Build_Resources


rem ----------------------------------------------------------------------------
rem Build resource files
rem ----------------------------------------------------------------------------

:Build_Resources
if not defined BuildResources goto Build_Pascal
echo Building Resources
echo.

rem set required env vars

rem Ver info resource
set VerInfoBase=VersionInfo
set VerInfoSrc=%SrcDir%%VerInfoBase%.vi
set VerInfoTmp=%SrcDir%%VerInfoBase%.rc
set VerInfoRes=%BinDir%%VerInfoBase%.res
rem Resources resource
set ResourcesBase=Resources
set ResourcesSrc=%SrcDir%%ResourcesBase%.rc
set ResourcesRes=%BinDir%%ResourcesBase%.res

rem Compile version information resource

echo Compiling %VerInfoSrc% to %VerInfoRes%
rem VIedExe creates temp resource .rc file from .vi file
set ErrorMsg=
%VIEdExe% -makerc %VerInfoSrc%
if errorlevel 1 set ErrorMsg=Failed to compile %VerInfoSrc%
if not "%ErrorMsg%"=="" goto VerInfoRes_End
rem BRCC32Exe compiles temp resource .rc file to required .res
%BRCC32Exe% %VerInfoTmp% -fo%VerInfoRes%
if errorlevel 1 set ErrorMsg=Failed to compile %VerInfoTmp%
if not "%ErrorMsg%"=="" goto VerInfoRes_End
echo Done
echo.

:VerInfoRes_End
if exist %VerInfoTmp% del %VerInfoTmp%
if not "%ErrorMsg%"=="" goto Error


rem Compile Resources resource

echo Compiling %ResourcesSrc% to %ResourcesRes%
%BRCC32Exe% %ResourcesSrc% -fo%ResourcesRes%
if errorlevel 1 goto ResourcesRes_Error
echo Done
echo.
goto ResourcesRes_End

:ResourcesRes_Error
set ErrorMsg=Failed to compile %ResourcesSrc%
goto Error

:ResourcesRes_End

rem End of resource compilation

goto Build_Pascal


rem ----------------------------------------------------------------------------
rem Build Pascal project
rem ----------------------------------------------------------------------------

:Build_Pascal
if not defined BuildPascal goto Build_End

rem Set up required env vars
set PascalBase=PasHGUI
set PascalSrc=%SrcDir%%PascalBase%.dpr
set PascalExe=%ExeDir%%PascalBase%.exe

if not defined BuildPascal goto Build_Help
echo Building Pascal Project
%DCC32Exe% -B %PascalSrc%
if errorlevel 1 goto Pascal_Error
goto Pascal_End

:Pascal_Error
set ErrorMsg=Failed to compile %PascalSrc%
if exist %PascalExe% del %PascalExe%
goto Error

:Pascal_End
echo Done.
echo.

rem End of Pascal compilation

goto Build_End


rem ----------------------------------------------------------------------------
rem Build completed
rem ----------------------------------------------------------------------------

:Build_End
echo BUILD COMPLETE
echo.

goto End


rem ----------------------------------------------------------------------------
rem Handle errors
rem ----------------------------------------------------------------------------

:Error
echo.
echo *** ERROR: %ErrorMsg%
echo.


rem ----------------------------------------------------------------------------
rem Finished
rem ----------------------------------------------------------------------------

rem **** TO DO Unset all variables? ****

:End
echo.
echo DONE.
endlocal