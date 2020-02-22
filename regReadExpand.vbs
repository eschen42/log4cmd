Option Explicit
Dim args, objShell, strRegPathWithValueName, strResultUnexpanded, strResultExpanded

Set objShell = Nothing
On Error Resume Next
Set objShell = WScript.CreateObject("WScript.Shell")
On Error Goto 0
If Not objShell Is Nothing Then

  If UCase( Right( WScript.FullName, 12 ) ) <> "\CSCRIPT.EXE" Then
    WScript.Echo "Usage: cscript //nologo regReadExpand.vbs path\to\registry\string\value"
    WScript.Quit -1
  End If

  Set args = Wscript.Arguments
  If args.Count <> 1 Then
    WScript.StdErr.Writeline "Usage: cscript //nologo regReadExpand.vbs path\to\registry\string\value"
    WScript.StdErr.Writeline "  Read a value (string or 32-bit signed integer) from the registry."
    WScript.StdErr.Writeline "  For string values, environment variables are expanded."
    WScript.StdErr.Writeline "  e.g.: cscript //nologo regReadExpand.vbs HKCU\Environment\TEMP"
    WScript.Quit -1
  End If

  ' strRegPathWithValueName = "HKCU\Environment\log4cmd"
  strRegPathWithValueName = args(0)

  Set strResultUnexpanded = Nothing
  On Error Resume Next
  strResultUnexpanded = objShell.RegRead(strRegPathWithValueName)
  On Error Goto 0
  If Not IsObject(strResultUnexpanded) Then
    ' WScript.StdErr.Writeline "log4cmd base: " & strResultUnexpanded
    On Error Resume Next
    strResultExpanded = objShell.ExpandEnvironmentStrings(strResultUnexpanded)
    On Error Goto 0
    If Not IsObject(strResultExpanded) Then
      WScript.StdOut.Writeline strResultExpanded
      Set objShell = Nothing
      WScript.Quit 0
    Else
      WScript.StdErr.Writeline "Cannot expand string value from: " & strResultUnexpanded
    End If
  Else
    WScript.StdErr.Writeline "Cannot read value from: " & strRegPathWithValueName
  End If

End If

Set objShell = Nothing
WScript.Quit -1
