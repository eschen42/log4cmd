' Prerequisites:
'   iso8601zulu.vbs must have been included
'   strLog4cmdDir has been set

Sub LogToFile(Source, Level, Message)
  Const ForAppending = 8
  Dim oLogFile  : Set oLogFile = Nothing
  Dim nowZulu   : nowZulu = ToIsoDateTimeZulu(NOW(), "-", ":", GetTimeZoneOffset())
  Dim logFile   : logFile = strLog4cmdDir & "\" & Source & "-" & Left(nowZulu,10) & ".log"
  Dim mySuccess : mySuccess = False
  Dim myTTL
  For myTTL = 1 to 5
    If mySuccess Then Exit For
    If myTTL < 5 Then On Error Resume Next
    Set oLogFile = fso.OpenTextFile(logFile, ForAppending, True)
    If Not oLogFile Is Nothing Then
      oLogFile.WriteLine LogMessage(Level, Message)
      oLogFile.Close
      If Err.Number = 0 Then mySuccess = True
    End If
    Set oLogFile = Nothing
    ' ' The only Err.Number that I have seen here is 70 Permission Denied
    ' If Err.Number <> 0 Then
    '   WScript.StdErr.WriteLine "log4vbs_log2file.vbs myTTL " & myTTL & _
    '     " because error " & Err.Number & " - " & Err.Description & _
    '     " - for message: " & Message
    ' End If
    On Error Goto 0
    If Not mySuccess Then
      Randomize
      WScript.Sleep 200 + (500 * Rnd)
    End If
  Next ' myTTL
End Sub
