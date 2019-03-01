@echo off
chcp 65001 2>nul >nul


::pre-cleanup (solves repeating-override problem).
set "EXIT_CODE=0"
set "NODE="
set "SCRIPT="


::--------------------------------------------------------------------------------------


::system-PATH 'node.exe'.
echo [INFO] looking for node.exe ...                                         1>&2
set "NODE=%~sdp0node.exe"
if exist %NODE%                                       ( goto LOCAL_NODE     )
for /f "tokens=*" %%a in ('where node.exe 2^>nul') do ( set "NODE=%%a"      )
if ["%ErrorLevel%"] NEQ ["0"]                         ( goto ERROR_NONODE   )
if ["%NODE%"] EQU [""]                                ( goto ERROR_NONODE   )
for /f %%a in ("%NODE%")                           do ( set "NODE=%%~fsa"   )
if not exist %NODE%                                   ( goto ERROR_NONODE   )
:LOCAL_NODE
echo [INFO] %NODE%                                                           1>&2
echo [INFO] Done.                                                            1>&2
echo.                                                                        1>&2


::--------------------------------------------------------------------------------------select either nightly/developer version of firefox.


set "SCRIPT=index__nightly.js"
set "SCRIPT=%~sdp0%SCRIPT%"


::--------------------------------------------------------------------------------------

echo.                              1>&2
echo [INFO] calling:               1>&2
echo  "%NODE%" "%SCRIPT%"          1>&2
echo.                              1>&2
echo [INFO] program output:        1>&2
echo ----------------------------- 1>&2
call  "%NODE%" "%SCRIPT%" 
set "EXIT_CODE=%ErrorLevel%"
echo ----------------------------- 1>&2
echo [INFO] Done.                  1>&2

echo.                              1>&2

if ["%EXIT_CODE%"] NEQ ["0"]                          ( goto ERROR_NODEJS   )


echo. 1>&2
echo [INFO] program finished successfully. 1>&2


goto END


::--------------------------------------------------------------------------------------


:ERROR_NONODE
  set "EXIT_CODE=111"
  echo [ERROR] node.exe - can not find it. 1>&2


:ERROR_NODEJS
  echo [ERROR] program finished with errors. 1>&2
  goto END


:END
  echo exit code: [%EXIT_CODE%]. 1>&2
  echo.                          1>&2
::pause                          1>&2
  exit /b %EXIT_CODE%


::--------------------------------------------------------------------------------------
::  Exit codes
::    0        success.                                         node.exe found in system-PATH, node finished with an exit-code "0" (success).
::
::    Errors:
::    ----------
::    From 'index.cmd':
::    ---------------------------
::    111      node.exe - not found in system-PATH.             get it from https://nodejs.org/download/nightly/  (choose version, download node.exe from the 'win-x86/' folder).
::
::    From 'index.js' (NodeJS):
::    ---------------------------
::    1/other  JavaScript syntax-error or unexpected thrown-exception by NodeJS itself.
::--------------------------------------------------------------------------------------

