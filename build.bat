@ECHO OFF
COLOR 07
TITLE Retromaze Build Script

SET START=%CD%

IF /I "%PROCESSOR_ARCHITECTURE%"=="x32" (
    IF NOT DEFINED PROCESSOR_ARCHITEW6432 (
        SET ARCH=32
    ) ELSE (
        SET ARCH=64
    )
) ELSE IF /I "%PROCESSOR_ARCHITECTURE%"=="x86" (
        IF NOT DEFINED PROCESSOR_ARCHITEW6432 (
            SET ARCH=32
        ) ELSE (
            SET ARCH=64
        )
) ELSE (
        SET ARCH=64
)

IF /I "%1"=="/FORCEWIN32" (
    ECHO Note: Tools will run in 32-bit mode!
    TITLE Retromaze Build Script [32-bit]
    SET ARCH=32
)
IF /I "%1"=="/FORCEWIN64" (
    ECHO Note: Tools will run in 64-bit mode!
    TITLE Retromaze Build Script [64-bit]
    SET ARCH=64
)

"%START%\utilities\windows\win%ARCH%\gitcommit.exe" batch "%START%\utilities\commit.bat" --silent
IF NOT %ERRORLEVEL%==0 GOTO EXEFail
CALL "%START%\utilities\commit.bat"
IF NOT %ERRORLEVEL%==0 GOTO EXEFail
CALL "%START%\version.bat"
IF NOT %ERRORLEVEL%==0 GOTO EXEFail

IF NOT EXIST "%START%\retromaze\acs\" (
	MKDIR "%START%\retromaze\acs\" >nul
)

IF NOT EXIST "%START%\out\" (
	MKDIR "%START%\out\" >nul
)

ECHO Compiling ACS.
"%START%\utilities\windows\acc\acc.exe" "%START%\retromaze\source\libretro.acs" "%START%\retromaze\acs\libretro.o"
IF NOT %ERRORLEVEL%==0 GOTO ACCFail

CD "%START%\retromaze"

"%START%\utilities\windows\win%ARCH%\7za.exe" a -tzip "%START%\out\retromaze-%VERSION%_git-%COMMIT_HASH%.pk3" *.* -r -xr!*.dbs -xr!*.backup1 -xr!*.backup2 -xr!*.backup3 -xr!*.bak
IF NOT %ERRORLEVEL%==0 GOTO EXEFail

COLOR 0A
ECHO.
ECHO Retromaze should have been built successfully.

ECHO.
ECHO Press any key to exit.
PAUSE >nul
EXIT 0

:ACCFail
COLOR 0C
ECHO.
TITLE Retromaze Build Failure!
ECHO Building libretro.acs has failed.
ECHO Please fix the errors and retry.
ECHO.
ECHO Press any key to exit.
PAUSE >nul
EXIT 1

:EXEFail
COLOR 0C
ECHO.
TITLE Retromaze Build Failure!
ECHO A utility has failed somewhere.
ECHO Please check for error messages and try again.
ECHO.
ECHO Press any key to exit.
PAUSE >nul
EXIT 2
