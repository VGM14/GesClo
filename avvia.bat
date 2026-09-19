@echo off
title GesClo
color 0A

set "ROOT=%~dp0"
if "%ROOT:~-1%"=="\" set "ROOT=%ROOT:~0,-1%"

echo =========================================
echo  GesClo v2.0 - Avvio
echo =========================================
echo.

node --version >nul 2>&1
if errorlevel 1 (
    echo ERRORE: Node.js non trovato.
    echo Esegui under.bat come amministratore per installarlo.
    echo.
    pause
    exit /b 1
)
for /f "tokens=*" %%v in ('node --version') do echo Node.js %%v OK

if not exist "%ROOT%\server\node_modules" (
    echo ERRORE: Dipendenze server mancanti.
    echo Esegui under.bat per installarle.
    echo.
    pause
    exit /b 1
)
echo Dipendenze server OK

if not exist "%ROOT%\frontend\node_modules" (
    echo ERRORE: Dipendenze frontend mancanti.
    echo Esegui under.bat per installarle.
    echo.
    pause
    exit /b 1
)
echo Dipendenze frontend OK

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
