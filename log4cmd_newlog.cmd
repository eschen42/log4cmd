@echo off
:: Generic source log name setup script log4cmd_newlog.cmd:
::   1. %1 sourceName
::   2. %2 logName
::   3. %3 variableName to set
::   4. Actions:
::     a. Abort if log4cmd is not configured
::     b. Abort if %3 is empty
::     c. Generate log name as iso8601zulu-UUID-logName.log
::     d. Create if not exist 
::          %USERPROFILE%\AppData\Local\log4cmd\sourceName\

setlocal
set DP0=%~dp0
set NX0=%~nx0

set ERROR_PATH_NOT_FOUND=-3
set ERROR_INVALID_PARAMETER=-87
if not exist "%DP0%\log4cmd_regkey.cmd" (
  echo "%NX0%: aborting because file %DP0%\log4cmd_regkey.cmd was not found"
  exit /b %ERROR_PATH_NOT_FOUND%
)
call "%DP0%\log4cmd_regkey.cmd"
if "%LOG4CMD_REGKEYVAL%" == "" (
  echo "%NX0%: aborting because environment variable LOG4CMD_REGKEYVAL was not found"
  exit /b %ERROR_INVALID_PARAMETER%
)

set LOG4CMD_HOME=
for /f %%L in ('cscript //nologo regReadExpand.vbs "%LOG4CMD_REGKEYVAL%"') do @set LOG4CMD_HOME=%%L
if [%LOG4CMD_HOME%] == [] (
  echo "%NX0%: aborting because environment variable LOG4CMD_HOME was not set"
  exit /b %ERROR_INVALID_PARAMETER%
)

if [%3] == [] (
  echo usage: %0 sourceName logName variableName
  echo This script creates a logname and assignes it to the named variable.
  exit /b %ERROR_INVALID_PARAMETER%
)

set SOURCE_NAME=%1
set LOG_NAME=%2
set VARIABLE_NAME=%3

if not exist "%LOG4CMD_HOME%\%SOURCE_NAME%" mkdir "%LOG4CMD_HOME%\%SOURCE_NAME%"
if not exist "%LOG4CMD_HOME%\%SOURCE_NAME%" (
  echo "%NX0%: aborting because directory %LOG4CMD_HOME%\%SOURCE_NAME% does not exist or could not be created"
  exit /b %ERROR_INVALID_PARAMETER%
)

:: Get currentdatetime in ISO8601 in UTC time zone
for /f %%U in ('cscript //nologo "%DP0%\nowISO8601zulu.vbs"') do @set ISO8601ZULU=%%U
for /f %%U in ('cscript //nologo "%DP0%\uuid.vbs"') do @set UUID=%%U

set LOG_DPNX=%LOG4CMD_HOME%\%SOURCE_NAME%\%ISO8601ZULU%_%UUID%_%LOG_NAME%.log

echo set %VARIABLE_NAME%=%LOG_DPNX%
endlocal & set %VARIABLE_NAME%=%LOG_DPNX%
