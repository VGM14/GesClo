@echo off
set "ROOT=%~dp0"
if "%ROOT:~-1%"=="\" set "ROOT=%ROOT:~0,-1%"

if exist "%ROOT%\GesClo-Setup.exe" (
    start "" "%ROOT%\GesClo-Setup.exe" "%ROOT%"
    exit /b 0
)

:: Fallback se l'exe non esiste
title GesClo - Prerequisiti
color 0A

net session >nul 2>&1
if not %errorlevel% == 0 (
    echo Riavvio come amministratore...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

echo.
echo =========================================
echo  GesClo - Installazione prerequisiti
echo =========================================
echo.

echo [1/2] Node.js...
node --version >nul 2>&1
if %errorlevel% == 0 (
    echo  Node.js gia installato - OK
    goto npm
)
set INST=%ROOT%\installers
if not exist "%INST%\node.msi" goto errornode
echo  Installo Node.js...
start /wait msiexec /i "%INST%\node.msi" /quiet /norestart
echo  OK - Node.js installato
goto npm
:errornode
echo  ERRORE: node.msi non trovato in installers\
pause & exit /b 1

:npm
echo [2/2] Dipendenze npm...
echo  Installo dipendenze server API...
call npm install --prefix "%ROOT%\server" --quiet
echo  Installo dipendenze frontend...
call npm install --prefix "%ROOT%\frontend" --legacy-peer-deps --quiet
echo  OK - Dipendenze installate

echo.
echo =========================================
echo  Prerequisiti OK!
echo  Avvia GesClo con avvia.bat
echo =========================================
pause
exit /b 0
