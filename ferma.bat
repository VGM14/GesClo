@echo off
title GesClo - Arresto
color 0C

echo =========================================
echo  GesClo - Arresto servizi
echo =========================================
echo.

taskkill /f /fi "WINDOWTITLE eq GesClo API*"      >nul 2>&1
taskkill /f /fi "WINDOWTITLE eq GesClo Frontend*" >nul 2>&1
taskkill /f /fi "WINDOWTITLE eq GesClo Launcher*" >nul 2>&1
taskkill /f /im node.exe                          >nul 2>&1

echo GesClo fermato.
echo.
pause
exit /b 0
