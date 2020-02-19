@echo off
setlocal
set MY_LOG4CMD_VALUE=%USERPROFILE%\AppData\Local\log4cmd
if not exist %MY_LOG4CMD_VALUE% mkdir %MY_LOG4CMD_VALUE%
set MY_LOG4CMD_VALUE=%%USERPROFILE%%\AppData\Local\log4cmd

echo Installing registry value log4cmd under key "HKCU\Environment"
pause
reg add   "HKCU\Environment" /f /t REG_EXPAND_SZ /d %MY_LOG4CMD_VALUE% /v log4cmd
reg query "HKCU\Environment" /v log4cmd
