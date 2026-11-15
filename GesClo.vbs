Option Explicit
' Avvia il server GesClo in background (nessuna finestra) e apre l'interfaccia nel browser.
' Richiede Node.js installato sul PC (usa "node" dal PATH). Se le librerie del server non
' ci sono (o l'installazione e' incompleta) le installa da solo prima di partire:
' con under+.bat se c'e', altrimenti direttamente con npm.
Dim sh, fso, root, i, code
Set sh  = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")
root = fso.GetParentFolderName(WScript.ScriptFullName)

Function ServerUp()
  Dim h
  On Error Resume Next
  Set h = CreateObject("MSXML2.ServerXMLHTTP.6.0")
  h.setTimeouts 500, 500, 500, 500
  h.open "GET", "http://127.0.0.1:3001/health", False
  h.send
  ServerUp = (Err.Number = 0 And h.status = 200)
  On Error GoTo 0
End Function

Function DepsOk()
  DepsOk = fso.FileExists(root & "\server\node_modules\express\package.json")
End Function

If Not ServerUp() Then
  code = sh.Run("cmd /c node -v >nul 2>&1", 0, True)
  If code <> 0 Then
    MsgBox "Node.js non trovato. Installa Node.js (https://nodejs.org) e riapri GesClo." & vbCrLf & vbCrLf & _
           "Node.js not found. Install Node.js (https://nodejs.org) and open GesClo again.", 48, "GesClo"
    WScript.Quit 1
  End If

  If Not DepsOk() Then
    If fso.FileExists(root & "\under+.bat") Then
      sh.Run "cmd /c """"" & root & "\under+.bat"" /silent""", 1, True
    Else
      sh.CurrentDirectory = root & "\server"
      sh.Run "cmd /c npm install --omit=dev --no-audit --no-fund", 1, True
    End If
    If Not DepsOk() Then
      MsgBox "Non sono riuscito a installare le librerie. Servono internet e una cartella scrivibile (non C:\Program Files)." & vbCrLf & vbCrLf & _
             "Could not install the libraries. Internet and a writable folder are required (not C:\Program Files).", 48, "GesClo"
      WScript.Quit 1
    End If
  End If

  sh.CurrentDirectory = root & "\server"
  sh.Run "node server.js", 0, False
  For i = 1 To 40
    WScript.Sleep 300
    If ServerUp() Then Exit For
  Next
  If Not ServerUp() Then
    MsgBox "Il server GesClo non e' partito. Per vedere l'errore apri un prompt dei comandi nella cartella server e lancia: node server.js" & vbCrLf & vbCrLf & _
           "The GesClo server did not start. To see the error, open a command prompt in the server folder and run: node server.js", 48, "GesClo"
    WScript.Quit 1
  End If
End If

sh.Run "http://localhost:3001", 1, False
