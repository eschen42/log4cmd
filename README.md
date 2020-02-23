# log4cmd - a configurable log proxy for the windows command line

This is a configurable command-line logger written in VBScript.

It can be invoked directly from the Windows command line or included in another VBScript program.

## Usage

```
cscript //nologo log4vbs.vbs /lvl:{debug:info|warn|error|fatal|none|pass|fail|skip} /msg:your-message-in-double-quotes [/src:override-configured-source]
log4cmd_newlog.cmd variableName sourceName logName
```

## How to use - quick start

### TL;DR;

```
:: Set up registry keys and create directory where log files will be written.
install_example.cmd
:: Write some log messages.
demo_log4cmd.cmd
:: Create mySourceName subdirectory in log directory and generate a path for a
::   uniquely named file in that directory, but do not create that file yet.
log4cmd_newlog.cmd MY_LOGNAME_LOG mySourceName myLogName
```

### Defaults

By default:

- the `log4cmd` value under the `HKCU\Environment` specifies the root directory used for logging by `log4cmd`;
- that value specifies `%USERPROFILE%\AppData\Local\log4cmd` as the logging root;
- the "log source" is named `log4vbs`.
- log messages will be written to %USERPROFILE%\AppData\Local\log4cmd\log4vbs-CCYY-MM-DD.log
  - where CCYY is the current year, MM is the current month, and DD is the current day, in the UTC time zone.

### Demonstration

To see `log4cmd` in action, assuming that the default settings seem acceptable to you:

- Run `install_example.cmd`.
- Run `demo_log4cmd.cmd` to demonstrate invocation of `log4vbs.vbs` directly from the command line.
- Run `demo_log4vbs.vbs` to demonstrate invocation of `log4vbs.vbs` from VBScript by inclusion.
  - This is in fact run from `demo_log4cmd.cmd` as well.
- Run `log4cmd_newlog.cmd` to create a unique path for a general purpose `supplementary` log file.
  - Each supplementary log for a give source is written to a subdirectory named after that source, created in the logging root directory.
  - usage: `log4cmd_newlog.cmd MY_LOGNAME_LOG mySourceName myLogName`
    - This creates the `mySourceName` subdirectory under the `log4cmd` logging directory root and assigns to the `MY_LOGNAME_LOG` environment variable a unique path that can be used to log any text in any fashion that you require. 
    - This does not in fact create the log file, though it does create a subdirectory for it if it does not already exist.

### Customization

- If you want to customize the registry key used to locate where log files will be written, or to customize that location, copy `log4cmd_regkey_example.cmd` to `log4cmd_regkey.cmd` and make the desired changes there.
- If you want to configure the logging behavior itself, copy `log4vbs_config_example.vbs` to `log4vbs_config.vbs` and make the desired changes there:
  - You can modify `strLog4cmdKey` to match any change made to the location in `log4cmd_regkey.cmd`.
  - You can modify `logSource` to change the default "log source".
    - A *Source* might be a program or suite of closely related programs.
    - All messages logged by `log4vbs.vbs` specify a source, even if this is only implicitly through the configured default.
    - The source name is prepended to each day's log in the logging root directory.
  - You can modify the `Select Case` statement in the `Loggers` function to add or remove loggers.
  - You can modify `logLevelFilter` to remove log levels that you wish to suppress from logging.
- If you don't like the behavior of `install_example.cmd` you can copy it to `install.cmd` and adjust it accordingly.


### Loggers

Presently there are two loggers:

- log to standard output
- log to a file in the designated log directory.

### Log-level Filtering

The log levels that will be accepted for logging (i.e., not silently ignored) may be assigned to the `logLevelFilter` in `log4vbs_config.vbs`.

### Security

A hallmark of secure logging is that logs be written where they cannot be modified or erased.  If you have a need for secure logging, you could create a logger to interact with such a logging facility.  The file logger included here is **not** intended to meet any security requirements.

The Windows Event Log is set up to achieve such non-redactability to a great degree, for unpriviliged users at least; however, an unprivileged user can only write to the *Application Log* "event source" unless an administrator creates an application-specific event source, so it may be too much of a jumble to be worthwhile.  If you want to do this, you might find what you need to get started at [https://ss64.com/vb/logevent.html](https://ss64.com/vb/logevent.html).
