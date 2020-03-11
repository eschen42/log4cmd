@echo off
:: example:
::   log_level_async debug "this is only a test" my_debug
:: argument 1 must be the log level and must be unquoted
:: argument 2 must be the message, wrapped in double quotes
::            [single quotes will work but are not recommended.]
:: argument 3 must be the log source and must have neither double quotes nor spaces
setlocal
:: capture arg 1
set LVL=%1
:: validate argument 1 to avert scripting attacks
set LVL | findstr /i "LVL=debug LVL=error LVL=fail LVL=fatal LVL=info LVL=none LVL=noop LVL=pass LVL=skip LVL=warn" >NUL || (
  echo %~nx0: bad first argument [level] 1>&2
  goto :usage
)
:: after shift, arg 2 and 3 become respectively arg 1 and 2
shift
:: validate argument 2 to avert scripting attacks
:: ensure that message has no double quote characters
set MSG=..%1..
set MSG=%MSG:"='%
set PERIM=%MSG:~0,3%%MSG:~-3,3%
if not ..''.. == %MSG:~0,3%%MSG:~-3,3% (
  echo %~nx0: bad second argument [message] 1>&2
  goto :usage
)
set MSG="%MSG:~3,-3%"

:: validate argument 3 to avert scripting attacks
set SOURCE=..%2..
set SOURCE=%SOURCE: =_%
set SOURCE=%SOURCE:"='%
if ..''.. == %SOURCE:~0,3%%SOURCE:~-3,3% (
  echo %~nx0: bad third argument [log_source] 1>&2
  goto :usage
)
set SOURCE | findstr /r /c:"^SOURCE=[.][.][.][.]$" >NUL && (
  set SOURCE=
  goto :default_source
)
set SOURCE=%SOURCE:~2,-2%
set SOURCE | findstr /r /c:"^SOURCE=[a-zA-Z_][a-zA-Z_]*$" >NUL || (
  echo %~nx0: bad third argument [log_source] 1>&2
  goto :usage
)

:default_source

if defined LOG4CMD_ASYNC (
  set CLEAN_CMD=start /b /i /d "%CD%" "%windir%\explorer.exe" "%windir%\system32\cmd.exe" /c
) else (
  set CLEAN_CMD="%windir%\system32\cmd.exe" /c
)
if not [%SOURCE%] == [] set LOG_CMD=cscript //nologo "%~dp0\log4vbs.vbs" /lvl:%LVL% /msg:%1 /src:%SOURCE%
if     [%SOURCE%] == [] set LOG_CMD=cscript //nologo "%~dp0\log4vbs.vbs" /lvl:%LVL% /msg:%MSG%
%CLEAN_CMD% ^"%LOG_CMD%^"
exit /b 0

:usage

echo usage: %~nx0 level "message in double quotes" log_source 1>&2
echo ^ ^ Argument 1 [level] should be unquoted and be one of: 1>&2
echo ^ ^ ^ ^ debug info warn error fatal pass fail skip noop none 1>&2
echo ^ ^ Argument 2 [message] must be double-quoted 1>&2
echo ^ ^ Argument 3 [log_source] must NOT be double-quoted 1>&2

exit /b -1
