@echo off
if not [%2] == [] cscript //nologo "%~dp0\log4vbs.vbs" /lvl:info /msg:%1 /src:%2
if     [%2] == [] cscript //nologo "%~dp0\log4vbs.vbs" /lvl:info /msg:%1
