@echo off
setlocal
set MY_LOG4CMD_ROOT_EX=%USERPROFILE%\AppData\Local\log4cmd
set MY_LOG4CMD_ROOT=%%USERPROFILE%%\AppData\Local\log4cmd

call "%~dp0\log4cmd_regkey.cmd"

if     exist "%MY_LOG4CMD_ROOT_EX%" echo Found directory %MY_LOG4CMD_ROOT_EX%
if not exist "%MY_LOG4CMD_ROOT_EX%" echo Attempting to create directory %MY_LOG4CMD_ROOT_EX%
echo Installing registry value "%LOG4CMD_REGVAL%" under key "%LOG4CMD_REGKEY%"
pause
if not exist "%MY_LOG4CMD_ROOT_EX%" mkdir "%MY_LOG4CMD_ROOT_EX%"
reg add   "%LOG4CMD_REGKEY%" /f /t REG_EXPAND_SZ /d %MY_LOG4CMD_ROOT% /v "%LOG4CMD_REGVAL%"
reg query "%LOG4CMD_REGKEY%" /v "%LOG4CMD_REGVAL%"

endlocal
