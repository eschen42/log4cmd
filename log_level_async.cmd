@echo off
:: example:
::   log_level_async debug "this is only a test" my_debug
:: argument 1 must be the log level and must be unquoted
:: argument 2 must be the message, wrapped in double quotes
::            [single quotes will work but are not recommended.]
:: argument 3 must be the log source and must have neither double quotes nor spaces
setlocal

if defined LOG4CMD_VALIDATE_NOTHING (
  set NO_VALIDATION=TRUE
  set ONLY_VALIDATE_MSG=TRUE
) else if defined LOG4CMD_VALIDATE_LVL_MSG_SRC (
  set NO_VALIDATION=
  set ONLY_VALIDATE_MSG=
) else (
  set NO_VALIDATION=
  set ONLY_VALIDATE_MSG=TRUE
)

:: capture arg 0
set DP0=%~dp0
set NX0=%~nx0
set MSG=
set LVL=
set ARG4=
set SRC=

if not defined USAGE set USAGE=%NX0% level "message in double quotes" log_source

:: capture arg 4 if it exists [it should not]
set ARG4=%4
if defined ARG4 (
  echo  ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! >&2
  echo %NX0%: too many arguments 1>&2
  echo %NX0% was invoked with the following arguments: >&2
  goto :usage
)


:: capture arg 1
set LVL=%1
if defined ONLY_VALIDATE_MSG goto :post_arg1

call "%~dp0\log4cmd_validate.cmd" LVL RXNQNS
if %ERRORLEVEL% neq 0 (
  echo LVL "%LVL%"
  echo  ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! >&2
  echo %NX0%: bad first argument [level] 1>&2
  echo %NX0% was invoked with the following arguments: >&2
  goto :usage
)

:: validate argument 1 to avert scripting attacks
set LVL | findstr /r /c:"^LVL=" | findstr /i "LVL=debug LVL=error LVL=fail LVL=fatal LVL=info LVL=none LVL=noop LVL=pass LVL=skip LVL=warn" >NUL || (
  echo  ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! >&2
  echo %NX0%: bad first argument [level] 1>&2
  echo Expected one of: 1>&2
  echo ^  info error fail fatal info none noop pass skip warn 1>&2
  echo %NX0% was invoked with the following arguments: >&2
  goto :usage
)

:post_arg1

:: validate argument 2 is double-quoted to avert scripting attacks
set MSG=%2

if defined NO_VALIDATION goto :post_arg2

:: - MSG must:
::   - begin and end with double quotes
::   - have no internal double quotes
:: - Regular expressions containing double quotes must escape certain
::   characters with hats.
::   - So, use patterns that don't include double quotes

set RESULT=1
call "%~dp0\log4cmd_validate.cmd" MSG RXDQNQ

set RESULT=%ERRORLEVEL%
if not %ERRORLEVEL% equ 0 echo line 72 RESULT %RESULT%
if %RESULT% neq 0 (
  echo  ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! >&2
  echo %NX0%: second argument [message] not found or is bad 1>&2
  echo %NX0% was invoked with the following arguments: >&2
  goto :usage
)

:post_arg2
:: escape less than
set MSG=%MSG:<=^<%
:: escape greater than
set MSG=%MSG:>=^>%
:: escape ampersand
set MSG=%MSG:&=^&%
:: escape pipe
set MSG=%MSG:|=^|%

:: validate argument 3 is unquoted and without spaces to avert scripting attacks
set SRC=%3
if defined ONLY_VALIDATE_MSG goto :post_arg3

if not defined SRC goto :post_source
:: - SRC must:
::   - not begin or end with double quotes
::   - have no internal double quotes
call "%~dp0\log4cmd_validate.cmd" SRC RXNQNS

if %ERRORLEVEL% neq 0 (
  echo SRC "%SRC%"
  echo  ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! >&2
  echo %NX0%: bad third argument [log_source] 1>&2
  echo %NX0% was invoked with the following arguments: >&2
  goto :usage
)

:post_source

:post_arg3

if defined LOG4CMD_ASYNC (
  set CLEAN_CMD=start /b /i /d "%CD%" "%windir%\explorer.exe" "%windir%\system32\cmd.exe" /c
) else (
  set CLEAN_CMD="%windir%\system32\cmd.exe" /c
)

if     defined SRC set LOG_CMD=cscript //nologo ^"%DP0%\log4vbs.vbs" /lvl:%LVL% /msg:%MSG% /src:%SRC%
if not defined SRC set LOG_CMD=cscript //nologo ^"%DP0%\log4vbs.vbs" /lvl:%LVL% /msg:%MSG%

%CLEAN_CMD% ^"%LOG_CMD%^"

exit /b 0

:usage

if defined LVL echo ^ ^ ^ ^ ^ ^ ^ ^ %*
echo usage: %USAGE% 1>&2
if not defined LOG4CMD_TERSE (
  echo ^ ^ + level argument [if applicable] should be unquoted and be one of: 1>&2
  echo ^ ^ ^ ^ ^ ^ ^ ^ debug info warn error fatal pass fail skip noop none 1>&2
  echo ^ ^ + message argument must be double-quoted 1>&2
  echo ^ ^ + log_source argument [optional] must NOT be double-quoted 1>&2
  echo ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~  >&2
)
exit /b -1
