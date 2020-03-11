@echo off
:: add log level and pass control to log_level_async.cmd [does not return]
"%~dp0\log_level_async.cmd" fatal %*
