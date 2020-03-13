@echo off
:: example:
::   log_level_async debug "this is only a test" my_debug
:: argument 1 must be the log level and must be unquoted
:: argument 2 must be the message, wrapped in double quotes
::            [single quotes will work but are not recommended.]
:: argument 3 must be the log source and must have neither double quotes nor spaces
setlocal

:: capture arg 0
set DP0=%~dp0
set NX0=%~nx0
set MSG=
set LVL=
set ARG4=
set SRC=

if not defined USAGE set USAGE=%NX0% level "message in double quotes" log_source

:: pattern for all ASCII printables but space and double quote
set NODQSP=!#-/0-9:-@[-`a-z{-~
:: pattern for all ASCII printables but double quote
set NODQ= %NODQSP%
:: pattern for double quote, by excluding everything else
set DQ=^^^%NODQ%

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
:: echo LVL "%LVL%"
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

:: validate argument 2 is double-quoted to avert scripting attacks
set MSG=%2
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
set MSG=%MSG:<=^<%

:: validate argument 3 is unquoted and without spaces to avert scripting attacks
set SRC=%3
if not defined SRC goto :post_source
:: - SRC must:
::   - not begin or end with double quotes
::   - have no internal double quotes
:: - regular expressions containing double quotes must escape certain
::   characters in the unquoted sections with hats:
::     - NODQSP matches every printable ASCII character but space and double quote
:: set SRC | findstr /r /c:"^SRC="| findstr /r /c:"^SRC=[%NODQSP%]*$"
call "%~dp0\log4cmd_validate.cmd" SRC RXNQNS

if %ERRORLEVEL% neq 0 (
  echo SRC "%SRC%"
  echo  ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! >&2
  echo %NX0%: bad third argument [log_source] 1>&2
  echo %NX0% was invoked with the following arguments: >&2
  goto :usage
)

:post_source

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
