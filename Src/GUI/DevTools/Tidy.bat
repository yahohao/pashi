@rem ---------------------------------------------------------------------------
@rem Script used to delete temp and backup source files of PasHGUI
@rem
@rem Copyright (C) Peter Johnson (www.delphidabbler.com), 2006-2010
@rem
@rem $Rev$
@rem $Date$
@rem
@rem Switches:
@rem   no switch - delete temp source files
@rem ---------------------------------------------------------------------------

@echo off

echo Tidying
echo ~~~~~~~
echo.

set RootDir=..


echo Deleting temporary files
del /S %RootDir%\*.~* 
del /S %RootDir%\*.dcu 
del /S %RootDir%\*.exe 
del /S %RootDir%\*.dsk 
del /S %RootDir%\*.bak
del /S %RootDir%\*.identcache
del /S %RootDir%\*.local
echo.

echo Deleting temporary directories
if exist %RootDir%\Release rmdir /S /Q %RootDir%\Release
for /F "usebackq" %%i in (`dir /S /B /A:D %RootDir%\__history*`) do rmdir /S /Q %%i
echo.

echo Done.

endlocal
