set LAST_FAILURE=0

REM turn on logging with log4cmd
set LOG4CMD_INSTALL=echo yes ^| call "%~dp0\..\install_example.cmd"
set LOG4CMD_REMOVE= echo yes ^| call "%~dp0\..\install_example.cmd" remove

set LOG_NONE=call "%~dp0\..\log_none.cmd"
set LOG_SKIP=call "%~dp0\..\log_skip.cmd"
set LOG_PASS=call "%~dp0\..\log_pass.cmd"
set LOG_FAIL=call "%~dp0\..\log_fail.cmd"
set NEW_LOG=call  "%~dp0\..\log4cmd_newlog.cmd"

REM vim: sw=2 ts=3 et ai ff=dos :
