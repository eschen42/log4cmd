' Prerequisites:
'   iso8601zulu.vbs must have been included

Public Function LogMessage(Level, Message)
  Dim nowZulu
  nowZulu = ToIsoDateTimeZulu(NOW(), "-", ":", GetTimeZoneOffsetHours())
  LogMessage = nowZulu & "  " & Level & " " & Message
End Function
