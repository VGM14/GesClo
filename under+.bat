@echo off
setlocal
title GesClo - Installazione dipendenze
rem Da lanciare a fine installazione (anche con doppio clic):
rem   1. controlla che Node.js sia installato
rem   2. installa le librerie del server (serve internet)
rem   3. installa le librerie del frontend (se nella cartella c'e' frontend\package.json)
rem      Per ognuna verifica che l'installazione sia COMPLETA (ogni libreria presente e,
rem      per il frontend, Vite che parte); se non lo e' cancella node_modules e riprova.
rem   4. apre nel firewall di Windows le porte 3000 e 3001 per la rete locale
rem      (serve per usare GesClo da altri PC; richiede i diritti di amministratore:
rem       se non li ha, Windows mostra la sua richiesta di conferma. Se la rifiuti,
rem       tutto il resto funziona e GesClo si usa solo da questo PC)
rem   5. crea il collegamento "GesClo" sul Desktop:
rem        - se nella cartella c'e' avvia.bat, parte da avvia.bat
rem        - altrimenti parte da GesClo.vbs
rem Non chiede mai nulla e non aspetta tasti: con /silent chiude subito, senza /silent
rem lascia qualche secondo per leggere il risultato.
rem NB: la cartella di installazione deve essere scrivibile dall'utente (il server crea
rem     gesclo.sqlite accanto al programma): evita C:\Program Files.

set "ROOT=%~dp0"
if "%ROOT:~-1%"=="\" set "ROOT=%ROOT:~0,-1%"
set "WAIT=3"
if /i "%~1"=="/silent" set "WAIT=0"

echo =========================================
echo  GesClo - Installazione
echo =========================================
echo.

echo [1/5] Controllo Node.js...
node --version >nul 2>&1
if errorlevel 1 goto nonode
for /f "tokens=*" %%v in ('node --version') do echo  Node.js %%v - OK

echo [2/5] Installo le librerie del server...
set "D_DEV="
call :deps "%ROOT%\server" "--omit=dev"
if errorlevel 1 goto nonpm
echo  Librerie del server installate e verificate - OK

echo [3/5] Installo le librerie del frontend...
if not exist "%ROOT%\frontend\package.json" goto nofrontend
set "D_DEV=1"
call :deps "%ROOT%\frontend" "--legacy-peer-deps"
set "D_DEV="
if errorlevel 1 goto nofrontendlibs
echo  Librerie del frontend installate e verificate - OK
goto firewall

:nofrontend
echo  Cartella frontend non presente: passo saltato.
goto firewall

:nofrontendlibs
echo  ATTENZIONE: librerie del frontend non installate correttamente.
rem Senza di esse parte solo l'interfaccia gia' compilata (frontend\dist), quindi si
rem continua; se pero' si avvia da avvia.bat (che usa npm run dev) e' un errore.
if exist "%ROOT%\avvia.bat" goto nofrontendfatal

:firewall
echo [4/5] Apro le porte 3000 e 3001 nel firewall (solo rete locale)...
rem Una regola per porta (non per programma): vale anche se node.exe cambia percorso.
rem remoteip=localsubnet = accessibile solo dai PC della stessa rete, non da internet.
if defined GESCLO_SKIP_FIREWALL goto fwdone
net session >nul 2>&1
if errorlevel 1 goto fwelevate
netsh advfirewall firewall delete rule name=GesClo >nul 2>&1
netsh advfirewall firewall add rule name=GesClo dir=in action=allow protocol=TCP localport=3000,3001 profile=any remoteip=localsubnet >nul 2>&1
goto fwcheck

:fwelevate
set "FWCMD=netsh advfirewall firewall delete rule name=GesClo >nul 2>&1 & netsh advfirewall firewall add rule name=GesClo dir=in action=allow protocol=TCP localport=3000,3001 profile=any remoteip=localsubnet >nul 2>&1"
powershell -NoProfile -ExecutionPolicy Bypass -Command "try { Start-Process -FilePath $env:ComSpec -ArgumentList ('/c ' + $env:FWCMD) -Verb RunAs -Wait -WindowStyle Hidden } catch { exit 9 }" >nul 2>&1

:fwcheck
netsh advfirewall firewall show rule name=GesClo >nul 2>&1
if errorlevel 1 goto fwfail
echo  Firewall - OK
goto fwdone

:fwfail
echo  ATTENZIONE: firewall non configurato. GesClo funziona da questo PC ma non dagli altri.
echo  Per usarlo in rete rilancia questo file come amministratore.

:fwdone
echo [5/5] Creo il collegamento sul Desktop...
set "GESCLO_ROOT=%ROOT%"
if exist "%ROOT%\avvia.bat" (set "GESCLO_START=avvia.bat") else (set "GESCLO_START=GesClo.vbs")
echo  Il collegamento avviera' %GESCLO_START%
powershell -NoProfile -ExecutionPolicy Bypass -Command "$r=$env:GESCLO_ROOT; $d=$env:GESCLO_DESKTOP; if(-not $d){$d=[Environment]::GetFolderPath('Desktop')}; $s=(New-Object -ComObject WScript.Shell).CreateShortcut($d+'\GesClo.lnk'); if($env:GESCLO_START -eq 'avvia.bat'){ $s.TargetPath=$r+'\avvia.bat'; $s.Arguments=''; $s.WindowStyle=7 } else { $s.TargetPath=$env:SystemRoot+'\System32\wscript.exe'; $s.Arguments='\"'+$r+'\GesClo.vbs\"' }; $s.WorkingDirectory=$r; $s.IconLocation=$r+'\GesClo.ico'; $s.Description='GesClo'; $s.Save()"
if errorlevel 1 goto noshortcut
echo  Collegamento creato - OK

echo.
echo =========================================
echo  Installazione completata.
echo  Apri GesClo dal collegamento sul Desktop.
echo =========================================
if not "%WAIT%"=="0" timeout /t %WAIT% /nobreak >nul
exit /b 0

:nonode
echo.
echo  ERRORE: Node.js non trovato.
echo  Installa Node.js da https://nodejs.org e rilancia questo file.
if not "%WAIT%"=="0" timeout /t 15 /nobreak >nul
exit /b 1

:nonpm
echo.
echo  ERRORE: installazione delle librerie del server non riuscita.
echo  Serve internet e una cartella scrivibile (non C:\Program Files).
if not "%WAIT%"=="0" timeout /t 15 /nobreak >nul
exit /b 2

:noshortcut
echo.
echo  ERRORE: collegamento sul Desktop non creato.
if not "%WAIT%"=="0" timeout /t 15 /nobreak >nul
exit /b 3

:nofrontendfatal
echo.
echo  ERRORE: avvia.bat ha bisogno delle librerie del frontend e non si sono installate.
echo  Serve internet e una cartella scrivibile (non C:\Program Files).
if not "%WAIT%"=="0" timeout /t 15 /nobreak >nul
exit /b 4

rem ---------------------------------------------------------------------------
rem :deps <cartella> <opzioni npm>   (D_DEV=1 -> controlla anche le devDependencies)
rem Installa con npm ci (ripiega su npm install), verifica, e se l'installazione e'
rem incompleta cancella node_modules e riprova una volta. Restituisce 0 se tutto ok.
:deps
pushd "%~1"
if errorlevel 1 exit /b 1
call npm ci %~2 --no-audit --no-fund
if errorlevel 1 call npm install %~2 --no-audit --no-fund
call :verify
if errorlevel 1 (
  echo  Installazione incompleta: cancello node_modules e riprovo da zero...
  if exist node_modules rmdir /s /q node_modules
  call npm install %~2 --no-audit --no-fund
  call :verify
)
set "D_RES=%errorlevel%"
popd
exit /b %D_RES%

rem :verify  (nella cartella corrente) ogni libreria del package.json deve avere la sua
rem cartella in node_modules; per il frontend Vite deve anche partire.
:verify
if not exist node_modules exit /b 1
node -e "const fs=require('fs');const p=require('./package.json');const o=Object.assign({},p.dependencies,process.env.D_DEV?p.devDependencies:{});const m=Object.keys(o).filter(d=>!fs.existsSync('node_modules/'+d));if(m.length){console.log('  Mancano: '+m.join(', '));process.exit(1)}"
if errorlevel 1 exit /b 1
if defined D_DEV node node_modules\vite\bin\vite.js --version >nul 2>&1
exit /b %errorlevel%
