# log4cmd - a configurable log proxy for the windows command line

This is a configurable command-line logger written in VBScript.

It can be invoked directly from the Windows command line or included in another VBScript program.

## Usage

```
cscript //nologo log4vbs.vbs /lvl:{debug:info|warn|error|fatal|none|pass|fail|skip} /msg:your-message-in-double-quotes [/src:override-configured-source]
log4cmd_newlog.cmd sourceName logName variableName
```

## How to use - quick start

### TL;DR;

```
copy log4cmd_regkey_example.cmd log4cmd_regkey.cmd
REM Customize log4cmd_regkey.cmd if desired.
copy install_example.cmd        install.cmd
REM Customize install.cmd if desired,
install.cmd
copy log4vbs_config_example.vbs log4vbs_config.vbs
REM Customize log4vbs_config.vbs as desired or as
REM   necessitated by customizations above.
demo_log4cmd.cmd
log4cmd_newlog.cmd mySourceName myLogName MY_LOGNAME_LOG
```

### Defaults

By default:

- the `log4cmd` value under the `HKCU\Environment` specifies the root directory used for logging by `log4cmd`;
- that value specifies `%USERPROFILE%\AppData\Local\log4cmd` as the logging root;
- the "log source" is named `log4vbs`.

### Details

To see `log4cmd` in action:

- Copy `log4cmd_regkey_example.cmd` to `log4cmd_regkey.cmd`
  - If desired, customize it to have `log4cmd` designate the *root directory for logging* using a *registry value other than `log4cmd` under `HKCU\Environment`*
- If desired, copy and customize `install_example.cmd` to use a directory root for logging other than `%USERPROFILE%\AppData\Local\log4cmd`.
  - Run `install_example.cmd` or your customized copy.
- Copy `log4vbs_config_example.vbs` to `log4vbs_config.vbs` and run `demo_log4cmd.cmd`.
  - If you customized the registry key or value in `log4cmd_regkey.cmd`, you will need to modify `strLog4cmdKey` in the config as well.
- `demo_log4cmd.cmd` demonstrates invocation of `log4vbs.vbs` directly from the command line.
- `demo_log4vbs.vbs` demonstrates invocation of `log4vbs.vbs` from VBScript by inclusion.

## Loggers

Presently there are two loggers, one to standard output and another to a file.  You can modify `log4vbs_config.vbs` to add more and include them.

## Sources, LogNames, and supplementary logs

A *Source* might be a program or suite of closely related programs.  All messages logged by `log4vbs.vbs` specify a source, even if this is only implicitly through `log4vbs_config.vbs`.  The source name is prepended to each day's log in the logging root directory.

A *LogName* is a label for a supplementary log.  Each supplementary log for a give source is written to a subdirectory named after that source, created in the logging root directory.

A path to a uniquely named supplementary log may be assigned using the `log4cmd_newlog.cmd` command.  For example:
```
log4cmd_newlog.cmd mySourceName myLogName MY_LOGNAME_LOG
```
creates the `mySourceName` subdirectory under the `log4cmd` logging directory root and generates a unique path that can be used to log any text in any fashion that you require. 
