@echo off
setlocal

rem Start a local web server for the battery and open it in the browser (Windows).
rem
rem Usage, from Command Prompt or PowerShell in the repository folder:
rem   .\serve day=1          day can be 0, 1 or 2
rem   .\serve task=effort    task can be effort, rlwm, foraging or gonogo
rem
rem For local testing only. Pavlovia does not use this script.

rem Command Prompt splits "day=1" into two arguments at the "=", so join them again.
set "PARAM=%~1"
if not "%~2"=="" set "PARAM=%~1=%~2"

set "OK="
if /i "%PARAM%"=="day=0" set "OK=1"
if /i "%PARAM%"=="day=1" set "OK=1"
if /i "%PARAM%"=="day=2" set "OK=1"
if /i "%PARAM%"=="task=effort" set "OK=1"
if /i "%PARAM%"=="task=rlwm" set "OK=1"
if /i "%PARAM%"=="task=foraging" set "OK=1"
if /i "%PARAM%"=="task=gonogo" set "OK=1"
if not defined OK (
    if not "%PARAM%"=="" echo Invalid parameter: %PARAM%
    echo Usage: .\serve day=0, day=1 or day=2
    echo        .\serve task=effort, task=rlwm, task=foraging or task=gonogo
    pause
    exit /b 1
)

rem Find Python 3. "py" is the launcher installed by the python.org installer.
set "PY="
py -3 -c "pass" >nul 2>&1 && set "PY=py -3"
if not defined PY python -c "import sys; sys.exit(sys.version_info[0] != 3)" >nul 2>&1 && set "PY=python"
if not defined PY (
    echo Python 3 was not found. Install it from https://www.python.org/downloads/
    echo and tick "Add python.exe to PATH" in the installer.
    pause
    exit /b 1
)

rem Find a free port, starting at 8000.
set "PORT="
for /f %%p in ('%PY% -c "import socket; print(next(p for p in range(8000, 8101) if socket.socket().connect_ex(('127.0.0.1', p))))"') do set "PORT=%%p"
if not defined PORT (
    echo No free port found between 8000 and 8100.
    pause
    exit /b 1
)

set "URL=http://localhost:%PORT%/index.html?%PARAM%"
echo.
echo Battery running at: %URL%
echo Press Ctrl+C to stop the server.
echo.

rem Open the browser after a short delay so the server has time to start.
start "" /b cmd /c "ping -n 2 127.0.0.1 >nul & start "" "%URL%""

rem Bind to 127.0.0.1 so the server is reachable only from this machine.
rem Serve the folder this script lives in, regardless of where it is called from.
%PY% -m http.server %PORT% --bind 127.0.0.1 --directory "%~dp0."
