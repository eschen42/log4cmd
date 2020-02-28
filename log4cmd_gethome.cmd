@echo off
:: Generic source log name setup script log4cmd_newlog.cmd:
::   1. %1 variableName to set
::   4. Actions:
::     a. Abort if log4cmd is not configured
::     b. Abort if %3 is empty

setlocal
set DP0=%~dp0
set NX0=%~nx0

set VARIABLE_NAME=%1
if [%1] == [] (
  echo usage: %0 environmentVariableName
  echo This script retrieves the base directory for log4cmd.
  exit /b %ERROR_INVALID_PARAMETER%
)

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

echo set %VARIABLE_NAME%=%LOG4CMD_HOME%
endlocal & set %VARIABLE_NAME%=%LOG4CMD_HOME%
