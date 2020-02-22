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

Dim logSource
logSource = "log4vbs"
Dim logLevelFilter
logLevelFilter = "debug|info|warn|error|fatal|none|pass|fail|skip"

include ".\log4vbs_logMessage.vbs"

Dim strLog4cmdKey
strLog4cmdKey = "HKCU\Environment\log4cmd"
Dim log2file_objShell, strLog4cmdDir
Set log2file_objShell = WScript.CreateObject("WScript.Shell")
strLog4cmdDir = log2file_objShell.RegRead(strLog4cmdKey)
strLog4cmdDir = log2file_objShell.ExpandEnvironmentStrings(strLog4cmdDir)
Set log2file_objShell = Nothing

include ".\log4vbs_log2file.vbs"
log4vbsSinkCount = 1 + log4vbsSinkCount

include ".\log4vbs_log2stdout.vbs"
log4vbsSinkCount = 1 + log4vbsSinkCount

Sub Logger(Level, Message)
  Dim i
  For i = 1 to log4vbsSinkCount
    Select Case i
      Case 1
        LogToFile logSource, Level, Message
      Case 2
        LogToStdOut logSource, Level, Message
    End Select
  Next
End Sub

