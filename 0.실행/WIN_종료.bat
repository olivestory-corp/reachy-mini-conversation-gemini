@echo off
REM ===========================================================
REM  Reachy Mini Conversation App - STOP (Windows)
REM  Stops the conversation app and the robot daemon.
REM  NOTE: This file must stay ASCII-only. Korean text breaks
REM        cmd.exe batch parsing on Windows (codepage mismatch).
REM ===========================================================
echo ------------------------------------------
echo   Reachy Mini - stopping
echo ------------------------------------------
echo [1/2] Closing daemon window and processes...

REM Close the daemon window by its title
taskkill /F /FI "WINDOWTITLE eq Reachy Daemon*" >nul 2>&1

REM Kill reachy processes by command line (daemon + conversation app)
powershell -NoProfile -Command "Get-CimInstance Win32_Process | Where-Object { $_.CommandLine -match 'reachy_mini_conversation_app|reachy-mini-conversation-app|reachy-mini-daemon' } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }" 2>nul

echo [2/2] Done.
echo All stopped.
pause
