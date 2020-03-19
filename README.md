# log4cmd - a configurable log proxy for the windows command line

This is a configurable command-line logger for Windows, written in VBScript.

It can be invoked directly from the Windows command line or included in a VBScript program.

It can be configured to send the same message to each of several ["loggers"](#loggers), subject to ["log-level filtering"](#log-level-filtering).

## Usage

### Direct invocation

To log a message, you can invoke `log4vbs.vbs` directly:
```
cscript //nologo log4vbs.vbs /lvl:{debug|info|warn|error|fatal|none|pass|fail|skip} /msg:your-message-in-double-quotes [/src:override-default-configured-source]
```
e.g.:
```
cscript //nologo log4vbs.vbs /lvl:info /msg:"This is only a test."
```

- The `lvl` and `msg` arguments are required.
- The configuration specifies a default value for `src` (the [Log Source](#log-source), see below for details).
  - Therefore the `src` argument is optional.

### Invocation via convenience scripts

To make invocations more succinct, you can also use one of the "convenience scripts" for general purpose logging:

- `log_debug.cmd`
- `log_info.cmd`
- `log_warn.cmd`
- `log_error.cmd`
- `log_fatal.cmd`

or for reporting test results:

- `log_none.cmd`
- `log_pass.cmd`
- `log_fail.cmd`
- `log_skip.cmd`

There is also a "no-operation" dummy script that does absolutely nothing; you can use this when you temporarily want to suppress another logging operation from your script:

- `log_noop.cmd`

Each of these scripts takes the log message in double quotes as the first argument, and optionally an alternative source (without quotes), e.g.:
```
log_debug "Wow! This is wonderful" myDebugLogSource
log_fatal "Bummer. Cannot continue. Sorry"
```
Note that:
- In addition to being enclosed by double quotes, must be recognized as a single argument by the `CMD` shell.
  - If it has internal double quotes, 
    - they must be paired, and
    - no spaces may appear between these pairs.
- The second argument may not include double quotes or spaces.

#### `log_level_async.cmd`

The convenience scripts all call `log_level_async.cmd`; some error messages reference this script rather than the calling script.

### Creating paths for supplementary logs

To create a path to a "supplementary log", as described in the [Supplementary Logs](#supplementary-logs) section below, and assign it to the `MY_SUPPLEMENATARY_LOG_PATH` environment variable:
```
log4cmd_newlog.cmd MY_SUPPLEMENATARY_LOG_PATH sourceName logName
```
Note, however, that this path will *not* be enclosed in double quotes; if it contains spaces then you must enclose it in double quotes when you reference it, e.g.:
```
type "%MY_SUPPLEMENATARY_LOG_PATH%"
```

## How to use - quick start

### TL;DR

```
:: Set up registry keys and create directory where log files will be written.
install_example.cmd

:: Write some log messages.
demo_log4cmd.cmd

:: Run some tests if you like.
test\run_tests.cmd

:: Create mySourceName subdirectory in log directory and generate a path for a
::   uniquely named file in that directory, but do not create that file yet.
log4cmd_newlog.cmd MY_LOGNAME_LOG mySourceName myLogName
```

### Default Behavior

#### Windows Registry

In the Windows registry:

- the `log4cmd` value under the `HKCU\Environment` key specifies the root directory used for logging by `log4cmd`;
- that value specifies `%USERPROFILE%\AppData\Local\log4cmd` as the logging root.

#### Log Source

The default "log source" is named `log4vbs`:

- This is merely the default.
  - Individual logging calls may specify any log source.
- Log sources are merely names; there is no requirement that they be defined before they are used.

#### Log Messages

As long as an alternative log source has not been specified, log messages will be written to `%USERPROFILE%\AppData\Local\log4cmd\log4vbs-CCYY-MM-DD.log`:

- `CCYY` is the current year, `MM` is the current month (01-12), and `DD` is the current day-of-month, in the UTC time zone.
- When logging, if a log source is specified as an alternative to the default, it will be used as the prefix in lieu of `log4vbs`.

#### Synchronous Logging by `LOG_*.CMD` Scripts

By default, all `LOG_*.CMD` scripts wait for all loggers to finish running before returning.

**EXPERIMENTAL** If you define the `LOG4CMD_ASYNC` environment variable before calling, however, these will delegate logging to a background task and return immediately.  This has reliability issues at the moment, however, so don't assume that it's going to work.

### Demonstration

To see `log4cmd` in action, assuming that the default settings seem acceptable to you:

#### Set Up

- Run `install_example.cmd`.

#### Logging

- Run `demo_log4cmd.cmd` to demonstrate invocation of `log4vbs.vbs` directly from the command line.
- Run `cscript //nologo demo_log4vbs.vbs` to demonstrate invocation of `log4vbs.vbs` from VBScript by inclusion.
  - This is in fact run from `demo_log4cmd.cmd` as well.
- Run `demo_log4cmd_async.cmd` to demonstrate asynchronous logging with the `LOG_*.CMD` scripts.  As would be expected:
  - The synchronous messages will appear in the order in which they are logged.
  - The asynchronous messages may not appear in the order in which they are logged.

#### Supplementary Logs

- Run `log4cmd_newlog.cmd` to create a unique path for a general purpose "supplementary log" file.
  - Each supplementary log for a give source is written to a subdirectory named after that source, created in the logging root directory.
  - usage: `log4cmd_newlog.cmd MY_LOGNAME_LOG mySourceName myLogName`
    - This creates the `mySourceName` subdirectory under the `log4cmd` logging directory root and assigns to the `MY_LOGNAME_LOG` environment variable a unique path that can be used to log any text in any fashion that you require.
    - This does not in fact create the log file, though it does create a subdirectory for it if it does not already exist.

### Customization

(For a more advanced approach that may be easier to maintain, see
[Alternative Customization Technique - "tail patching"](#alternative-customization-technique---tail-patching)
below.)

Customizations will hopefully be straightforward.

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

(The next logger I would like to have would be one that logs to an SQLite database.)

### Log-level Filtering

The log levels that will be accepted for logging (i.e., not silently ignored) may be assigned to the `logLevelFilter` in `log4vbs_config.vbs`, which filters logging to all loggers.

The `Select Case` statement in the `Loggers` function in `log4vbs_config_example.vbs` supports logger-specific log-level filtering through the `logLevelFilterForFile` and `logLevelFilterForStdOut` VBScript variables.

### Security

A hallmark of secure logging is that logs be written where they cannot be modified or erased.  If you have a need for secure logging, you could create a logger to interact with such a logging facility.  The file logger included here is **not** intended to meet any security requirements.

The Windows Event Log is set up to achieve such non-redactability to a great degree, for unpriviliged users at least; however, an unprivileged user can only write to the *Application Log* "event source" unless an administrator creates an application-specific event source, so it may be too much of a jumble to be worthwhile.  If you want to do this, you might find what you need to get started at [https://ss64.com/vb/logevent.html](https://ss64.com/vb/logevent.html).

## Alternative Customization Technique - "tail patching"

A "tail patch" is applying a few minor changes after some code has executed.  This makes minor configuration changes easier both to read and to maintain.

### `log4vbs_config.vbs`

If you do not need to change the loggers but merely want to override the values assigned to some variables, one alternative to copying `log4vbs_config_example.vbs` to `log4vbs_config.vbs` is to create `log4vbs_config.vbs` as follows:
```
include ".\log4vbs_config_example.vbs"
logSource = "myOwnLogSource"
logLevelFilter = "debug|info|warn|error|fatal"
```
Note that `include` is a function defined in `log4vbs.vbs`; it is not a standard part of VBScript.

### `log4cmd_regkey.cmd`

Similarly, you can override just the logging location by creating `log4cmd_regkey.cmd` as follows:
```
@call "%~dp0\log4cmd_regkey_example.cmd"
@set LOG4CMD_ROOT_EX=%TEMP%\log4cmd
@set LOG4CMD_ROOT_IN=%%TEMP%%\log4cmd
```
