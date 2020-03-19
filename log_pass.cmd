@setlocal
@set USAGE=%~nx0 "message in double quotes" log_source
@cmd /c ^"echo off^&"%~dp0\log_level_async.cmd" pass %*^"
