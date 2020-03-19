@echo off
set USAGE=%~nx0 "message in double quotes" log_source
:: add log level and pass control to log_level_async.cmd [does not return]
"%~dp0\log_level_async.cmd" error %*
