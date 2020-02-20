@echo off
pushd "%~dp0"

:: demonstrate invocation directly from the command line
cscript //nologo log4vbs.vbs /lvl:fatal /msg:"Greetings, Terra"
cscript //nologo log4vbs.vbs /lvl:error /msg:"Greetings, Terra"
cscript //nologo log4vbs.vbs /lvl:warn  /msg:"Greetings, Terra"
cscript //nologo log4vbs.vbs /lvl:info  /msg:"Greetings, Terra"
cscript //nologo log4vbs.vbs /lvl:debug /msg:"Greetings, Terra"

:: demonstrate invocation via inclusion in another VBScript
cscript //nologo demo_log4vbs.vbs

popd
