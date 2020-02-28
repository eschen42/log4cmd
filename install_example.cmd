@set ERRORLEVEL=&setlocal&echo off
set MY_RESULT=0

if /I "%1" == "help" goto :usage
if /I "%1" == "--help" goto :usage
if /I "%1" == "-h" goto :usage
if /I "%1" == "-?" goto :usage
if /I "%1" == "/?" goto :usage
if /I "%1" == "-?" goto :usage

if exist "%~dp0\log4cmd_regkey.cmd" call "%~dp0\log4cmd_regkey.cmd"
if "%LOG4CMD_REGKEYVAL%" == "" call "%~dp0\log4cmd_regkey_example.cmd"
set | findstr "LOG4CMD_"
if /I "%1" == "remove" goto :remove

reg query "%LOG4CMD_REGKEY%" /v "%LOG4CMD_REGVAL%" >NUL 2>&1 && (
  if not exist "%LOG4CMD_ROOT_EX%" echo Attempting to create directory %LOG4CMD_ROOT_EX%
  if not exist "%LOG4CMD_ROOT_EX%" mkdir "%LOG4CMD_ROOT_EX%"
  endlocal&set LOG4CMD_ROOT=%LOG4CMD_ROOT_EX%&exit /b %MY_RESULT%
) 
echo Set registry value "%LOG4CMD_REGVAL%" under key "%LOG4CMD_REGKEY%" to "%LOG4CMD_ROOT_IN%"?
if not exist "%LOG4CMD_ROOT_EX%" echo Create directory "%LOG4CMD_ROOT_IN%"?
echo If you do not wish to proceeed, press control-C and then type Y to terminate this script.
:: pause to get confirmation before proceeding
pause
reg add   "%LOG4CMD_REGKEY%" /f /t REG_EXPAND_SZ /d "%LOG4CMD_ROOT_IN%" /v "%LOG4CMD_REGVAL%"
if not exist "%LOG4CMD_ROOT_EX%" reg query "%LOG4CMD_REGKEY%" /v "%LOG4CMD_REGVAL%" && (
  if not exist "%LOG4CMD_ROOT_EX%" echo Attempting to create directory %LOG4CMD_ROOT_EX%
  if not exist "%LOG4CMD_ROOT_EX%" mkdir "%LOG4CMD_ROOT_EX%"
)
endlocal&set LOG4CMD_ROOT=%LOG4CMD_ROOT_EX%&exit /b %MY_RESULT%

:remove

reg query "%LOG4CMD_REGKEY%" /v "%LOG4CMD_REGVAL%" >NUL 2>&1 && (
  echo Deleting registry value "%LOG4CMD_REGVAL%" under key "%LOG4CMD_REGKEY%"
  :: reg delete will prompt before acting, so no need for confirmation before proceeding
  reg delete "%LOG4CMD_REGKEY%" /v "%LOG4CMD_REGVAL%"
)
endlocal&set LOG4CMD_ROOT=&exit /b %MY_RESULT%

:usage

echo . To install registry value for LOG4CMD: %0
echo . To remove  registry value for LOG4CMD: %0 remove
echo . To configure which values in the registry are used:
echo .   copy log4cmd_regkey_example.cmd to log4cmd_regkey.cmd
echo .   and customize the latter before running %0

endlocal&exit /b -1
