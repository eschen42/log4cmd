' Prerequisites:
'   iso8601zulu.vbs must have been included

Sub LogToStdOut(Source, Level, Message)
  WScript.StdOut.WriteLine Source & ": " & LogMessage(Level, Message)
End Sub
