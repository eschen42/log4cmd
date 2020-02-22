' Get for supplied date, in ISO8601 format, in UTC (also known as "Zulu" or UTC)
' Adapted from:
'   https://www.3dclipboard.com/forum/viewtopic.php?t=2977 section "ISO8601 no colons"
' Usage examples:
'   WScript.StdOut.WriteLine ToIsoDateTime(NOW(), "-", ":")
'   WScript.StdOut.WriteLine ToIsoDateTimeZulu(NOW(), "-", ":")
' Warning! This may not properly handle fractional hour timezones!

'''   ' To include this in another VBScript file, use this include
'''   ' function ref: https://stackoverflow.com/a/43957897
'''       Sub include( relativeFilePath ) 
'''         Set fso = CreateObject("Scripting.FileSystemObject")
'''         thisFolder = fso.GetParentFolderName( WScript.ScriptFullName ) 
'''         absFilePath = fso.BuildPath( thisFolder, relativeFilePath )
'''         executeGlobal fso.openTextFile( absFilePath ).readAll()
'''       End Sub
'''   ' as follows
'''       include ".\iso8601zulu.vbs"

Public Function ToIsoDateTime(datetime, dash, colon)
  ToIsoDateTime = ToIsoDate(datetime, dash) & "T" & ToIsoTime(datetime, colon) & GetTimeZoneOffsetString()
End Function

Public Function ToIsoDateTimeZulu(datetime, dash, colon, offset)
  'offset = GetTimeZoneOffset()
  datetime = DateAdd("h", -offset, datetime)
  ToIsoDateTimeZulu = ToIsoDate(datetime, dash) & "T" & ToIsoTime(datetime, colon) & "Z"
End Function

Public Function ToIsoDate(datetime, dash)
  ToIsoDate = CStr(Year(datetime)) & dash & StrN2(Month(datetime),"") & dash & StrN2(Day(datetime),"")
End Function    

Public Function ToIsoTime(datetime, colon) 
  ToIsoTime = StrN2(Hour(datetime),"") & colon & StrN2(Minute(datetime),"") & colon & StrN2(Second(datetime),"")
End Function

Function GetTimeZoneOffset()
  Const sComputer = "."

  Dim oWmiService : Set oWmiService = _
    GetObject("winmgmts:{impersonationLevel=impersonate}!\\" _
      & sComputer & "\root\cimv2")

  Set cItems = oWmiService.ExecQuery("SELECT * FROM Win32_ComputerSystem")

  For Each oItem In cItems
    GetTimeZoneOffset = oItem.CurrentTimeZone / 60.0
    Exit For
  Next
End Function

Function GetTimeZoneOffsetString()
  GetTimeZoneOffsetString = StrN2(GetTimeZoneOffset(),"+") & "00"
End Function


Private Function StrN2(n,positiveSign)
  n = CInt(n)
  If n<0 Then
    sign = "-"
    n = -n
  Else
    sign = positiveSign
  End If
  If Len(n) < 2 Then StrN2 = "0" & n Else StrN2 = n
  StrN2 = sign & StrN2
  StrN2 = CStr(StrN2)
End Function
