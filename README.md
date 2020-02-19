# log4cmd - a configurable log proxy for the windows command line

This is a configurable command-line logger written in VBScript.

It can be invoked directly from the Windows command line or included in another VBScript program.

## How to use - quick start

To see it in action:

- Run `install_example.cmd` or copy and customize it to use another registry value than `log4cmd` under `HKCU\\Environment`.
- Copy `log4vbs_config_example.vbs` to `log4vbs_config.vbs` and run `demo_log4cmd.cmd`.
  - If you customized the registry value, you will need to modify the config as well.

## Loggers

Presently there are two loggers, one to standard output and another to a file.  You can add more and modify the config to include them.
