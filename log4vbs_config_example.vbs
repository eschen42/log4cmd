' Configure log4vbs.vbs

'''   ' To include this in another VBScript file, use this include
'''   ' function ref: https://stackoverflow.com/a/43957897
'''
'''   Function include( relativeFilePath )
'''     Dim thisFolder, absFilePath, errMsg
'''     include = False
'''     thisFolder = fso.GetParentFolderName( WScript.ScriptFullName )
'''     absFilePath = fso.BuildPath( thisFolder, relativeFilePath )
'''     If fso.FileExists( absFilePath ) Then
'''       executeGlobal fso.openTextFile( absFilePath ).readAll()
'''       include = True
'''     Else
'''       errMsg ="File does not exist: " & absFilePath
'''       Err.Description = errMsg
'''     End If
'''   End Function
'''
'''   ' e.g.:
'''
'''   include ".\log4vbs_config.vbs"

Dim logSource, strLog4cmdKey, log2file_objShell, strLog4cmdDir
Dim logLevelFilterForStdOut, logLevelFilterForFile
Dim enabledFile, enabledStdOut

strLog4cmdKey           = "HKCU\Environment\log4cmd"
logSource               = "log4vbs"
logLevelFilter          = "debug|info|warn|error|fatal|none|pass|fail|skip"
logLevelFilterForFile   = "debug|info|warn|error|fatal|none|pass|fail|skip"
logLevelFilterForStdOut = "debug|info|warn|error|fatal|none|pass|fail|skip"

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

  enabledFile = include(".\log4vbs_log2file.vbs")
  log4vbsSinkCount = 1 + log4vbsSinkCount

  enabledStdOut = include(".\log4vbs_log2stdout.vbs")
  log4vbsSinkCount = 1 + log4vbsSinkCount

End If

Function Logger(Level, Message)
  Dim i, trimLCaseLevel
  trimLCaseLevel = RTrim(LCase(Level))
  For i = 1 to log4vbsSinkCount
    Select Case i
      Case 1
        If enabledFile   And InStr("|" & logLevelFilterForFile   & "|", trimLCaseLevel) > 1 Then
          LogToFile   logSource, Level, Message
        End If
      Case 2
        If enabledStdOut And InStr("|" & logLevelFilterForStdOut & "|", trimLCaseLevel) > 1 Then
          LogToStdOut logSource, Level, Message
        End If
    End Select
  Next
  Logger = True
End Function
