#NoTrayIcon
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <EditConstants.au3>

; ── Estrai template alla prima esecuzione ─────────────────────
Local $sTempZip = @TempDir & "\GesClo-Template.zip"
If Not FileExists($sTempZip) Or FileGetSize($sTempZip) < 1000 Then
    FileInstall("GesClo-Template.zip", $sTempZip, 1)
EndIf

; ── GUI ───────────────────────────────────────────────────────
Local $hGUI = GUICreate("GesClo - Configuratore", 520, 500, -1, -1, $WS_CAPTION + $WS_SYSMENU)
GUISetBkColor(0x1A1A2E)

GUICtrlCreateLabel("GesClo Configurator", 20, 14, 480, 32)
GUICtrlSetFont(-1, 18, 700, 0, "Segoe UI")
GUICtrlSetColor(-1, 0x4F8EF7)

GUICtrlCreateLabel("Genera un installer personalizzato con le tue chiavi", 20, 48, 480, 16)
GUICtrlSetFont(-1, 8, 400, 0, "Segoe UI")
GUICtrlSetColor(-1, 0x888888)

; ── Clerk Publishable Key ─────────────────────────────────────
GUICtrlCreateLabel("CLERK PUBLISHABLE KEY *", 20, 80, 480, 14)
GUICtrlSetFont(-1, 8, 400, 0, "Segoe UI")
GUICtrlSetColor(-1, 0x888888)
Local $inPubKey = GUICtrlCreateInput("", 20, 96, 480, 28)
GUICtrlSetFont(-1, 9, 400, 0, "Consolas")
GUICtrlSetColor(-1, 0xE6EDF3)
GUICtrlSetBkColor(-1, 0x161B22)

; ── Clerk Secret Key ──────────────────────────────────────────
GUICtrlCreateLabel("CLERK SECRET KEY *", 20, 132, 480, 14)
GUICtrlSetFont(-1, 8, 400, 0, "Segoe UI")
GUICtrlSetColor(-1, 0x888888)
Local $inSecKey = GUICtrlCreateInput("", 20, 148, 480, 28, $ES_PASSWORD)
GUICtrlSetFont(-1, 9, 400, 0, "Consolas")
GUICtrlSetColor(-1, 0xE6EDF3)
GUICtrlSetBkColor(-1, 0x161B22)

; ── Porta server ──────────────────────────────────────────────
GUICtrlCreateLabel("PORTA SERVER", 20, 184, 120, 14)
GUICtrlSetFont(-1, 8, 400, 0, "Segoe UI")
GUICtrlSetColor(-1, 0x888888)
Local $inPort = GUICtrlCreateInput("3001", 20, 200, 100, 28)
GUICtrlSetFont(-1, 9, 400, 0, "Consolas")
GUICtrlSetColor(-1, 0xE6EDF3)
GUICtrlSetBkColor(-1, 0x161B22)

; ── NFC API Key ───────────────────────────────────────────────
GUICtrlCreateLabel("NFC API KEY (opzionale)", 160, 184, 340, 14)
GUICtrlSetFont(-1, 8, 400, 0, "Segoe UI")
GUICtrlSetColor(-1, 0x888888)
Local $inNfcKey = GUICtrlCreateInput("", 160, 200, 340, 28)
GUICtrlSetFont(-1, 9, 400, 0, "Consolas")
GUICtrlSetColor(-1, 0xE6EDF3)
GUICtrlSetBkColor(-1, 0x161B22)

; ── Cartella output ───────────────────────────────────────────
GUICtrlCreateLabel("CARTELLA OUTPUT", 20, 240, 480, 14)
GUICtrlSetFont(-1, 8, 400, 0, "Segoe UI")
GUICtrlSetColor(-1, 0x888888)
Local $inOutput = GUICtrlCreateInput(@DesktopDir & "\GesClo-Personalizzato", 20, 256, 400, 28)
GUICtrlSetFont(-1, 9, 400, 0, "Consolas")
GUICtrlSetColor(-1, 0xE6EDF3)
GUICtrlSetBkColor(-1, 0x161B22)
Local $btnBrowse = GUICtrlCreateButton("...", 424, 256, 76, 28)

; ── Exe AutoIt (opzionali) ────────────────────────────────────
GUICtrlCreateLabel("EXE AUTOIT (opzionale - trascina i file compilati)", 20, 296, 480, 14)
GUICtrlSetFont(-1, 8, 400, 0, "Segoe UI")
GUICtrlSetColor(-1, 0x888888)

GUICtrlCreateLabel("Launcher:", 20, 316, 60, 14)
GUICtrlSetFont(-1, 8, 400, 0, "Segoe UI")
GUICtrlSetColor(-1, 0x666666)
Local $inLauncherExe = GUICtrlCreateInput("", 82, 312, 340, 24)
GUICtrlSetFont(-1, 8, 400, 0, "Consolas")
GUICtrlSetColor(-1, 0xE6EDF3)
GUICtrlSetBkColor(-1, 0x161B22)
Local $btnLauncher = GUICtrlCreateButton("...", 426, 312, 74, 24)

GUICtrlCreateLabel("Setup:", 20, 344, 60, 14)
GUICtrlSetFont(-1, 8, 400, 0, "Segoe UI")
GUICtrlSetColor(-1, 0x666666)
Local $inSetupExe = GUICtrlCreateInput("", 82, 340, 340, 24)
GUICtrlSetFont(-1, 8, 400, 0, "Consolas")
GUICtrlSetColor(-1, 0xE6EDF3)
GUICtrlSetBkColor(-1, 0x161B22)
Local $btnSetup = GUICtrlCreateButton("...", 426, 340, 74, 24)

; ── Status + Progress ─────────────────────────────────────────
Local $lblStatus = GUICtrlCreateLabel("", 20, 380, 480, 18)
GUICtrlSetFont(-1, 9, 400, 0, "Segoe UI")
GUICtrlSetColor(-1, 0xCCCCCC)
Local $hProg = GUICtrlCreateProgress(20, 400, 480, 14)

; ── Pulsanti ──────────────────────────────────────────────────
Local $btnAll = GUICtrlCreateButton("Genera ZIP + Installer", 20, 426, 240, 44)
GUICtrlSetFont(-1, 11, 700, 0, "Segoe UI")
Local $btnZip = GUICtrlCreateButton("Solo ZIP", 270, 426, 110, 44)
GUICtrlSetFont(-1, 10, 400, 0, "Segoe UI")

GUICtrlCreateLabel("Le chiavi AI si configurano dopo, dal pannello Admin del gestionale.", 20, 478, 480, 14)
GUICtrlSetFont(-1, 7, 400, 0, "Segoe UI")
GUICtrlSetColor(-1, 0x444466)

GUISetState(@SW_SHOW)

; ── LOOP ──────────────────────────────────────────────────────
While 1
    Switch GUIGetMsg()
        Case $GUI_EVENT_CLOSE
            FileDelete($sTempZip)
            Exit
        Case $btnBrowse
            Local $f = FileSelectFolder("Cartella output", "", 7, GUICtrlRead($inOutput))
            If $f <> "" Then GUICtrlSetData($inOutput, $f)
        Case $btnLauncher
            Local $f2 = FileOpenDialog("GesClo-Launcher.exe", @DesktopDir, "Exe (*.exe)", 1)
            If $f2 <> "" Then GUICtrlSetData($inLauncherExe, $f2)
        Case $btnSetup
            Local $f3 = FileOpenDialog("GesClo-Setup.exe", @DesktopDir, "Exe (*.exe)", 1)
            If $f3 <> "" Then GUICtrlSetData($inSetupExe, $f3)
        Case $btnAll
            _Generate(True)
        Case $btnZip
            _Generate(False)
    EndSwitch
WEnd

; ── GENERAZIONE ───────────────────────────────────────────────
Func _Generate($bInstaller)
    Local $sPubKey  = StringStripWS(GUICtrlRead($inPubKey), 3)
    Local $sSecKey  = StringStripWS(GUICtrlRead($inSecKey), 3)
    Local $sPort    = StringStripWS(GUICtrlRead($inPort), 3)
    Local $sNfcKey  = StringStripWS(GUICtrlRead($inNfcKey), 3)
    Local $sOutDir  = StringStripWS(GUICtrlRead($inOutput), 3)
    Local $sLauncherExe = StringStripWS(GUICtrlRead($inLauncherExe), 3)
    Local $sSetupExe    = StringStripWS(GUICtrlRead($inSetupExe), 3)

    If $sPubKey = "" Or $sSecKey = "" Then
        GUICtrlSetData($lblStatus, "Inserisci le chiavi Clerk!")
        GUICtrlSetColor($lblStatus, 0xFF6666)
        Return
    EndIf
    If $sPort = "" Then $sPort = "3001"

    ; ── Estrai template ───────────────────────────────────────
    _Status("Estrazione template...", 5)
    Local $sWork = @TempDir & "\GesClo-Build-" & Random(1000, 9999, 1)
    DirCreate($sWork)

    Local $sPS = 'Add-Type -AssemblyName System.IO.Compression.FileSystem; '
    $sPS &= '[System.IO.Compression.ZipFile]::ExtractToDirectory("' & $sTempZip & '", "' & $sWork & '")'
    _RunWait('powershell -NoProfile -Command "' & $sPS & '"')

    Local $sGesclo = $sWork & "\GesClo"
    If Not FileExists($sGesclo) Then
        _Status("Errore: template non estratto", 0)
        GUICtrlSetColor($lblStatus, 0xFF6666)
        Return
    EndIf

    _Status("Scrittura chiavi...", 25)

    ; ── Scrivi .env ───────────────────────────────────────────
    FileWrite(FileOpen($sGesclo & "\frontend\.env", 2), "VITE_CLERK_PUBLISHABLE_KEY=" & $sPubKey)
    Local $sEnv = "CLERK_SECRET_KEY=" & $sSecKey & @CRLF & "PORT=" & $sPort
    If $sNfcKey <> "" Then $sEnv &= @CRLF & "NFC_API_KEY=" & $sNfcKey
    FileWrite(FileOpen($sGesclo & "\server\.env", 2), $sEnv)

    ; ── Scrivi supplement con NFC key ─────────────────────────
    If $sNfcKey <> "" Then
        Local $sSupp = '{"settings":{"nfc_api_key":"' & $sNfcKey & '"},"cashRegister":{"name":"Cassa principale","printer_type":"epson_a4","header_text":"GesClo","footer_text":"Grazie!","show_tax":false,"tax_rate":22,"currency":"EUR"},"sales":[],"saleCounter":0}'
        FileWrite(FileOpen($sGesclo & "\gesclo.supplement.json", 2), $sSupp)
    EndIf

    ; ── Copia exe AutoIt se forniti ───────────────────────────
    _Status("Copia exe personalizzati...", 35)
    If FileExists($sLauncherExe) Then FileCopy($sLauncherExe, $sGesclo & "\GesClo-Launcher.exe", 1)
    If FileExists($sSetupExe) Then FileCopy($sSetupExe, $sGesclo & "\GesClo-Setup.exe", 1)

    ; ── Crea cartella output ──────────────────────────────────
    If Not FileExists($sOutDir) Then DirCreate($sOutDir)

    ; ── Genera ZIP ────────────────────────────────────────────
    _Status("Creazione ZIP...", 45)
    Local $sZipOut = $sOutDir & "\GesClo.zip"
    If FileExists($sZipOut) Then FileDelete($sZipOut)
    $sPS = 'Add-Type -AssemblyName System.IO.Compression.FileSystem; '
    $sPS &= '[System.IO.Compression.ZipFile]::CreateFromDirectory("' & $sGesclo & '", "' & $sZipOut & '")'
    _RunWait('powershell -NoProfile -Command "' & $sPS & '"')
    _Status("ZIP creato: " & $sZipOut, 70)

    ; ── Compila NSIS ──────────────────────────────────────────
    If $bInstaller Then
        Local $sNSIS = "C:\Program Files (x86)\NSIS\makensis.exe"
        If FileExists($sNSIS) Then
            _Status("Compilazione installer NSIS...", 75)
            Local $sNSI = $sGesclo & "\GesClo-Server-Setup.nsi"
            If FileExists($sNSI) Then
                _RunWait('"' & $sNSIS & '" /V1 "' & $sNSI & '"')
                Local $sInstallerExe = $sGesclo & "\GesClo-Server-Setup.exe"
                If FileExists($sInstallerExe) Then
                    FileCopy($sInstallerExe, $sOutDir & "\GesClo-Server-Setup.exe", 1)
                    _Status("Installer creato!", 95)
                Else
                    _Status("NSIS non ha generato l'exe", 90)
                    GUICtrlSetColor($lblStatus, 0xFFAA44)
                EndIf
            EndIf
        Else
            _Status("NSIS non installato — solo ZIP generato", 90)
            GUICtrlSetColor($lblStatus, 0xFFAA44)
        EndIf
    EndIf

    ; ── Pulizia ───────────────────────────────────────────────
    DirRemove($sWork, 1)

    _Status("Completato! Output: " & $sOutDir, 100)
    GUICtrlSetColor($lblStatus, 0x4FCB71)
    ShellExecute($sOutDir)
EndFunc

Func _Status($sText, $iPercent)
    GUICtrlSetData($lblStatus, $sText)
    GUICtrlSetColor($lblStatus, 0xCCCCCC)
    GUICtrlSetData($hProg, $iPercent)
EndFunc

Func _RunWait($sCmd)
    Local $iPID = Run($sCmd, @TempDir, @SW_HIDE)
    While ProcessExists($iPID)
        Sleep(300)
    WEnd
EndFunc
