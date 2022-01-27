#^Esc::
  WinGet, TransLevel, Transparent, A
  If (TransLevel = OFF) {
    WinSet, Transparent, 100, A
  } Else {
    WinSet, Transparent, OFF, A
  }
return
