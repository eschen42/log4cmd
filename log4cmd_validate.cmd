@set ERRORLEVEL=&setlocal&echo off
set TRACE=
if defined TRACE echo -------------------------------------- 1>&2
if defined TRACE echo running %~nx0 %* 1>&2
if defined TRACE echo arg1: '%1' 1>&2
if defined TRACE set %1 1>&2
if defined TRACE echo arg2: '%2' 1>&2
if defined TRACE echo arg3: '%3' 1>&2

:: Validate input - takes two trusted arguments:
:: - Arg 1
::   - the name of an environment variable holding the value to be validated
::     unless Arg 3 is supplied, in which case it will be assigned to Arg 1
::     only if it can be validated
:: - Arg 2
::   - the name of the envar with a regular expression 
::     to validate the value of the envar named by Arg 1
::   - permitted values:
::     - RXDQNQ: ends in double quotes with no internal double quotes
::       - Equivalent RegEx: ^[\"][^^\"]*[^^\"][\"]$
::     - RXNQNS: no double quotes and no internal spaces
::       - Equivalent RegEx: ^[!#$%&'()*+,./0-9:;<=>?@A-Z\[\\\]_`a-z{|}~^-]*$
:: - Arg 3 [optional]
::   - an argument to be validated; if validated, it is assigned to the 
::     variable named by argument 1.  Use this to validate %# arguments.
:: - Arg 4 [forbidden]
::   - a fourth argument, if supplied, will trigger a usage error
::
:: For examples, see `.\test\test_validate.cmd`.

call :validator_check_init

:: check for too many arguments
set FORBIDDEN=%4
if defined FORBIDDEN goto :usage
:: check for too few arguments
set VALIDATOR=%2
if not defined VALIDATOR goto :usage
:: get remaining required argument
set TARGET=%1
:: get optional argument
set UNVALIDATED=%3

:: refuse to assign result to one of the regex variables set by :validator_check_init
call :validator_check TARGET
if %ERRORLEVEL% equ 0 goto :usage

:: refuse to use a regex variable not set by :validator_check_init
call :validator_check VALIDATOR
if %ERRORLEVEL% neq 0 goto :usage

:: if optional argument not supplied, assign the default
if not defined UNVALIDATED call :assign "UNVALIDATED" "%TARGET%"

:: Assign to DEREF an expression that will echo the name assigned to VALIDATOR
for /f "delims=" %%V in ('echo %VALIDATOR%') do @(set DEREF=echo "%%%%V%%")

:: At this point, if VALIDATOR is assigned "MSG", DEREF is assigned the value "echo %MSG%"
for /f "delims=" %%V in ('%DEREF%') do @set DEREF=%%V

:: At this point, if VALIDATOR is assigned "MSG", DEREF is assigned the result of "echo %MSG%"
set UNVALIDATED| findstr /r /c:"^UNVALIDATED="| findstr /r /c:"^UNVALIDATED=%DEREF:~1,-1%" >NUL && (endlocal && set %TARGET%=%UNVALIDATED%&& exit /b 0)

:: These statements will be reached only when validation fails
set RESULT_ERROR=%ERRORLEVEL%
echo %~nx0 %* 1>&2
echo "Not valid or FINDSTR failed with error %ERRORLEVEL% - execute without options for help." 1>&2
exit /b 87


:validator_check_init
  :: Note well: Each of these strings is the TAIL of a regex;
  :: - the head of which will be ^UNVALIDATED=
  set RXDQNQ=[\"][^^^^^^^^\"]*[^^\"][\"]$
  set RXNQNS=[^&^<^>^|^^0-9!#$%'()*+,./:;=?@A-Z\[\\\]_`a-z{}~-]*$
  goto :eof

:validator_check
  :: Arg - name of validator environment variable to check
  (set %1>NUL) || (
    echo :validator_check - variable %1 not defined 1>&2
    exit /b 1
  )
  set %1| findstr /i /r /c:"^%1=RXDQNQ$" /c:"^%1=RXNQNS$" /c:"^%1=MYDQ$" >NUL
  exit /b %ERRORLEVEL%

:usage
  @echo off
  echo %~nx0 1>&2
  echo - either validates a previously assigned environment variable 1>&2
  echo - or validates a value before assigning it to an environment variable. 1>&2
  if defined TARGET      echo ^  arg1            :%1: 1>&2
  if defined VALIDATOR   echo ^  arg2            :%2: 1>&2
  if defined UNVALIDATED echo ^  arg3  [optional]:%3: 1>&2
  if defined FORBIDDEN   echo ^  arg4 [forbidden]:%4: 1>&2
  echo Usage: %~nx0 ^<result^> {RXDQNQ,RXNQNS} [value] 1>&2
  echo ^  If arg3 [value] is supplied it will be assigned to arg1 [result]  1>&2
  echo ^     if and only if it passes validation against the validator 1>&2
  echo ^     pattern named by arg2 1>&2
  echo ^  If arg3 [value] is not supplied the value of arg1 will be 1>&2
  echo ^      validated against the validator pattern named by arg2 1>&2
  echo ^  RXDQNQ requires that the validand have double quotes at and only 1>&2
  echo ^    at the first and last character. 1>&2
  echo ^  RXNQNS requires that the validand have no double quotes or spaces. 1>&2
  echo ^  Exit code is zero on success, nonzero otherwise. 1>&2
  exit /b 87

:assign
  :: arguments are double quoted
  :: echo :assign arg1: %1
  :: echo :assign arg2: %2

  set LVALUE=%1
  set LVALUE=%LVALUE:~1,-1%
  set RVALUE=%2
  set RVALUE="echo %%%RVALUE:~1,-1%%%"
  :: set %LVALUE%
  :: echo set %LVALUE% ^| findstr "%LVALUE%="
  :: set %LVALUE% | findstr "%LVALUE%="
  for /f "delims=" %%R in ('
    %RVALUE:~1,-1%^&
  ') do (set %LVALUE%=%%R)&exit /b 0
  echo %~nx0 :assign failed [ERRORLEVEL %ERRORLEVEL%] for args: "%*" 1>&2
  exit /b 87
