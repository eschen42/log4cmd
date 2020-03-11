@echo off
setlocal
pushd "%~dp0"

set CALL_LOG4VBS=cscript //nologo log4vbs.vbs


:: demonstrate invocation directly from the command line
%CALL_LOG4VBS% /lvl:fatal /msg:"A. Greetings, Terra"
%CALL_LOG4VBS% /lvl:error /msg:"B. Greetings, Terra"
%CALL_LOG4VBS% /lvl:warn  /msg:"C. Greetings, Terra"
%CALL_LOG4VBS% /lvl:info  /msg:"D. Greetings, Terra"
%CALL_LOG4VBS% /lvl:debug /msg:"E. Greetings, Terra"

:: demonstrate invocation via inclusion in another VBScript
cscript //nologo demo_log4vbs.vbs


:: demonstrate synchronous logging by convenience scripts
call log_info.cmd "X. hello sync info"
call log_error.cmd "Y. hello sync error"

call log_debug.cmd "Z. hello sync debug"

popd
endlocal
