# log4cmd - a configurable log proxy for the windows command line

This is a configurable command-line logger written in VBScript.

It can be invoked directly from the Windows command line or included in another VBScript program.

## How to use - quick start

### TL;DR;

```
copy log4cmd_regkey_example.cmd log4cmd_regkey.cmd
copy install_example.cmd        install.cmd
copy log4vbs_config_example.vbs log4vbs_config.vbs
demo_log4cmd.cmd
```

### Details

To see it in action:

- Copy `log4cmd_regkey_example.cmd` to `log4cmd_regkey.cmd`
  - If desired, customize it to have `log4cmd` designate the root directory for logging using a registry value other than `log4cmd` under `HKCU\Environment`
- If desired, copy and customize `install_example.cmd` to use a directory root for logging other than `%USERPROFILE%\AppData\Local\log4cmd`.
  - Run `install_example.cmd` or your customized copy.
- Copy `log4vbs_config_example.vbs` to `log4vbs_config.vbs` and run `demo_log4cmd.cmd`.
  - If you customized the registry key or value in `log4cmd_regkey.cmd`, you will need to modify `strLog4cmdKey` in the config as well.
- `demo_log4cmd.cmd` demonstrates invocation of `log4vbs.vbs` directly from the command line.
- `demo_log4vbs.vbs` demonstrates invocation of `log4vbs.vbs` from VBScript by inclusion.

## Loggers

Presently there are two loggers, one to standard output and another to a file.  You can add more and modify the config to include them.

## Usage

```
cscript //nologo log4vbs.vbs /lvl:{debug:info|warn|error|fatal|none|pass|fail|skip} /msg:your-message-in-double-quotes [/src:override-configured-source]
```
