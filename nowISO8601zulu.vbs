' Get current time (in UTC time zone) in ISO8601 format
Option Explicit

Dim fso
Set fso = CreateObject("Scripting.FileSystemObject")

' To include another VBScript file, use this include
' function ref: https://stackoverflow.com/a/43957897
Sub include( relativeFilePath )
  Dim thisFolder, absFilePath
  thisFolder = fso.GetParentFolderName( WScript.ScriptFullName )
  absFilePath = fso.BuildPath( thisFolder, relativeFilePath )
  executeGlobal fso.openTextFile( absFilePath ).readAll()
End Sub

include ".\include\iso8601zulu.vbs"

WScript.StdOut.WriteLine ToIsoDateTimeZulu( Now(), "-", ":", GetTimeZoneOffsetHours() )

set fso = Nothing
