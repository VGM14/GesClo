#NoTrayIcon
#include <GUIConstantsEx.au3>
#include <ProgressConstants.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>

Local $sRoot = $CmdLine[0] > 0 ? $CmdLine[1] : @ScriptDir

; ── GUI ───────────────────────────────────────────────────────
Local $hGUI = GUICreate("GesClo - Configurazione", 480, 220, -1, -1, $WS_CAPTION + $WS_SYSMENU)
GUISetBkColor(0x1A1A2E)

GUICtrlCreateLabel("GesClo", 20, 18, 440, 30)
GUICtrlSetFont(-1, 16, 700, 0, "Segoe UI")
GUICtrlSetColor(-1, 0x4F8EF7)

GUICtrlCreateLabel("Configurazione in corso...", 20, 50, 440, 16)
GUICtrlSetFont(-1, 8, 400, 0, "Segoe UI")
GUICtrlSetColor(-1, 0x888888)

Local $lblStatus = GUICtrlCreateLabel("Inizializzazione...", 20, 74, 440, 18)
GUICtrlSetFont(-1, 9, 400, 0, "Segoe UI")
GUICtrlSetColor(-1, 0xCCCCCC)

Local $hProg = GUICtrlCreateProgress(20, 100, 440, 16, $PBS_SMOOTH)

Local $lblDetail = GUICtrlCreateLabel("", 20, 126, 440, 16)
GUICtrlSetFont(-1, 8, 400, 0, "Segoe UI")
GUICtrlSetColor(-1, 0x666666)

GUICtrlCreateLabel("v2.0  |  Node.js + React + Clerk", 20, 190, 440, 14)
GUICtrlSetFont(-1, 7, 400, 0, "Segoe UI")
GUICtrlSetColor(-1, 0x444466)

GUISetState(@SW_SHOW)

; ── STEP 1: npm install server ────────────────────────────────
_Step("Installazione dipendenze server API...", 10, "npm install in " & $sRoot & "\server")
_RunWait('cmd.exe /c npm install --quiet', $sRoot & '\server')

; ── STEP 2: npm install frontend ─────────────────────────────
_Step("Installazione dipendenze frontend...", 50, "npm install in " & $sRoot & "\frontend")
_RunWait('cmd.exe /c npm install --legacy-peer-deps --quiet', $sRoot & '\frontend')

; ── STEP 3: Collegamento desktop ─────────────────────────────
_Step("Creazione collegamento desktop...", 90, "GesClo.lnk sul Desktop")
Local $sDesktop = @DesktopDir
Local $oShell = ObjCreate("WScript.Shell")
If IsObj($oShell) Then
    Local $oLink = $oShell.CreateShortcut($sDesktop & "\GesClo.lnk")
    $oLink.TargetPath = $sRoot & "\GesClo-Launcher.exe"
    $oLink.WorkingDirectory = $sRoot
    $oLink.IconLocation = $sRoot & "\GesClo.ico, 0"
    $oLink.Description = "Avvia GesClo - Gestionale"
    $oLink.WindowStyle = 7
    $oLink.Save()
    GUICtrlSetData($lblDetail, "Collegamento creato sul Desktop")
Else
    GUICtrlSetData($lblDetail, "Collegamento non creato (errore COM)")
EndIf
Sleep(800)

; ── DONE ─────────────────────────────────────────────────────
_Step("Configurazione completata!", 100, "Avvia GesClo con avvia.bat o dal Desktop")
GUICtrlSetColor($lblStatus, 0x4FCB71)
Sleep(2500)
GUIDelete($hGUI)
Exit 0

Func _Step($sText, $iPercent, $sDetail)
    GUICtrlSetData($lblStatus, $sText)
    GUICtrlSetData($hProg, $iPercent)
    GUICtrlSetData($lblDetail, $sDetail)
EndFunc

Func _RunWait($sCmd, $sWorkDir)
    Local $iPID = Run($sCmd, $sWorkDir, @SW_HIDE)
    While ProcessExists($iPID)
        Sleep(300)
    WEnd
EndFunc
