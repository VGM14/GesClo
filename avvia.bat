@echo off
title GesClo
color 0A

set "ROOT=%~dp0"
if "%ROOT:~-1%"=="\" set "ROOT=%ROOT:~0,-1%"

echo =========================================
echo  GesClo
echo =========================================
echo.

node --version >nul 2>&1
if errorlevel 1 goto nonode
for /f "tokens=*" %%v in ('node --version') do echo Node.js %%v OK

rem Dipendenze: se mancano (o sono incomplete) le installa da solo, senza fare nulla a mano.
set "NEEDDEPS="
if not exist "%ROOT%\server\node_modules\express" set "NEEDDEPS=1"
if not exist "%ROOT%\frontend\node_modules\vite\bin\vite.js" set "NEEDDEPS=1"
if not defined NEEDDEPS goto depsok

echo Dipendenze mancanti: le installo (serve internet, ci vuole un minuto)...
echo.
if exist "%ROOT%\under+.bat" goto depsunder

rem Senza under+.bat: installazione diretta.
pushd "%ROOT%\server"
call npm install --omit=dev --no-audit --no-fund
popd
pushd "%ROOT%\frontend"
call npm install --legacy-peer-deps --no-audit --no-fund
popd
goto depscheck

:depsunder
call "%ROOT%\under+.bat" /silent

:depscheck
if not exist "%ROOT%\server\node_modules\express" goto depsfail
if not exist "%ROOT%\frontend\node_modules\vite\bin\vite.js" goto depsfail
echo.

:depsok
echo Dipendenze OK
echo.

echo [1/3] Avvio launcher...
cd /d "%ROOT%\server"
start /b node launcher.js >nul 2>&1
timeout /t 2 /nobreak >nul

echo [2/3] Avvio server API...
start /b node server.js >nul 2>&1
timeout /t 4 /nobreak >nul

echo [3/3] Avvio frontend...
cd /d "%ROOT%\frontend"
start /b cmd /c "npm run dev >nul 2>&1"
timeout /t 6 /nobreak >nul

start http://localhost:3000

echo.
echo =========================================
echo  GesClo avviato!
echo  Gestionale:  http://localhost:3000
echo  API:         http://localhost:3001
echo =========================================
echo.
echo  I servizi girano in background.
echo  Per chiudere tutto: Admin - Sistema - Chiudi GesClo
echo  oppure esegui ferma.bat
echo.
pause
exit /b 0

:nonode
echo ERRORE: Node.js non trovato.
echo Installa Node.js da https://nodejs.org e riapri GesClo.
echo.
pause
exit /b 1

:depsfail
echo.
echo ERRORE: non sono riuscito a installare le dipendenze.
echo Servono internet e una cartella scrivibile (non C:\Program Files).
echo.
pause
exit /b 1
