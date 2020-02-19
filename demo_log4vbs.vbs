Option Explicit

Dim fso
Set fso = CreateObject("Scripting.FileSystemObject")

' To include another VBScript file, use this include
' function ref: https://stackoverflow.com/a/43957897
Sub include( relativeFilePath )
  Dim thisFolder, absFilePath
  thisFolder  = fso.GetParentFolderName( WScript.ScriptFullName ) 
  absFilePath = fso.BuildPath( thisFolder, relativeFilePath )
  executeGlobal fso.openTextFile( absFilePath ).readAll()
End Sub

include ".\log4vbs.vbs"

LogInfo "Hello World"

set fso = Nothing
