;---------------------------------------------------
; GesClo Configurator
; Chiede le chiavi Clerk, scrive i .env,
; poi compila GesClo-Server-Setup.nsi per generare
; l'installer personalizzato
;---------------------------------------------------

!include "MUI2.nsh"
!include "LogicLib.nsh"
!include "nsDialogs.nsh"

Name "GesClo Configurator"
OutFile "GesClo-Configurator.exe"
InstallDir "$TEMP\GesClo-Config"
RequestExecutionLevel user
Unicode True

!define MUI_ICON "GesClo.ico"
!define MUI_WELCOMEFINISHPAGE_BITMAP "welcome.bmp"
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_BITMAP "header.bmp"
!define MUI_HEADERIMAGE_RIGHT

!define MUI_WELCOMEPAGE_TITLE "GesClo Configurator"
!define MUI_WELCOMEPAGE_TEXT "Questo tool genera un installer GesClo personalizzato con le tue chiavi.$\r$\n$\r$\nInserisci le chiavi del tuo account Clerk e verra generato:$\r$\n$\r$\n- GesClo-Server-Setup.exe (installer)$\r$\n- GesClo.zip (archivio completo)$\r$\n$\r$\nLe chiavi AI si configurano dopo, dal pannello Admin.$\r$\n$\r$\nClicca Avanti per continuare."

!define MUI_FINISHPAGE_TITLE "Generazione completata!"
!define MUI_FINISHPAGE_TEXT "I file personalizzati sono stati generati.$\r$\n$\r$\nClicca Fine per aprire la cartella di output."
!define MUI_FINISHPAGE_RUN
!define MUI_FINISHPAGE_RUN_TEXT "Apri cartella output"
!define MUI_FINISHPAGE_RUN_FUNCTION OpenOutput

!insertmacro MUI_PAGE_WELCOME
Page custom PageClerkKeys PageClerkKeysLeave
Page custom PageOutput PageOutputLeave
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_LANGUAGE "Italian"

; ── Variabili ─────────────────────────────────────────────────
Var ClerkPubKey
Var ClerkSecKey
Var ServerPort
Var NfcApiKey
Var OutputDir
Var PackageMode
Var hPackageDev
Var hPackageClient
Var hPubKey
Var hSecKey
Var hPort
Var hNfcKey
Var hOutputDir

; ── Pagina Chiavi ─────────────────────────────────────────────
Function PageClerkKeys
  !insertmacro MUI_HEADER_TEXT "Chiavi Clerk" "Inserisci le chiavi del tuo account Clerk"
  nsDialogs::Create 1018
  Pop $0

  ${NSD_CreateLabel} 0 0 100% 12u "CLERK PUBLISHABLE KEY (pk_test_... o pk_live_...)"
  Pop $0
  ${NSD_CreateText} 0 14u 100% 13u "$ClerkPubKey"
  Pop $hPubKey

  ${NSD_CreateLabel} 0 38u 100% 12u "CLERK SECRET KEY (sk_test_... o sk_live_...)"
  Pop $0
  ${NSD_CreateText} 0 52u 100% 13u "$ClerkSecKey"
  Pop $hSecKey
  SendMessage $hSecKey ${EM_SETPASSWORDCHAR} 42 0

  ${NSD_CreateLabel} 0 78u 40% 12u "PORTA SERVER (default 3001)"
  Pop $0
  ${NSD_CreateText} 0 92u 25% 13u "3001"
  Pop $hPort

  ${NSD_CreateLabel} 40% 78u 60% 12u "NFC / POS API KEY (opzionale)"
  Pop $0
  ${NSD_CreateText} 40% 92u 60% 13u ""
  Pop $hNfcKey

  ${NSD_CreateLabel} 0 116u 100% 12u "Le chiavi si trovano su clerk.com > Dashboard > API Keys"
  Pop $0

  nsDialogs::Show
FunctionEnd

Function PageClerkKeysLeave
  ${NSD_GetText} $hPubKey $ClerkPubKey
  ${NSD_GetText} $hSecKey $ClerkSecKey
  ${NSD_GetText} $hPort $ServerPort
  ${NSD_GetText} $hNfcKey $NfcApiKey

  ${If} $ClerkPubKey == ""
    MessageBox MB_OK|MB_ICONEXCLAMATION "Inserisci la Clerk Publishable Key!"
    Abort
  ${EndIf}
  ${If} $ClerkSecKey == ""
    MessageBox MB_OK|MB_ICONEXCLAMATION "Inserisci la Clerk Secret Key!"
    Abort
  ${EndIf}
  ${If} $ServerPort == ""
    StrCpy $ServerPort "3001"
  ${EndIf}
FunctionEnd

; ── Pagina Output ─────────────────────────────────────────────
Function PageOutput
  !insertmacro MUI_HEADER_TEXT "Tipo pacchetto e output" "Scegli cosa generare e dove salvarlo"
  nsDialogs::Create 1018
  Pop $0

  ${NSD_CreateLabel} 0 0 100% 12u "Tipo di pacchetto:"
  Pop $0

  ${NSD_CreateRadioButton} 10u 16u 100% 12u "Client — solo installer server + app Tauri (per il cliente finale)"
  Pop $hPackageClient
  ${NSD_Check} $hPackageClient

  ${NSD_CreateRadioButton} 10u 32u 100% 12u "Sviluppatore — ZIP completo con sorgenti, app Android, Tauri"
  Pop $hPackageDev

  ${NSD_CreateLabel} 0 56u 100% 12u "Cartella output:"
  Pop $0
  ${NSD_CreateDirRequest} 0 70u 84% 13u "$DESKTOP\GesClo-Output"
  Pop $hOutputDir
  ${NSD_CreateBrowseButton} 86% 69u 14% 15u "..."
  Pop $0
  ${NSD_OnClick} $0 OnBrowseOutput

  nsDialogs::Show
FunctionEnd

Function OnBrowseOutput
  nsDialogs::SelectFolderDialog "Seleziona cartella output" "$DESKTOP"
  Pop $0
  ${If} $0 != error
    ${NSD_SetText} $hOutputDir $0
  ${EndIf}
FunctionEnd

Function PageOutputLeave
  ${NSD_GetText} $hOutputDir $OutputDir
  ${If} $OutputDir == ""
    StrCpy $OutputDir "$DESKTOP\GesClo-Output"
  ${EndIf}
  ${NSD_GetState} $hPackageDev $PackageMode
FunctionEnd

; ── Generazione ───────────────────────────────────────────────
Section "Genera"
  SectionIn RO

  ; ── Estrai file in cartella temp ─────────────────────────────
  DetailPrint "Estrazione file GesClo..."

  ; Server + Frontend (servono sempre per compilare l'installer)
  SetOutPath "$INSTDIR\GesClo\frontend"
  File /r /x "node_modules" /x ".env" "frontend\*.*"

  SetOutPath "$INSTDIR\GesClo\server"
  File /r /x "node_modules" /x ".env" "server\*.*"

  SetOutPath "$INSTDIR\GesClo\installers"
  File "installers\node.msi"

  ; ── Solo sviluppatore: sorgenti ──────────────────────────────
  ${If} $PackageMode == ${BST_CHECKED}
    SetOutPath "$INSTDIR\GesClo\android-pos"
    File /r /x "build" /x ".gradle" "android-pos\*.*"

    SetOutPath "$INSTDIR\GesClo\android-nfc"
    File /r /x "build" /x ".gradle" "android-nfc\*.*"

    SetOutPath "$INSTDIR\GesClo\gesclo-app"
    File /r /x "node_modules" /x "target" "gesclo-app\*.*"
  ${EndIf}

  ; File root
  SetOutPath "$INSTDIR\GesClo"
  File "avvia.bat"
  File "ferma.bat"
  File "under.bat"
  File "GesClo.ico"
  File "GesClo-Setup.au3"
  File "GesClo-Setup.exe"
  File "GesClo-Launcher.au3"
  File "GesClo.exe"
  File "crea-collegamento.bat"
  File "GesClo-Server-Setup.nsi"
  File "header.bmp"
  File "welcome.bmp"

  ; ── Scrivi .env personalizzati ──────────────────────────────
  DetailPrint "Scrittura chiavi personalizzate..."

  FileOpen $0 "$INSTDIR\GesClo\frontend\.env" w
  FileWrite $0 "VITE_CLERK_PUBLISHABLE_KEY=$ClerkPubKey"
  FileClose $0

  FileOpen $0 "$INSTDIR\GesClo\server\.env" w
  FileWrite $0 "CLERK_SECRET_KEY=$ClerkSecKey$\r$\nPORT=$ServerPort"
  ${If} $NfcApiKey != ""
    FileWrite $0 "$\r$\nNFC_API_KEY=$NfcApiKey"
  ${EndIf}
  FileClose $0

  ${If} $NfcApiKey != ""
    FileOpen $0 "$INSTDIR\GesClo\gesclo.supplement.json" w
    FileWrite $0 '{"settings":{"nfc_api_key":"$NfcApiKey"},"cashRegister":{"name":"Cassa principale","printer_type":"epson_a4","header_text":"GesClo","footer_text":"Grazie!","show_tax":false,"tax_rate":22,"currency":"EUR"},"sales":[],"saleCounter":0}'
    FileClose $0
  ${EndIf}

  ; ── Crea cartella output ────────────────────────────────────
  CreateDirectory "$OutputDir"

  ; ── Genera ZIP ──────────────────────────────────────────────
  ${If} $PackageMode == ${BST_CHECKED}
    ; SVILUPPATORE: ZIP completo con tutto
    DetailPrint "Creazione ZIP sviluppatore..."
    FileOpen $0 "$INSTDIR\makezip.ps1" w
    FileWrite $0 "Add-Type -AssemblyName System.IO.Compression.FileSystem$\r$\n"
    FileWrite $0 "$$src = '$INSTDIR\GesClo'$\r$\n"
    FileWrite $0 "$$dst = '$OutputDir\GesClo-Dev.zip'$\r$\n"
    FileWrite $0 "if (Test-Path $$dst) { Remove-Item $$dst -Force }$\r$\n"
    FileWrite $0 "[System.IO.Compression.ZipFile]::CreateFromDirectory($$src, $$dst)$\r$\n"
    FileClose $0
    nsExec::ExecToLog 'powershell -NoProfile -ExecutionPolicy Bypass -File "$INSTDIR\makezip.ps1"'
    Delete "$INSTDIR\makezip.ps1"
  ${Else}
    ; CLIENT: installer server + Tauri + APK + .env
    DetailPrint "Creazione ZIP client..."
    CreateDirectory "$INSTDIR\Client"

    ; Installer server (pre-compilato, embeddato)
    SetOutPath "$INSTDIR\Client"
    File "GesClo-Server-Setup.exe"
    File "GesClo-Client-Portable.exe"
    File "GesClo-Client-Setup.exe"
    File "GesClo-POS.apk"
    File "GesClo.ico"

    ; .env personalizzati
    CreateDirectory "$INSTDIR\Client\env"

    FileOpen $0 "$INSTDIR\Client\env\frontend.env" w
    FileWrite $0 "VITE_CLERK_PUBLISHABLE_KEY=$ClerkPubKey"
    FileClose $0

    FileOpen $0 "$INSTDIR\Client\env\server.env" w
    FileWrite $0 "CLERK_SECRET_KEY=$ClerkSecKey$\r$\nPORT=$ServerPort"
    ${If} $NfcApiKey != ""
      FileWrite $0 "$\r$\nNFC_API_KEY=$NfcApiKey"
    ${EndIf}
    FileClose $0

    ; Script che fa tutto: installa + copia .env
    FileOpen $0 "$INSTDIR\Client\Installa-GesClo.bat" w
    FileWrite $0 "@echo off$\r$\n"
    FileWrite $0 "title GesClo - Installazione$\r$\n"
    FileWrite $0 "color 0A$\r$\n"
    FileWrite $0 "echo =========================================$\r$\n"
    FileWrite $0 "echo  GesClo - Installazione$\r$\n"
    FileWrite $0 "echo =========================================$\r$\n"
    FileWrite $0 "echo.$\r$\n"
    FileWrite $0 "echo [1/3] Avvio installer server...$\r$\n"
    FileWrite $0 'start /wait "" "%~dp0GesClo-Server-Setup.exe"$\r$\n'
    FileWrite $0 "echo.$\r$\n"
    FileWrite $0 "echo [2/3] Configurazione chiavi...$\r$\n"
    FileWrite $0 'set "INST=C:\GesClo"$\r$\n'
    FileWrite $0 'if not exist "%INST%" set /p INST="Cartella installazione: "$\r$\n'
    FileWrite $0 'copy /y "%~dp0env\frontend.env" "%INST%\frontend\.env" >nul$\r$\n'
    FileWrite $0 'copy /y "%~dp0env\server.env" "%INST%\server\.env" >nul$\r$\n'
    FileWrite $0 "echo Chiavi configurate!$\r$\n"
    FileWrite $0 "echo.$\r$\n"
    FileWrite $0 "echo [3/3] Installazione dipendenze...$\r$\n"
    FileWrite $0 'if exist "%INST%\GesClo-Setup.exe" start "" "%INST%\GesClo-Setup.exe"$\r$\n'
    FileWrite $0 "echo.$\r$\n"
    FileWrite $0 "echo =========================================$\r$\n"
    FileWrite $0 "echo  Installazione completata!$\r$\n"
    FileWrite $0 "echo =========================================$\r$\n"
    FileWrite $0 "pause$\r$\n"
    FileClose $0

    FileOpen $0 "$INSTDIR\makezip.ps1" w
    FileWrite $0 "Add-Type -AssemblyName System.IO.Compression.FileSystem$\r$\n"
    FileWrite $0 "$$src = '$INSTDIR\Client'$\r$\n"
    FileWrite $0 "$$dst = '$OutputDir\GesClo.zip'$\r$\n"
    FileWrite $0 "if (Test-Path $$dst) { Remove-Item $$dst -Force }$\r$\n"
    FileWrite $0 "[System.IO.Compression.ZipFile]::CreateFromDirectory($$src, $$dst)$\r$\n"
    FileClose $0
    nsExec::ExecToLog 'powershell -NoProfile -ExecutionPolicy Bypass -File "$INSTDIR\makezip.ps1"'
    Delete "$INSTDIR\makezip.ps1"
  ${EndIf}

  ; ── Pulizia ─────────────────────────────────────────────────
  DetailPrint "Pulizia file temporanei..."
  RMDir /r "$INSTDIR"

  DetailPrint "Completato! File in: $OutputDir"
SectionEnd

Function OpenOutput
  ExecShell "open" "$OutputDir"
FunctionEnd
