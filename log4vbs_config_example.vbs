' Configure log4vbs.vbs

'''   ' To include this in another VBScript file, use this include
'''   ' function ref: https://stackoverflow.com/a/43957897
'''   Sub include( relativeFilePath ) 
'''       Set fso = CreateObject("Scripting.FileSystemObject")
'''       thisFolder = fso.GetParentFolderName( WScript.ScriptFullName ) 
'''       absFilePath = fso.BuildPath( thisFolder, relativeFilePath )
'''       executeGlobal fso.openTextFile( absFilePath ).readAll()
'''   End Sub

'''   include ".\log4vbs_config.vbs"

'WScript.StdErr.WriteLine "(1)"

Dim logSource, strLog4cmdKey, log2file_objShell, strLog4cmdDir
strLog4cmdKey = "HKCU\Environment\log4cmd"
logSource = "log4vbs"
logLevelFilter = "debug|info|warn|error|fatal|none|pass|fail|skip"

' Include the message formatter - ISO8601 LEVEL MESSAGE
include ".\log4vbs_logMessage.vbs"

Set log2file_objShell = WScript.CreateObject("WScript.Shell")
set strLog4cmdDir = Nothing
On Error Resume Next
strLog4cmdDir = log2file_objShell.RegRead(strLog4cmdKey)
On Error Goto 0
If IsObject(strLog4cmdDir) Then
  WScript.StdErr.WriteLine "Warning: Aborting logging because unable to read registry value " & strLog4cmdKey
Else

  strLog4cmdDir = log2file_objShell.ExpandEnvironmentStrings(strLog4cmdDir)
  Set log2file_objShell = Nothing

  include ".\log4vbs_log2file.vbs"
  log4vbsSinkCount = 1 + log4vbsSinkCount

  include ".\log4vbs_log2stdout.vbs"
  log4vbsSinkCount = 1 + log4vbsSinkCount

End If

Function Logger(Level, Message)
  Dim i
  For i = 1 to log4vbsSinkCount
    Select Case i
      Case 1
        LogToFile logSource, Level, Message
      Case 2
        LogToStdOut logSource, Level, Message
    End Select
  Next
  Logger = True
End Function
