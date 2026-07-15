@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
cd /d "%~dp0.."
set "ROOT=%CD%"

REM ═══════════════════════════════════════════════════════════
REM  Reachy Mini 대화앱 v0.8.0 (Gemini Live) - 시작 (Windows)
REM  Reachy Mini Control 앱 없이 CLI 데몬으로 직접 실행합니다.
REM  * Control 앱이 켜져 있으면 먼저 완전히 종료하세요 (:8000 충돌).
REM  * 이 폴더 경로에 한글/공백이 없는 곳에 두는 것을 권장합니다.
REM ═══════════════════════════════════════════════════════════

REM ══ 설정: 로봇 없이 테스트=1, 실제 로봇(USB)=0 ══
set "SIM=0"

echo ──────────────────────────────────────────
echo   Reachy Mini 대화앱 (Gemini) 시작
echo ──────────────────────────────────────────

if exist ".venv\Scripts\activate.bat" goto venv_ready

echo [설치] 첫 실행 - 가상환경 생성 + 패키지 설치 중... (몇 분 걸립니다)
where uv >nul 2>&1
if !errorlevel! equ 0 (
  REM uv.lock 의 검증 버전 그대로 설치 (reachy-mini 1.8.3 등 = v0.8.0 출시 조합)
  uv sync --frozen
  if !errorlevel! neq 0 goto fail_install
  call ".venv\Scripts\activate.bat"
  goto venv_done
)
py -3.12 -m venv .venv 2>nul
if !errorlevel! neq 0 python -m venv .venv
if !errorlevel! neq 0 goto fail_python
call ".venv\Scripts\activate.bat"
python -m pip install --upgrade pip >nul 2>&1
python -m pip install -e .
if !errorlevel! neq 0 goto fail_install
python -m pip install "reachy-mini==1.8.3" >nul 2>&1
goto venv_done

:venv_ready
call ".venv\Scripts\activate.bat"
goto after_venv

:venv_done
echo [설치] 완료.

:after_venv

REM ── 로봇 데몬 ──
set "DAEMON_ARGS=--preload-datasets"
if "%SIM%"=="1" (
  REM 로봇 없는 테스트(실험적) - MuJoCo 시뮬. 없으면 자동 설치.
  python -c "import mujoco" 2>nul || python -m pip install mujoco >nul 2>&1
  set "DAEMON_ARGS=--sim --preload-datasets"
)

curl -s -m 2 http://127.0.0.1:8000/api/daemon/status >nul 2>&1
if !errorlevel! equ 0 (
  echo [1/2] 로봇 데몬 이미 실행 중 :8000
  goto run_app
)

echo [1/2] 로봇 데몬 기동 중... (SIM=%SIM%)  ^<- 새 창이 뜹니다. 그 창은 닫지 마세요.
start "Reachy 데몬 (닫지 마세요)" cmd /k ""%ROOT%\.venv\Scripts\reachy-mini-daemon.exe" %DAEMON_ARGS%"

set /a n=0
:wait
timeout /t 2 >nul
curl -s -m 2 http://127.0.0.1:8000/api/daemon/status 2>nul | findstr "running" >nul
if !errorlevel! equ 0 goto daemon_ok
set /a n+=1
if !n! lss 30 goto wait
echo.
echo ❌ 데몬 시작 실패 - 로봇 USB 연결을 확인하세요.
echo    로봇 없이 테스트하려면 이 파일을 편집기로 열어 SIM=0 을 SIM=1 로 바꾸세요.
pause
exit /b 1
:daemon_ok
echo       데몬 running

:run_app
echo [2/2] 대화앱 시작 - 로봇에게 말을 걸어보세요.
echo       끝내려면: 이 창을 닫거나 WIN_종료.bat 실행
echo ──────────────────────────────────────────
"%ROOT%\.venv\Scripts\reachy-mini-conversation-app.exe"
goto end

:fail_python
echo.
echo ❌ Python 3.12 이 필요합니다.
echo    https://www.python.org/downloads/ 에서 3.12 설치 시 "Add python.exe to PATH" 체크 후 다시 실행하세요.
pause
exit /b 1

:fail_install
echo.
echo ❌ 설치 실패. 인터넷 연결과 Python 3.12 를 확인하고,
echo    이 폴더의 .venv 폴더를 삭제한 뒤 다시 실행하세요.
pause
exit /b 1

:end
echo.
echo (앱이 종료되었습니다. 데몬 창은 WIN_종료.bat 로 정리하세요.)
pause
