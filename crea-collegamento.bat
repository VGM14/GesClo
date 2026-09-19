@echo off
set "ROOT=%~dp0"
if "%ROOT:~-1%"=="\" set "ROOT=%ROOT:~0,-1%"

powershell -Command "$ws = New-Object -ComObject WScript.Shell; $s = $ws.CreateShortcut([Environment]::GetFolderPath('Desktop') + '\GesClo.lnk'); $s.TargetPath = '%ROOT%\dist-electron\win-unpacked\GesClo.exe'; $s.WorkingDirectory = '%ROOT%\dist-electron\win-unpacked'; $s.IconLocation = '%ROOT%\GesClo.ico, 0'; $s.Description = 'Avvia GesClo - Gestionale'; $s.Save(); Write-Host 'OK'"

echo.
echo  Collegamento "GesClo" creato sul Desktop!
echo.
timeout /t 3 /nobreak >nul
