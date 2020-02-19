' Prerequisites:
'   iso8601zulu.vbs must have been included
'   strLog4cmdDir has been set

Sub LogToFile(Source, Level, Message)
  Dim logFile, oLogFile, nowZulu
  nowZulu = ToIsoDateTimeZulu(NOW(), "-", ":", GetTimeZoneOffset())
  logFile = strLog4cmdDir & "\" & Source & "-" & Left(nowZulu,10) & ".log"
  Const ForAppending = 8
  Set oLogFile = fso.OpenTextFile(logFile, ForAppending, True)
  oLogFile.WriteLine LogMessage(Level, Message)
  oLogFile.Close
  Set oLogFile = Nothing
End Sub
