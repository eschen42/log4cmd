' Generic logger for VBScript, to be invoked from the command line
Option Explicit

Dim bLog4vbsConfigResult
Dim logLevelFilter
logLevelFilter = "debug|info|warn|error|fatal|none|pass|fail|skip"

If WScript.ScriptName = "log4vbs.vbs" Then
  Dim fso
  Set fso = CreateObject("Scripting.FileSystemObject")
End If

' To include another VBScript file, use this include
' function ref: https://stackoverflow.com/a/43957897
Function include( relativeFilePath )
  Dim thisFolder, absFilePath, errMsg
  include = False
  thisFolder = fso.GetParentFolderName( WScript.ScriptFullName )
  absFilePath = fso.BuildPath( thisFolder, relativeFilePath )
  If fso.FileExists( absFilePath ) Then
    executeGlobal fso.openTextFile( absFilePath ).readAll()
    include = True
  Else
    errMsg ="File does not exist: " & absFilePath
    Err.Description = errMsg
  End If
End Function

Sub MyLogger(Level, Message)
  Dim mySuccess
  mySuccess = False
  On Error Resume Next
  mySuccess = Logger(Level, Message)
  On Error Goto 0
  If Not mySuccess Then
    WScript.StdOut.WriteLine "NoLog: " & Level & " " & Message
  End If
End Sub

Sub LogDebug(Message)
  MyLogger "DEBUG", Message
End Sub
Sub LogInfo(Message)
  MyLogger "INFO ", Message
End Sub
Sub LogWarn(Message)
  MyLogger "WARN ", Message
End Sub
Sub LogError(Message)
  MyLogger "ERROR", Message
End Sub
Sub LogFatal(Message)
  MyLogger "FATAL", Message
End Sub
Sub LogNone(Message)
  MyLogger "     ", Message
End Sub
Sub LogPass(Message)
  MyLogger "PASS ", Message
End Sub
Sub LogFail(Message)
  MyLogger "FAIL ", Message
End Sub
Sub LogSkip(Message)
  MyLogger "SKIP ", Message
End Sub

Dim log4vbsSinkCount
log4vbsSinkCount = 0

Dim includeResult
includeResult = False
includeResult = include(".\include\iso8601zulu.vbs")
If Not includeResult Then
  WScript.StdErr.WriteLine "Warning: Could not include include\iso8601zulu.vbs - " & _
    Err.Description
End If

If includeResult Then
  includeResult = False
  includeResult = include(".\log4vbs_config.vbs")
  If Not includeResult Then
    includeResult = include(".\log4vbs_config_example.vbs")
    If Not includeResult Then
      WScript.StdErr.WriteLine "Warning: Could include neither log4vbs_config.vbs nor log4vbs_config_example.vbs - " & _
      Err.Description
    End If
  End If
End If

'If includeResult Then
'  If bLog4vbsConfigResult Then
    Dim usageMsg
    usageMsg = "usage: cscript //nologo " & WScript.ScriptName & _
               " /lvl:{" & logLevelFilter & "}" & _
               " /msg:your-message-in-double-quotes" & _
               " [/src:override-configured-source]"

    ' Only process command-line arguments if this was not included
    '   in another script (this test is a hack)
    If WScript.ScriptName = "log4vbs.vbs" Then
      Dim Args, argSrc, argLvl, argMsg
      Set Args = Wscript.Arguments.Named
      If Args Is Nothing Then
        WScript.Echo "Args is Nothing"
      ElseIf IsEmpty(Args) Then
        WScript.Echo "Args is empty"
      ElseIf IsNull(Args) Then
        WScript.Echo "Args is null"
      Else
        argLvl = Args.Item("lvl")
        argMsg = Args.Item("msg")
        If argLvl = "" Or argMsg = "" Then
          WScript.StdErr.WriteLine usageMsg
        Else
          argSrc = Args.Item("src")
          If Not argSrc = "" Then
            logSource = argSrc
          End If
          ' If lvl is not set, instr will return 1
          ' If lvl is set to something not in logLevelFilter, instr will return 0
          If InStr("|" & logLevelFilter & "|", Args.Item("lvl")) > 1 Then
            Select Case Args.Item("lvl")
              Case "debug"
                LogDebug Args.Item("msg")
              Case "info"
                LogInfo Args.Item("msg")
              Case "warn"
                LogWarn Args.Item("msg")
              Case "error"
                LogError Args.Item("msg")
              Case "fatal"
                LogFatal Args.Item("msg")
              Case "none"
                LogNone Args.Item("msg")
              Case "pass"
                LogPass Args.Item("msg")
              Case "fail"
                LogFail Args.Item("msg")
              Case "skip"
                LogSkip Args.Item("msg")
              Case Else
                WScript.StdErr.WriteLine usageMsg
            End Select
          End If
        End If
      End If
    End If
'  End If
'End If

If WScript.ScriptName = "log4vbs.vbs" Then
  Set fso = Nothing
End If

' vim: sw=2 ts=3 et ai ff=dos :
