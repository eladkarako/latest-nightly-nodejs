@echo off
chcp 65001 2>nul >nul


::---------------
::Steps to update to latest-nightly-build, of the latest firefox:
:: 1. get the URL for the latest nightly version in a zip-format, from 'https://ftp.mozilla.org/pub/firefox/nightly/latest-mozilla-central-l10n/' HTML (using NodeJS)
:: 2. download using 'aria2c.cmd'
:: 3. extract zip.
:: 4. replace content of 'D:\Software\Mozilla\firefox\' folder with the content from step [3.] .
:: 5. done
::---------------


::pre-cleanup (solves repeating-override problem).
set "EXIT_CODE=0"
set "GET_MOST_UPDATED_URL="
set "URL="
set "ARIA2C_CMD="
set "FOLDER_MOZILLA="


set "GET_MOST_UPDATED_URL=%~sdp0get_most_updated_url.cmd"
for /f %%a in ("%GET_MOST_UPDATED_URL%")                        do ( set "GET_MOST_UPDATED_URL=%%~fsa"   )
if not exist %GET_MOST_UPDATED_URL%                                ( goto ERROR_NO_GET_MOST_UPDATED_URL  )


echo [INFO] Using get_most_updated_url.cmd from:   %GET_MOST_UPDATED_URL%     1>&2


for /f "tokens=*" %%a in ('call %GET_MOST_UPDATED_URL%') do ( set "URL=%%a"                             )
set "EXIT_CODE=%ErrorLevel%"
if ["%EXIT_CODE%"] NEQ ["0"]                                       ( goto ERROR_FAILED_TO_GET_MOST_UPDATED_URL )
if ["%URL%"] EQU [""]                                              ( goto ERROR_FAILED_TO_GET_MOST_UPDATED_URL )


echo going to download:     1>&2
echo %URL%                  1>&2
echo using 'aria2c.cmd'     1>&2


set "FOLDER_CURRENT=%~sdp0"
set "FOLDER_CURRENT=%FOLDER_CURRENT:\=/%"

::--------------------------------------------------------------------------------------------note that this will normalize the actual file-name.
call aria2c.cmd  "--dir=%FOLDER_CURRENT%"  "--out=firefox-XXXXXX.en-GB.win64.zip"  "%URL%"
set "EXIT_CODE=%ErrorLevel%"
if ["%EXIT_CODE%"] NEQ ["0"]                                       ( goto ERROR_FAILED_DOWNLOAD                )


::---------------------------------------------------
::---------------------------------------------------
set "FOLDER_MOZILLA=.\..\..\firefox"
for /f %%a in ("%FOLDER_MOZILLA%") do ( set "FOLDER_MOZILLA=%%~fsa" )

del   /q /s /f "%FOLDER_MOZILLA%"               1>nul 2>nul
del   /q /s /f "%FOLDER_MOZILLA%\"              1>nul 2>nul
del   /q /s /f /a:rhisal "%FOLDER_MOZILLA%\*"   1>nul 2>nul
rmdir /q /s    "%FOLDER_MOZILLA%"               1>nul 2>nul
rmdir /q /s    "%FOLDER_MOZILLA%\"              1>nul 2>nul


if exist "%FOLDER_MOZILLA%" ( goto ERROR_MOZILLA_FOLDER )
move /y ".\firefox-XXXXXX.en-GB.win64.zip" "%FOLDER_MOZILLA%\..\"
cd "%FOLDER_MOZILLA%\..\"
unzip "firefox-XXXXXX.en-GB.win64.zip"

del /q /s /f "firefox-XXXXXX.en-GB.win64.zip"   1>nul 2>nul

goto END


:ERROR_NO_GET_MOST_UPDATED_URL
  echo [ERROR] can't find 'get_most_updated_url.cmd'.  1>&2
  goto END


:ERROR_FAILED_TO_GET_MOST_UPDATED_URL
  echo [ERROR] 'get_most_updated_url.cmd' failed.      1>&2
  goto END


:ERROR_MOZILLA_FOLDER
  echo [ERROR] can not delete the mozilla folder at    1>&2
  echo %FOLDER_MOZILLA%                                1>&2
  echo manually-extract the zip-file from %~sdp0       1>&2
  echo replacing the old 'firefox' folder.             1>&2
  goto END


:END
  echo exit code: [%EXIT_CODE%]. 1>&2
  echo.                          1>&2
  pause                          1>&2
  exit /b %EXIT_CODE%

