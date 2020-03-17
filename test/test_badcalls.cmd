@echo off
set ERRORLEVEL=

REM keep environment variables temporary
setlocal

REM change to directory containing this script
pushd "%~dp0"
set NX0=%~nx0
set LAST_FAILURE=0
set LOG4CMD_SOURCE=test_validate_cmd
set LOG4CMD_VALIDATE_LVL_MSG_SRC=TRUE

REM set environment values for testing
call envars_for_test.cmd
%LOG4CMD_INSTALL%

set EXPECT_FAILURE=

%LOG_NONE% "Start %NX0% ----------" %LOG4CMD_SOURCE%

REM set unique paths if desired e.g.:
:: %NEW_LOG% MY_METADATA_LOG %LOG4CMD_SOURCE% metadata
:: %LOG_NONE% "Metadata log - %MY_METADATA_LOG%" %LOG4CMD_SOURCE% >> test_results.txt

:: This passes because angle brackets, ampersands, pipes, and hats are escaped below
:: Put the following into test_file.txt
::   YOU ARE IN a ^ little maze of < twisty & passages | all > different
echo YOU ARE IN a ^^ little maze of ^< twisty ^& passages ^| all ^> different> test_file.txt
:: Then read it and insert it into ARGS
for /f "delims=" %%L in (test_file.txt) do set ARGS=call ..\log_level_async.cmd  pass "%%L" test
:: escape less than
set ARGS=%ARGS:<=^<%
:: escape greater than
set ARGS=%ARGS:>=^>%
:: escape ampersand
set ARGS=%ARGS:&=^&%
:: escape pipe
set ARGS=%ARGS:|=^|%
call :skip_or_run
del test_file.txt

:: these fail because log level is in quotation marks
set ARGS=call ..\log_level_async.cmd "FAIL" "you are in a maze of little twisty passages all alike"
call :expect_failure
set ARGS=call ..\log_level_async.cmd "FAIL" "you are in a maze of little twisty passages all alike"         "test"
call :expect_failure

:: this passes because quotation marks are removed from log level
set ARGS=call ..\log_level_async.cmd  pass  "you are in a little maze of twisty passages all different"
call :skip_or_run

:: these fail because log source is in quotation marks
set ARGS=call ..\log_level_async.cmd  FAIL  "you are in a maze of little twisty passages all alike"         "test"
call :expect_failure

:: this passes because quotation marks are removed from log source
set ARGS=call ..\log_level_async.cmd  pass  "you are in a maze of twisty little passages all different"      test
call :skip_or_run

:: these fail because the message is not in double quotes
set ARGS=call ..\log_level_async.cmd  FAIL  you^ are^ in^ a^ maze^ of^ little^ twisty^ passages^ all^ alike  test
call :expect_failure
set ARGS=call ..\log_FAIL.cmd               you_are_in_a_maze_of_little_twisty_passages_all_alike            test
call :expect_failure

:: this passes because the message is in double quotes
set ARGS=call ..\log_pass.cmd               "you are in a twisty maze of little passages all different"      test
call :skip_or_run

:: this fails because of internal double quotes
set ARGS=call ..\log_FAIL.cmd               "you_are_in_"a_maze_of_little twisty_passages"_all_alike"        test
call :expect_failure

:: this passes because the message has no internal double quotes
set ARGS=call ..\log_pass.cmd               "you are in a twisty little maze of passages all different"      test
call :skip_or_run

set ARGS=call ..\log_FAIL.cmd               you_are_in_"a_maze_of_little ^| twisty_passages"_all_alike       test
call :expect_failure
set ARGS=call ..\log_FAIL.cmd               "you_are_in_"a_maze_of_little twisty_passages"_all_alike"        test
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
    :: TEST_RESULT is not zero:
    if not defined EXPECT_FAILURE %LOG_FAIL% "Error unexpected non-failure: %ARGS:"='%" %LOG4CMD_SOURCE% >> test_results.txt
    if     defined EXPECT_FAILURE %LOG_PASS% "Failure by design: %ARGS:"='%" %LOG4CMD_SOURCE% >> test_results.txt
    if not defined EXPECT_FAILURE echo ---------- FAIL %TEST_RESULT% ----------- 1>&2
    if     defined EXPECT_FAILURE echo ---------- PASS %TEST_RESULT% ----------- 1>&2
    goto :eof

:run_pass
  if not defined EXPECT_FAILURE %LOG_PASS% "%ARGS:"='%" %LOG4CMD_SOURCE% >> test_results.txt
  if     defined EXPECT_FAILURE %LOG_FAIL% "%ARGS:"='%" %LOG4CMD_SOURCE% >> test_results.txt
  if not defined EXPECT_FAILURE echo ---------- PASS ----------- 1>&2
  if     defined EXPECT_FAILURE echo ---------- FAIL ----------- 1>&2
REM vim: sw=2 ts=3 et ai ff=dos :
