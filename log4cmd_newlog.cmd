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
set LOG4CMD_REGKEY_CMD="%DP0%\log4cmd_regkey.cmd"
if not exist %LOG4CMD_REGKEY_CMD% set LOG4CMD_REGKEY_CMD="%DP0%\log4cmd_regkey_example.cmd"
if not exist %LOG4CMD_REGKEY_CMD% (
  echo "%NX0%: aborting because neither %DP0%\log4cmd_regkey.cmd nor %DP0%\log4cmd_regkey_example.cmd was found"
  exit /b %ERROR_PATH_NOT_FOUND%
)
call %LOG4CMD_REGKEY_CMD%
if "%LOG4CMD_REGKEYVAL%" == "" (
  echo "%NX0%: aborting because environment variable LOG4CMD_REGKEYVAL was not found"
  exit /b %ERROR_INVALID_PARAMETER%
)

set LOG4CMD_HOME=
for /f "delims=" %%L in ('cscript //nologo "%DP0%\regReadExpand.vbs" "%LOG4CMD_REGKEYVAL%"') do @set LOG4CMD_HOME="%%L"
if [%LOG4CMD_HOME%] == [] (
  echo "%NX0%: aborting because environment variable LOG4CMD_HOME was not set"
  exit /b %ERROR_INVALID_PARAMETER%
)
set LOG4CMD_HOME=%LOG4CMD_HOME:~1,-1%

if [%3] == [] (
  echo usage: %0 environmentVariableName sourceName logName
  echo This script creates a logname and assignes it to the named variable.
  exit /b %ERROR_INVALID_PARAMETER%
)

set SOURCE_NAME=%2
set LOG_NAME=%3
set VARIABLE_NAME=%1

if not exist "%LOG4CMD_HOME%\%SOURCE_NAME%" mkdir "%LOG4CMD_HOME%\%SOURCE_NAME%"
if not exist "%LOG4CMD_HOME%\%SOURCE_NAME%" (
  echo "%NX0%: aborting because directory %LOG4CMD_HOME%\%SOURCE_NAME% does not exist or could not be created"
  exit /b %ERROR_INVALID_PARAMETER%
)

:: Get currentdatetime in ISO8601 in UTC time zone
for /f %%U in ('cscript //nologo "%DP0%\nowISO8601zulu.vbs"') do @set ISO8601ZULU=%%U
for /f %%U in ('cscript //nologo "%DP0%\uuid.vbs"') do @set UUID=%%U

:: colons are illegal in paths except for after a drive letter
set ISO8601ZULU=%ISO8601ZULU::=-%

:: construct the path
set LOG_DPNX=%LOG4CMD_HOME%\%SOURCE_NAME%\%LOG_NAME%_%ISO8601ZULU%_%UUID%.log

echo set %VARIABLE_NAME%=%LOG_DPNX%
endlocal & set %VARIABLE_NAME%=%LOG_DPNX%
