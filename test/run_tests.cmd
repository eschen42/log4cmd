@echo off
:: Keep environment variables temporary
setlocal
:: Tracing variables
set ECHO_OFF=off
set ECHO_ON=off

:: set up logger
set LOG4CMD_SOURCE=log4cmdtests

REM set environment values for testing
call "%~dp0\envars_for_test.cmd"
%LOG4CMD_INSTALL%

:: change to directory containing this script
pushd %~dp0
:: set SED_EXE="%~dp0\..\bin\sed.exe"

REM Read the options
set VERBOSE=
set ARGS=
@echo %ECHO_ON%
:arg_loop
  shift
  if /i "%0" == "/verbose" (
    REM set VERBOSE=TRUE
    goto :arg_loop
  )
REM %* is not affected by shift, so use it to handle the
REM   case where the command line switches were provided
REM   at the end of the line.
echo %* | findstr "[/]verbose" >NUL && set VERBOSE=TRUE

REM TODO support more than one argument naming tests
REM if not "%0" == "" (
REM   set ARGS=%ARGS% %0
REM   goto :arg_loop
REM )

:: Set defaults that are not set in environment
if /i [%VERBOSE%] == [] set VERBOSE=FALSE
@echo %ECHO_OFF%

if exist test_results.txt     del test_results.txt
if exist test_stdout.txt      del test_stdout.txt
if exist test_stdout_one.txt  del test_stdout_one.txt
if exist test_stderr.txt      del test_stderr.txt
if exist test_stderr_one.txt  del test_stderr_one.txt

set MY_ERRORLEVEL=0
for /f %%F in ('dir /b/a-d test_*%0.cmd') do if %MY_ERRORLEVEL% equ 0 call :my_invoke %%F
goto :report

:my_invoke

  set my_cmd=%1

  if /i "%my_cmd:~-4,4%" == ".cmd" echo %DATE% %TIME% ____ run %my_cmd%
  if /i "%my_cmd:~-4,4%" == ".cmd" echo %DATE% %TIME% ____ run %my_cmd% >> test_results.txt
  if /i "%my_cmd:~-4,4%" == ".cmd" cmd /c %my_cmd% >> test_stdout_one.txt 2> test_stderr_one.txt
  if /i "%my_cmd:~-4,4%" == ".cmd" echo %DATE% %TIME%      end %my_cmd% ____ >> test_results.txt
  if /i "%my_cmd:~-4,4%" == ".cmd" echo %DATE% %TIME%      end %my_cmd% ____

  set MY_ERRORLEVEL=%ERRORLEVEL%

  if exist test_stderr_one.txt if %MY_ERRORLEVEL% neq 0 if /i [%VERBOSE%] == [TRUE] (
      echo Standard error
      type test_stderr_one.txt
  )
  if exist test_stderr_one.txt (
    type test_stderr_one.txt >> test_stderr.txt
    del test_stderr_one.txt
  )
  if exist test_stdout_one.txt if %MY_ERRORLEVEL% neq 0 if /i [%VERBOSE%] == [TRUE] (
      echo Standard output
      type test_stdout_one.txt
  )
  if exist test_stdout_one.txt (
    type test_stdout_one.txt >> test_stdout.txt
    del test_stdout_one.txt
  )

  exit /b %MY_ERRORLEVEL%

:report

echo --------------------- 1>&2
echo Note that all tests are run from the directory %CD% 1>&2
echo --------------------- 1>&2

echo %ECHO_ON%

if exist test_results.txt %NEW_LOG% MY_RESULT_LOG %LOG4CMD_SOURCE% test_results
if exist test_results.txt (
  type test_results.txt > "%MY_RESULT_LOG%"
  %LOG_NONE% "Copied test_results.txt to %MY_RESULT_LOG%" %LOG4CMD_SOURCE%
  type test_results.txt 1>&2
) else (
  echo test_results.txt not found 1>&2
)
if exist test_stdout.txt  %NEW_LOG% MY_STDOUT_LOG %LOG4CMD_SOURCE% test_stdout >NUL
if exist test_stdout.txt  type test_stdout.txt > "%MY_STDOUT_LOG%"
if exist test_stderr.txt  %NEW_LOG% MY_STDERR_LOG %LOG4CMD_SOURCE% test_stderr >NUL
if exist test_stderr.txt  type test_stderr.txt > "%MY_STDERR_LOG%"
echo --------------------- 1>&2
if /i not [%VERBOSE%] == [TRUE] if %MY_ERRORLEVEL% neq 0 echo Standard output and error for failing tests may be obtained using the '/verbose' switch or by setting VERBOSE environment variable to TRUE 1>&2

if not ["%MY_RESULT_LOG%"] == [] echo Test results          : "%MY_RESULT_LOG%"
if not ["%MY_STDOUT_LOG%"] == [] echo Test "standard output": "%MY_STDOUT_LOG%"
if not ["%MY_STDERR_LOG%"] == [] echo Test "standard error" : "%MY_STDERR_LOG%"

popd

REM vim: sw=2 ts=3 et ai ff=dos :
