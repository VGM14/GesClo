#NoTrayIcon
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>

Local $sRoot = @ScriptDir
Local $sServerDir = $sRoot & "\server"
Local $sFrontendDir = $sRoot & "\frontend"

; ── GUI ───────────────────────────────────────────────────────
Local $hGUI = GUICreate("GesClo", 420, 300, -1, -1, $WS_CAPTION + $WS_SYSMENU + $WS_MINIMIZEBOX)
GUISetBkColor(0x1A1A2E)

GUICtrlCreateLabel("GesClo", 20, 14, 380, 32)
GUICtrlSetFont(-1, 18, 700, 0, "Segoe UI")
GUICtrlSetColor(-1, 0x4F8EF7)

Local $lblStatus = GUICtrlCreateLabel("Avvio in corso...", 20, 50, 380, 20)
GUICtrlSetFont(-1, 10, 400, 0, "Segoe UI")
GUICtrlSetColor(-1, 0xCCCCCC)

Local $lblLauncher = GUICtrlCreateLabel("○  Launcher       :3002", 30, 88, 360, 18)
GUICtrlSetFont(-1, 9, 400, 0, "Segoe UI")
GUICtrlSetColor(-1, 0x555555)

Local $lblServer = GUICtrlCreateLabel("○  Server API     :3001", 30, 112, 360, 18)
GUICtrlSetFont(-1, 9, 400, 0, "Segoe UI")
GUICtrlSetColor(-1, 0x555555)

Local $lblFrontend = GUICtrlCreateLabel("○  Frontend       :3000", 30, 136, 360, 18)
GUICtrlSetFont(-1, 9, 400, 0, "Segoe UI")
GUICtrlSetColor(-1, 0x555555)

Local $lblUrl = GUICtrlCreateLabel("", 20, 170, 380, 18)
GUICtrlSetFont(-1, 9, 400, 0, "Segoe UI")
GUICtrlSetColor(-1, 0x4F8EF7)

Local $btnOpen = GUICtrlCreateButton("Apri GesClo", 20, 210, 185, 38)
GUICtrlSetFont(-1, 10, 600, 0, "Segoe UI")

Local $btnClose = GUICtrlCreateButton("Chiudi GesClo", 215, 210, 185, 38)
GUICtrlSetFont(-1, 10, 600, 0, "Segoe UI")

GUICtrlCreateLabel("v2.0  |  Node.js + React + Clerk", 20, 270, 380, 14)
GUICtrlSetFont(-1, 7, 400, 0, "Segoe UI")
GUICtrlSetColor(-1, 0x444466)

GUISetState(@SW_SHOW)

; ── Controllo prerequisiti ────────────────────────────────────
_InstallaSeDipendeManca()

If Not FileExists($sServerDir & "\node_modules") Then
    GUICtrlSetData($lblStatus, "Installazione dipendenze server...")
    GUICtrlSetColor($lblStatus, 0xFFAA44)
    _RunWaitGUI(@ComSpec & ' /c npm install', $sServerDir)
EndIf

If Not FileExists($sFrontendDir & "\node_modules") Then
    GUICtrlSetData($lblStatus, "Installazione dipendenze frontend...")
    GUICtrlSetColor($lblStatus, 0xFFAA44)
    _RunWaitGUI(@ComSpec & ' /c npm install', $sFrontendDir)
EndIf

; ── Avvio servizi ─────────────────────────────────────────────
GUICtrlSetData($lblStatus, "Avvio launcher...")
Run(@ComSpec & ' /c node launcher.js', $sServerDir, @SW_HIDE)
Sleep(2000)
GUICtrlSetData($lblLauncher, "●  Launcher       :3002")
GUICtrlSetColor($lblLauncher, 0x4FCB71)

GUICtrlSetData($lblStatus, "Avvio server API...")
Run(@ComSpec & ' /c node server.js', $sServerDir, @SW_HIDE)
Sleep(4000)
GUICtrlSetData($lblServer, "●  Server API     :3001")
GUICtrlSetColor($lblServer, 0x4FCB71)

GUICtrlSetData($lblStatus, "Avvio frontend...")
Run(@ComSpec & ' /c npm run dev', $sFrontendDir, @SW_HIDE)
Sleep(6000)
GUICtrlSetData($lblFrontend, "●  Frontend       :3000")
GUICtrlSetColor($lblFrontend, 0x4FCB71)

; ── Pronto ────────────────────────────────────────────────────
GUICtrlSetData($lblStatus, "GesClo attivo")
GUICtrlSetColor($lblStatus, 0x4FCB71)
GUICtrlSetData($lblUrl, "http://localhost:3000")
ShellExecute("http://localhost:3000")

; ── Loop eventi ───────────────────────────────────────────────
While 1
    Switch GUIGetMsg()
        Case $GUI_EVENT_CLOSE
            _Shutdown()
        Case $btnOpen
            ShellExecute("http://localhost:3000")
        Case $btnClose
            _Shutdown()
    EndSwitch
WEnd

Func _Shutdown()
    GUICtrlSetData($lblStatus, "Chiusura in corso...")
    GUICtrlSetColor($lblStatus, 0xFFAA44)
    GUICtrlSetData($lblLauncher, "○  Launcher       :3002")
    GUICtrlSetColor($lblLauncher, 0x555555)
    GUICtrlSetData($lblServer, "○  Server API     :3001")
    GUICtrlSetColor($lblServer, 0x555555)
    GUICtrlSetData($lblFrontend, "○  Frontend       :3000")
    GUICtrlSetColor($lblFrontend, 0x555555)
    Run(@ComSpec & ' /c taskkill /f /im node.exe', "", @SW_HIDE)
    Sleep(1500)
    GUIDelete($hGUI)
    Exit 0
EndFunc

Func _WaitClose()
    While GUIGetMsg() <> $GUI_EVENT_CLOSE
        Sleep(100)
    WEnd
    GUIDelete($hGUI)
    Exit 1
EndFunc

Func _InstallaSeDipendeManca()
    ; ── Git ──────────────────────────────────────────────────────
    Local $sGitVer = _RunCapture("git --version")
    If $sGitVer = "" Then
        GUICtrlSetData($lblStatus, "Installazione Git...")
        GUICtrlSetColor($lblStatus, 0xFFAA44)
        _RunWaitGUI(@ComSpec & ' /c winget install -e --id Git.Git --silent --accept-source-agreements --accept-package-agreements', "")
        If _RunCapture("git --version") = "" Then
            MsgBox(16, "GesClo — Errore", "Impossibile installare Git." & @CRLF & "Scaricalo da: https://git-scm.com")
            _WaitClose()
        EndIf
        GUICtrlSetData($lblStatus, "Git installato")
        GUICtrlSetColor($lblStatus, 0x4FCB71)
        Sleep(800)
    EndIf

    ; ── Node.js ───────────────────────────────────────────────────
    Local $sNodeVer = _RunCapture("node --version")
    If $sNodeVer = "" Then
        GUICtrlSetData($lblStatus, "Installazione Node.js LTS...")
        GUICtrlSetColor($lblStatus, 0xFFAA44)
        _RunWaitGUI(@ComSpec & ' /c winget install -e --id OpenJS.NodeJS.LTS --silent --accept-source-agreements --accept-package-agreements', "")
        If _RunCapture("node --version") = "" Then
            MsgBox(16, "GesClo — Errore", "Impossibile installare Node.js." & @CRLF & "Scaricalo da: https://nodejs.org")
            _WaitClose()
        EndIf
        GUICtrlSetData($lblStatus, "Node.js installato")
        GUICtrlSetColor($lblStatus, 0x4FCB71)
        Sleep(800)
    EndIf

    ; ── OpenJDK 25 (Adoptium Temurin) ────────────────────────────
    Local $sJavaVer = _RunCaptureErr("java -version")
    If Not StringInStr($sJavaVer, "25") Then
        GUICtrlSetData($lblStatus, "Installazione OpenJDK 25...")
        GUICtrlSetColor($lblStatus, 0xFFAA44)
        _RunWaitGUI(@ComSpec & ' /c winget install -e --id EclipseAdoptium.Temurin.25.JDK --silent --accept-source-agreements --accept-package-agreements', "")
        If Not StringInStr(_RunCaptureErr("java -version"), "25") Then
            ; winget fallito — download diretto da Adoptium
            GUICtrlSetData($lblStatus, "Download OpenJDK 25 (Adoptium) — attendere...")
            Local $sMsi = @TempDir & "\temurin25-jdk.msi"
            _InetGetGUI("https://api.adoptium.net/v3/binary/latest/25/ga/windows/x64/jdk/hotspot/normal/eclipse", $sMsi)
            If FileExists($sMsi) And FileGetSize($sMsi) > 1000000 Then
                GUICtrlSetData($lblStatus, "Installazione OpenJDK 25...")
                _RunWaitGUI(@ComSpec & ' /c msiexec /i "' & $sMsi & '" /quiet /norestart', "")
                FileDelete($sMsi)
            Else
                FileDelete($sMsi)
                MsgBox(16, "GesClo — Errore", "Impossibile installare OpenJDK 25." & @CRLF & "Scaricalo da: https://adoptium.net/temurin/releases/?version=25")
                _WaitClose()
            EndIf
            If Not StringInStr(_RunCaptureErr("java -version"), "25") Then
                MsgBox(16, "GesClo — Errore", "Impossibile installare OpenJDK 25." & @CRLF & "Scaricalo da: https://adoptium.net/temurin/releases/?version=25")
                _WaitClose()
            EndIf
        EndIf
        GUICtrlSetData($lblStatus, "OpenJDK 25 installato")
        GUICtrlSetColor($lblStatus, 0x4FCB71)
        Sleep(800)
    EndIf
EndFunc

; Cattura stdout + stderr (necessario per java -version)
Func _RunCaptureErr($sCmd)
    Local $iPID = Run(@ComSpec & ' /c ' & $sCmd & ' 2>&1', @TempDir, @SW_HIDE, 2)
    Local $sOut = ""
    While ProcessExists($iPID)
        $sOut &= StdoutRead($iPID)
        Sleep(100)
    WEnd
    $sOut &= StdoutRead($iPID)
    Return StringStripWS($sOut, 3)
EndFunc

Func _RunCapture($sCmd)
    Local $iPID = Run(@ComSpec & ' /c ' & $sCmd, @TempDir, @SW_HIDE, 2)
    Local $sOut = ""
    While ProcessExists($iPID)
        $sOut &= StdoutRead($iPID)
        Sleep(100)
    WEnd
    $sOut &= StdoutRead($iPID)
    Return StringStripWS($sOut, 3)
EndFunc

; Esegue un comando in background tenendo la GUI reattiva
Func _RunWaitGUI($sCmd, $sDir = "")
    Local $iPID = Run($sCmd, $sDir, @SW_HIDE)
    While ProcessExists($iPID)
        GUIGetMsg()
        Sleep(100)
    WEnd
EndFunc

; Scarica un file in background tenendo la GUI reattiva
Func _InetGetGUI($sUrl, $sFile)
    Local $hInet = InetGet($sUrl, $sFile, 1, 1)
    While Not InetGetInfo($hInet, 2)
        GUIGetMsg()
        Sleep(200)
    WEnd
    Local $nBytes = InetGetInfo($hInet, 0)
    InetClose($hInet)
    Return $nBytes
EndFunc
