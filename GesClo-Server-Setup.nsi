;---------------------------------------------------
; GesClo Server Installer v2.0
; Stack: Node.js + Express + React + Clerk
;---------------------------------------------------

!include "MUI2.nsh"
!include "LogicLib.nsh"

Name "GesClo"
OutFile "GesClo-Server-Setup.exe"
InstallDir "C:\GesClo"
InstallDirRegKey HKCU "Software\GesClo" "InstallDir"
RequestExecutionLevel admin
Unicode True

VIProductVersion "2.0.0.0"
VIAddVersionKey "ProductName" "GesClo"
VIAddVersionKey "ProductVersion" "2.0.0"
VIAddVersionKey "FileDescription" "GesClo - Gestionale"
VIAddVersionKey "LegalCopyright" "GesClo"

!define MUI_ABORTWARNING
!define MUI_ICON "GesClo.ico"
!define MUI_UNICON "GesClo.ico"
!define MUI_WELCOMEFINISHPAGE_BITMAP "welcome.bmp"
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_BITMAP "header.bmp"
!define MUI_HEADERIMAGE_RIGHT

!define MUI_WELCOMEPAGE_TITLE "Benvenuto in GesClo"
!define MUI_WELCOMEPAGE_TEXT "Questo wizard installera GesClo sul tuo computer.$\r$\n$\r$\nGesClo e un gestionale che include:$\r$\n$\r$\n- API Server Node.js (porta 3001)$\r$\n- Interfaccia web React (porta 3000)$\r$\n- Autenticazione sicura via Clerk$\r$\n- Supporto NFC / POS contactless$\r$\n$\r$\nClicca Avanti per continuare."

!define MUI_FINISHPAGE_TITLE "Installazione completata!"
!define MUI_FINISHPAGE_TEXT "GesClo e stato installato in $INSTDIR.$\r$\n$\r$\nClicca Fine per installare le dipendenze npm."
!define MUI_FINISHPAGE_RUN "$INSTDIR\GesClo-Setup.exe"
!define MUI_FINISHPAGE_RUN_TEXT "Installa dipendenze npm adesso"

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_DIRECTORY
Page custom ComponentsPage ComponentsLeave
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

!insertmacro MUI_LANGUAGE "Italian"

Var CreateDesktop
Var CreateStartMenu
Var AutoStart

Function ComponentsPage
  nsDialogs::Create 1018
  Pop $0
  ${If} $0 == error
    Abort
  ${EndIf}
  ${NSD_CreateLabel} 0 0 100% 16u "Seleziona i collegamenti da creare:"
  Pop $0
  ${NSD_CreateCheckbox} 10u 22u 100% 12u "Crea icona sul Desktop"
  Pop $CreateDesktop
  ${NSD_Check} $CreateDesktop
  ${NSD_CreateCheckbox} 10u 40u 100% 12u "Aggiungi al menu Start"
  Pop $CreateStartMenu
  ${NSD_Check} $CreateStartMenu
  ${NSD_CreateCheckbox} 10u 58u 100% 12u "Avvia automaticamente con Windows"
  Pop $AutoStart
  nsDialogs::Show
FunctionEnd

Function ComponentsLeave
  ${NSD_GetState} $CreateDesktop $CreateDesktop
  ${NSD_GetState} $CreateStartMenu $CreateStartMenu
  ${NSD_GetState} $AutoStart $AutoStart
FunctionEnd

Section "GesClo" SecMain
  SectionIn RO

  DetailPrint "Copia file GesClo..."

  SetOutPath "$INSTDIR\frontend"
  File /r /x "node_modules" "frontend\*.*"
  File "frontend\.env"

  SetOutPath "$INSTDIR\server"
  File /r /x "node_modules" "server\*.*"
  File "server\.env"

  SetOutPath "$INSTDIR\installers"
  File "installers\node.msi"

  SetOutPath "$INSTDIR"
  File "avvia.bat"
  File "ferma.bat"
  File "under.bat"
  File "GesClo.ico"
  File "GesClo-Setup.au3"
  File "GesClo-Setup.exe"
  File "GesClo-Launcher.au3"
  File "GesClo.exe"
  File "crea-collegamento.bat"

  ; ── Node.js (opzionale, se non presente) ─────────────────────
  DetailPrint "Verifica Node.js..."
  nsExec::ExecToStack 'node --version'
  Pop $0
  ${If} $0 != 0
    DetailPrint "Node.js non trovato - installalo manualmente da https://nodejs.org"
  ${Else}
    DetailPrint "Node.js gia presente - OK"
  ${EndIf}

  ; ── Firewall ─────────────────────────────────────────────────
  DetailPrint "Apertura porte firewall..."
  nsExec::ExecToLog 'netsh advfirewall firewall delete rule name="GesClo API"'
  nsExec::ExecToLog 'netsh advfirewall firewall delete rule name="GesClo Frontend"'
  nsExec::ExecToLog 'netsh advfirewall firewall add rule name="GesClo API" dir=in action=allow protocol=TCP localport=3001'
  nsExec::ExecToLog 'netsh advfirewall firewall add rule name="GesClo Frontend" dir=in action=allow protocol=TCP localport=3000'

  ; ── Registry ─────────────────────────────────────────────────
  WriteRegStr HKCU "Software\GesClo" "InstallDir" "$INSTDIR"
  WriteRegStr HKCU "Software\GesClo" "Version"    "2.0.0"
  WriteUninstaller "$INSTDIR\Uninstall-GesClo.exe"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\GesClo" "DisplayName"     "GesClo"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\GesClo" "UninstallString" "$INSTDIR\Uninstall-GesClo.exe"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\GesClo" "Publisher"       "GesClo"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\GesClo" "DisplayVersion"  "2.0.0"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\GesClo" "DisplayIcon"     "$INSTDIR\GesClo.ico"

  DetailPrint "Installazione completata!"
SectionEnd

Section "-Shortcuts"
  ${If} $CreateDesktop == ${BST_CHECKED}
    CreateShortcut "$DESKTOP\GesClo.lnk" "$INSTDIR\GesClo.exe" "" "$INSTDIR\GesClo.ico" 0
  ${EndIf}
  ${If} $CreateStartMenu == ${BST_CHECKED}
    CreateDirectory "$SMPROGRAMS\GesClo"
    CreateShortcut "$SMPROGRAMS\GesClo\Avvia GesClo.lnk" "$INSTDIR\GesClo.exe" "" "$INSTDIR\GesClo.ico" 0
    CreateShortcut "$SMPROGRAMS\GesClo\Ferma GesClo.lnk" "$INSTDIR\ferma.bat" "" "$INSTDIR\GesClo.ico" 0
    CreateShortcut "$SMPROGRAMS\GesClo\Disinstalla.lnk"  "$INSTDIR\Uninstall-GesClo.exe"
  ${EndIf}
  ${If} $AutoStart == ${BST_CHECKED}
    WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Run" "GesClo" '"$INSTDIR\GesClo.exe"'
  ${EndIf}
SectionEnd

Section "Uninstall"
  ExecWait '"$INSTDIR\ferma.bat"'
  nsExec::ExecToLog 'netsh advfirewall firewall delete rule name="GesClo API"'
  nsExec::ExecToLog 'netsh advfirewall firewall delete rule name="GesClo Frontend"'
  RMDir /r "$INSTDIR\frontend"
  RMDir /r "$INSTDIR\server"
  RMDir /r "$INSTDIR\installers"
  Delete "$INSTDIR\avvia.bat"
  Delete "$INSTDIR\ferma.bat"
  Delete "$INSTDIR\under.bat"
  Delete "$INSTDIR\GesClo.ico"
  Delete "$INSTDIR\GesClo-Setup.au3"
  Delete "$INSTDIR\GesClo-Setup.exe"
  Delete "$INSTDIR\GesClo-Launcher.au3"
  Delete "$INSTDIR\GesClo.exe"
  Delete "$INSTDIR\crea-collegamento.bat"
  Delete "$INSTDIR\gesclo.db.json"
  Delete "$INSTDIR\gesclo.supplement.json"
  Delete "$INSTDIR\Uninstall-GesClo.exe"
  RMDir "$INSTDIR"
  Delete "$DESKTOP\GesClo.lnk"
  RMDir /r "$SMPROGRAMS\GesClo"
  DeleteRegKey HKCU "Software\GesClo"
  DeleteRegKey HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\GesClo"
  DeleteRegValue HKCU "Software\Microsoft\Windows\CurrentVersion\Run" "GesClo"
SectionEnd
