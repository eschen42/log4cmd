@echo off
pushd "%~dp0"

:: demonstrate invocation directly from the command line
cscript //nologo log4vbs.vbs /lvl:info /msg:"Greetings, Terra"

:: demonstrate invocation via inclusion in another VBScript
cscript //nologo demo_log4vbs.vbs

popd
