@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0.."
set "ROOT=%CD%"

REM ===========================================================
REM  Reachy Mini Conversation App v0.8.0 (Gemini Live) - START
REM  Runs WITHOUT the Reachy Mini Control app (uses CLI daemon).
REM  * Quit the Control app completely before running (port 8000).
REM  * Connect the robot via USB.
REM  NOTE: This file must stay ASCII-only. Korean text breaks
REM        cmd.exe batch parsing on Windows (codepage mismatch).
REM ===========================================================

REM == SIM=0 : real robot (USB)   /   SIM=1 : no robot, MuJoCo sim (experimental) ==
set "SIM=0"

echo ------------------------------------------
echo   Reachy Mini Conversation App (Gemini)
echo ------------------------------------------

if exist ".venv\Scripts\activate.bat" goto venv_ready

echo [SETUP] First run - creating venv and installing packages...
echo         This takes a few minutes. Internet required. Please wait.
where uv >nul 2>&1
if !errorlevel! equ 0 (
  REM Pin Python 3.12 - the version v0.8.0 was tested/locked with.
  REM 3.13/3.14 may fail (locked deps have no wheels for them).
  REM If 3.12 is missing, uv downloads it automatically.
  uv sync --python 3.12 --frozen
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
echo [SETUP] Done.

:after_venv

set "DAEMON_ARGS=--preload-datasets"
if "%SIM%"=="1" (
  python -c "import mujoco" 2>nul || python -m pip install mujoco >nul 2>&1
  set "DAEMON_ARGS=--sim --headless --preload-datasets"
)

curl -s -m 2 http://127.0.0.1:8000/api/daemon/status >nul 2>&1
if !errorlevel! equ 0 (
  echo [1/2] Robot daemon already running on port 8000.
  goto run_app
)

echo [1/2] Starting robot daemon (SIM=%SIM%) ... a new window will open.
echo       Do NOT close that daemon window.
start "Reachy Daemon - do not close" cmd /k ""%ROOT%\.venv\Scripts\reachy-mini-daemon.exe" %DAEMON_ARGS%"

set /a n=0
:wait
timeout /t 2 >nul
curl -s -m 2 http://127.0.0.1:8000/api/daemon/status 2>nul | findstr "running" >nul
if !errorlevel! equ 0 goto daemon_ok
set /a n+=1
if !n! lss 30 goto wait
echo.
echo [ERROR] Daemon did not start.
echo         1) Is the robot connected via USB and powered on?
echo         2) Is the Reachy Mini Control app fully quit?
echo         (No robot? Open this file and set SIM=1 to try MuJoCo sim.)
pause
exit /b 1
:daemon_ok
echo       Daemon is running.

:run_app
echo [2/2] Starting conversation app - talk to the robot!
echo       To stop: close this window, or run the WIN stop file
echo       (the other WIN_*.bat in this 0.* folder).
echo ------------------------------------------
"%ROOT%\.venv\Scripts\reachy-mini-conversation-app.exe"
goto end

:fail_python
echo.
echo [ERROR] Python 3.12 is required.
echo         Install from https://www.python.org/downloads/
echo         and check "Add python.exe to PATH" during setup.
pause
exit /b 1

:fail_install
echo.
echo [ERROR] Install failed. Check your internet and Python 3.12,
echo         then delete the .venv folder and run this file again.
pause
exit /b 1

:end
echo.
echo (App exited. Use the stop file to close the daemon window.)
pause
