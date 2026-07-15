#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Reachy Mini 대화앱 v0.8.0 (Gemini Live) — 시작 (macOS)
#  Reachy Mini Control 앱 없이, CLI 데몬으로 직접 실행합니다.
#  ⚠ Control 앱이 켜져 있으면 먼저 완전히 종료하세요(포트 :8000 충돌).
# ─────────────────────────────────────────────────────────────
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1   # 0.실행/ 안에서 실행 → 상위(REACHY_WIN 루트)로
ROOT="$(pwd)"

# ══ 설정 ══════════════════════════════════════════════════════
#  로봇 없이 테스트하려면 SIM=1, 실제 로봇(USB)이면 SIM=0
SIM=0
# ══════════════════════════════════════════════════════════════

DAEMON_LOG="$ROOT/_daemon.log"; DAEMON_PID="$ROOT/_daemon.pid"
notify(){ osascript -e "display notification \"$2\" with title \"$1\"" >/dev/null 2>&1 || true; }
die(){ notify "Reachy" "$1"; echo ""; echo "$1"; read -n1 -s -r -p "아무 키나 누르면 창이 닫힙니다…"; exit 1; }

echo "──────────────────────────────────────────"
echo "  Reachy Mini 대화앱 (Gemini) 시작"
echo "──────────────────────────────────────────"

# ── 1) 가상환경 + 패키지 (첫 실행에만 설치, 몇 분 소요) ──
if [ ! -d ".venv" ]; then
  echo "[설치] 첫 실행 — 가상환경 생성 + 패키지 설치 중… (몇 분 걸립니다)"
  if command -v uv >/dev/null 2>&1; then
    # uv.lock 의 검증 버전 그대로 설치(reachy-mini 1.8.3 등 = v0.8.0 출시 조합)
    uv sync --frozen || die "❌ 패키지 설치 실패 (uv sync)"
    # shellcheck disable=SC1091
    source .venv/bin/activate
  else
    PY="$(command -v python3.12 || command -v python3 || command -v python || true)"
    [ -z "$PY" ] && die "❌ Python 3.12 이 필요합니다. https://www.python.org/downloads/ 에서 설치 후 다시 실행하세요."
    "$PY" -m venv .venv || die "❌ 가상환경 생성 실패"
    # shellcheck disable=SC1091
    source .venv/bin/activate
    python -m pip install --upgrade pip >/dev/null 2>&1 || true
    python -m pip install -e . || die "❌ 패키지 설치 실패"
    # v0.8.0 검증 버전으로 데몬/SDK 고정
    python -m pip install "reachy-mini==1.8.3" >/dev/null 2>&1 || true
  fi
  echo "[설치] 완료 ✅"
else
  # shellcheck disable=SC1091
  source .venv/bin/activate
fi

# ── 2) macOS GStreamer 우회 (데몬 미디어 초기화 hang 방지) ──
for gp in .venv/lib/python*/site-packages/gstreamer_python/lib/gstreamer-1.0/libgstpython.dylib; do
  [ -f "$gp" ] && mv "$gp" "${gp}.disabled" 2>/dev/null || true
done
export GST_PLUGIN_FEATURE_RANK="python:NONE"

# ── 3) 로봇 데몬 (CLI, 백그라운드) ──
DAEMON_ARGS="--preload-datasets"
if [ "$SIM" = "1" ]; then
  # 로봇 없는 테스트(실험적) — MuJoCo 시뮬. 없으면 자동 설치.
  python -c "import mujoco" 2>/dev/null || { echo "[sim] MuJoCo 설치 중…"; { command -v uv >/dev/null 2>&1 && uv pip install mujoco || python -m pip install mujoco; } >/dev/null 2>&1; }
  DAEMON_ARGS="--sim --preload-datasets"
fi
if curl -s -m 2 http://127.0.0.1:8000/api/daemon/status >/dev/null 2>&1; then
  echo "[1/2] 로봇 데몬 이미 실행 중 (:8000)."
else
  echo "[1/2] 로봇 데몬 기동 중… (SIM=$SIM)"
  # shellcheck disable=SC2086
  nohup reachy-mini-daemon $DAEMON_ARGS > "$DAEMON_LOG" 2>&1 &
  echo $! > "$DAEMON_PID"
  ok=0
  for _ in $(seq 1 30); do
    if curl -s -m 2 http://127.0.0.1:8000/api/daemon/status 2>/dev/null | grep -q '"state":"running"'; then ok=1; break; fi
    kill -0 "$(cat "$DAEMON_PID" 2>/dev/null)" 2>/dev/null || break
    sleep 2
  done
  if [ "$ok" = 1 ]; then echo "      🟢 데몬 running"; else
    echo "── 데몬 로그(마지막 15줄) ──"; tail -15 "$DAEMON_LOG" 2>/dev/null
    die "❌ 데몬 시작 실패 — 로봇 USB 연결 확인. 로봇 없이 테스트하려면 이 파일 상단 SIM=1 로 바꾸세요."
  fi
fi

# ── 4) 대화앱 (이 창에서 실행 — 로그 표시, 창 닫으면 앱 종료) ──
echo "[2/2] 대화앱 시작 — 로봇에게 말을 걸어보세요."
echo "      끝내려면: 이 창을 닫거나 'OSX_종료.command' 실행"
notify "Reachy" "🟢 준비 완료 — 로봇에게 말 거세요"
echo "──────────────────────────────────────────"
exec reachy-mini-conversation-app
