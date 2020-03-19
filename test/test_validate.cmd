@echo off
set ERRORLEVEL=

REM keep environment variables temporary
setlocal

REM change to directory containing this script
pushd "%~dp0"
set NX0=%~nx0
set LAST_FAILURE=0
set LOG4CMD_SOURCE=test_validate_cmd

REM set environment values for testing
call envars_for_test.cmd
%LOG4CMD_INSTALL%

%LOG_NONE% "Start %NX0% ----------" %LOG4CMD_SOURCE%

REM set unique paths if desired e.g.:
:: %NEW_LOG% MY_METADATA_LOG %LOG4CMD_SOURCE% metadata
:: %LOG_NONE% "Metadata log - %MY_METADATA_LOG%" %LOG4CMD_SOURCE% >> test_results.txt

set ARGS=call ..\log4cmd_validate.cmd
call :expect_failure

set ARGS=call ..\log4cmd_validate.cmd MYRESULT RXDQNQ "validate three-argument RXDQNQ case"
call :skip_or_run

set ARGS=call ..\log4cmd_validate.cmd MYRESULT RXDQNQ "validate internal hat^ RXDQNQ case"
call :skip_or_run

set ARGS=call ..\log4cmd_validate.cmd MYRESULT RXDQNQ
call :skip_or_run

set ARGS=call ..\log4cmd_validate.cmd MYRESULT RXNQNS "RXNQNS fails validation against RXDQNQ expression"
call :expect_failure

set ARGS=call ..\log4cmd_validate.cmd MYRESULT RXNQNS three_argument_RXNQNS_case
call :skip_or_run

set ARGS=call ..\log4cmd_validate.cmd MYRESULT RXNQNS
call :skip_or_run

set ARGS=call ..\log4cmd_validate.cmd MYRESULT RXDQNQ RXNQNS_value_fails_valdation_against_RXDQNQ_expression
call :expect_failure

set ARGS=call ..\log4cmd_validate.cmd MYRESULT RXDQ   "pass RXDQ having "internal" quote"
call :skip_or_run

set ARGS=call ..\log4cmd_validate.cmd MYRESULT RXDQNQ "fail RXDQNQ because of"internal"quote"
call :expect_failure

set ARGS=call ..\log4cmd_validate.cmd MYRESULT RXNQNS fail_RXNQNS_because_of"internal_quote
call :expect_failure

%LOG_NONE% "---------- Finished %NX0%" %LOG4CMD_SOURCE%

popd

if %LAST_FAILURE% neq 0 echo %NX0%: Aborted because the last test run failed with exit code %LAST_FAILURE% >> test_results.txt
exit /b %LAST_FAILURE%

REM Subroutines definitions follow

:expect_failure

  set EXPECT_FAILURE=TRUE
  if %LAST_FAILURE% neq 0 (
    call :skip_test
  ) else (
    call :run_test
  )
  if %TEST_RESULT% equ 0 set LAST_FAILURE=-1
  set EXPECT_FAILURE=
  goto :eof

:skip_or_run

  if %LAST_FAILURE% neq 0 (
    call :skip_test
  ) else (
    call :run_test
  )
  if %TEST_RESULT% neq 0 set LAST_FAILURE=%TEST_RESULT%
  goto :eof

:skip_test

  %LOG_SKIP% "%ARGS:"='%" %LOG4CMD_SOURCE% >> test_results.txt
  echo ===================== 1>&2
  echo %DATE% %TIME% SKIP %ARGS% 1>&2
  echo ---------- SKIP ----------- 1>&2
  goto :eof

:run_test

  echo ===================== 1>&2
  echo =====================
  echo TEST "%ARGS%" 1>&2
  echo TEST "%ARGS%"
  %LOG_NONE% "%ARGS:"='%" %LOG4CMD_SOURCE% >> test_results.txt

  :: run the test
  echo %ARGS%
  %ARGS%
  :: capture and report result
  set TEST_RESULT=%ERRORLEVEL%

  if %TEST_RESULT% equ 0 goto :run_pass
    if not defined EXPECT_FAILURE %LOG_FAIL% "%ARGS:"='%" %LOG4CMD_SOURCE% >> test_results.txt
    if     defined EXPECT_FAILURE %LOG_PASS% "%ARGS:"='%" %LOG4CMD_SOURCE% >> test_results.txt
    if not defined EXPECT_FAILURE echo ---------- FAIL ----------- 1>&2
    if     defined EXPECT_FAILURE echo ---------- PASS ----------- 1>&2
    goto :eof

:run_pass
  if not defined EXPECT_FAILURE %LOG_PASS% "%ARGS:"='%" %LOG4CMD_SOURCE% >> test_results.txt
  if     defined EXPECT_FAILURE %LOG_FAIL% "%ARGS:"='%" %LOG4CMD_SOURCE% >> test_results.txt
  if not defined EXPECT_FAILURE echo ---------- PASS ----------- 1>&2
  if     defined EXPECT_FAILURE echo ---------- FAIL ----------- 1>&2
REM vim: sw=2 ts=3 et ai ff=dos :
