' Generate a GUID
' ref: https://superuser.com/a/155834
' invocation:
'   cscript //NoLogo uuid.vbs
Option Explicit
Dim guid, index, obj, result

Set obj = Nothing
On Error Resume Next
Set obj = WScript.CreateObject("WScript.Shell")
On Error Goto 0
If Not obj Is Nothing Then
  If UCase( Right( WScript.FullName, 12 ) ) <> "\CSCRIPT.EXE" Then
    WScript.Echo "Usage: cscript //nologo uuid.vbs"
    WScript.Quit -1
  End If
End If

result = False
set obj = Nothing

For index = 1 To 10
  set obj = Nothing
  On Error Resume Next
  set obj = CreateObject("Scriptlet.TypeLib")
  On Error Goto 0
  If Not obj Is Nothing Then
    guid = obj.GUID
    WScript.StdOut.WriteLine Left(Replace(Replace(guid,"{",""),"}",""),36)
    result = True
    Exit For
  Else
    ' Wait for things to settle down before trying again
    WScript.StdErr.WriteLine "uuid.vbs: Wait for things to settle down before trying again"
    WScript.Sleep 250
  End If
Next

If Not result = True Then
  WScript.StdErr.WriteLine "uuid.vbs: Failed to generate UUID"
  WScript.Quit -1
Else
  WScript.Quit 0
End If
