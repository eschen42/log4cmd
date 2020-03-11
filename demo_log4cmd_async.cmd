@echo off
setlocal
pushd "%~dp0"

set CALL_LOG4VBS=cscript //nologo log4vbs.vbs

set LOG4CMD_ASYNC=TRUE
:: demonstrate asynchronous logging by convenience scripts
call log_info.cmd  "1.1 hello async info"
call log_debug.cmd "1.2 hello async debug"
call log_error.cmd "1.3 hello async error"
call log_info.cmd  "1.4 byebye async info"
call log_debug.cmd "1.5 byebye async debug"
call log_error.cmd "1.6 byebye async error"
set LOG4CMD_ASYNC=

:: demonstrate invocation directly from the command line
%CALL_LOG4VBS% /lvl:fatal /msg:"A. Greetings, Terra"
set LOG4CMD_ASYNC=TRUE
call log_info.cmd  "2.1 hello async info"
set LOG4CMD_ASYNC=
%CALL_LOG4VBS% /lvl:error /msg:"B. Greetings, Terra"
%CALL_LOG4VBS% /lvl:warn  /msg:"C. Greetings, Terra"
set LOG4CMD_ASYNC=TRUE
call log_debug.cmd "2.2 hello async debug"
call log_error.cmd "2.3 hello async error"
set LOG4CMD_ASYNC=
%CALL_LOG4VBS% /lvl:info  /msg:"D. Greetings, Terra"
%CALL_LOG4VBS% /lvl:debug /msg:"E. Greetings, Terra"

:: demonstrate invocation via inclusion in another VBScript
cscript //nologo demo_log4vbs.vbs

set LOG4CMD_ASYNC=TRUE
call log_info.cmd  "2.4 byebye async info"
set LOG4CMD_ASYNC=

:: demonstrate synchronous logging by convenience scripts
call log_info.cmd "X. hello sync info"
call log_error.cmd "Y. hello sync error"
set LOG4CMD_ASYNC=TRUE
call log_debug.cmd "2.5 byebye async debug"
call log_error.cmd "2.6 byebye async error"
set LOG4CMD_ASYNC=

call log_debug.cmd "Z. hello sync debug"

popd
endlocal
