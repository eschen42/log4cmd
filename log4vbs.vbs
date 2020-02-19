' Generic logger for VBScript, to be invoked from the command line
Option Explicit

If WScript.ScriptName = "log4vbs.vbs" Then
  Dim fso
  Set fso = CreateObject("Scripting.FileSystemObject")
End If

' To include another VBScript file, use this include
' function ref: https://stackoverflow.com/a/43957897
Sub include( relativeFilePath )
  Dim thisFolder, absFilePath
  thisFolder = fso.GetParentFolderName( WScript.ScriptFullName ) 
  absFilePath = fso.BuildPath( thisFolder, relativeFilePath )
  executeGlobal fso.openTextFile( absFilePath ).readAll()
End Sub

Dim log4vbsSinkCount
log4vbsSinkCount = 0

include ".\iso8601zulu.vbs"

include ".\log4vbs_config.vbs"

Sub LogInfo(Message)
  Logger "INFO ", Message
End Sub
Sub LogWarn(Message)
  Logger "WARN ", Message
End Sub
Sub LogError(Message)
  Logger "ERROR", Message
End Sub
Sub LogFatal(Message)
  Logger "FATAL", Message
End Sub
Sub LogNone(Message)
  Logger "     ", Message
End Sub
Sub LogPass(Message)
  Logger "PASS ", Message
End Sub
Sub LogFail(Message)
  Logger "FAIL ", Message
End Sub
Sub LogSkip(Message)
  Logger "SKIP ", Message
End Sub

' Only process command-line arguments if this was not included
'   in another script (this test is a hack)
If WScript.ScriptName = "log4vbs.vbs" Then
  Dim Args
  Set Args = Wscript.Arguments.Named
  If Args Is Nothing Then
    WScript.Echo "Args is Nothing"
  ElseIf IsEmpty(Args) Then
    WScript.Echo "Args is empty"
  ElseIf IsNull(Args) Then
    WScript.Echo "Args is null"
  Else
    Select Case Args.Item("lvl")
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
        WScript.StdErr.WriteLine "usage: cscript //nologo " & WScript.ScriptName & _
          " /lvl:{info|warn|error|fatal|none|pass|fail|skip}" & _
          " /msg:your-message-in-double-quotes"
    End Select
  End If
End If

If WScript.ScriptName = "log4vbs.vbs" Then
  Set fso = Nothing
End If

' vim: sw=2 ts=3 et ai ff=dos :
