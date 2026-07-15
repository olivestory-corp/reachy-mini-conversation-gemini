@echo off
chcp 65001 >nul
echo ──────────────────────────────────────────
echo   Reachy Mini 대화앱 종료
echo ──────────────────────────────────────────
echo [1/2] 대화앱 + 데몬 프로세스 종료...

REM 데몬 창(제목 기반) 종료
taskkill /F /FI "WINDOWTITLE eq Reachy 데몬*" >nul 2>&1

REM reachy 관련 프로세스를 커맨드라인으로 찾아 종료 (venv python + 콘솔 스크립트 + 데몬)
powershell -NoProfile -Command "Get-CimInstance Win32_Process | Where-Object { $_.CommandLine -match 'reachy_mini_conversation_app|reachy-mini-conversation-app|reachy-mini-daemon' } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }" 2>nul

echo [2/2] 완료.
echo 🔴 전체 종료 완료.
pause
