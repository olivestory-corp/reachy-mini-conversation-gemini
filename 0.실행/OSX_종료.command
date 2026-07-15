#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Reachy Mini 대화앱 — 종료 (macOS)
#  대화앱 + 로봇 데몬을 모두 정지합니다.
# ─────────────────────────────────────────────────────────────
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1   # 0.실행/ 안에서 실행 → 상위(REACHY_WIN 루트)로

notify(){ osascript -e "display notification \"$2\" with title \"$1\"" >/dev/null 2>&1 || true; }
kill_pat(){ pkill -f "$1" 2>/dev/null || true; sleep 2; pgrep -f "$1" >/dev/null 2>&1 && { pkill -9 -f "$1" 2>/dev/null || true; sleep 1; }; }

echo "──────────────────────────────────────────"
echo "  Reachy Mini 대화앱 종료"
echo "──────────────────────────────────────────"
echo "[1/2] 대화앱 종료…"
kill_pat "reachy_mini_conversation_app.main"
kill_pat "reachy-mini-conversation-app"
echo "[2/2] 로봇 데몬 종료… (로봇 sleep 자세)"
kill_pat "reachy-mini-daemon"
rm -f _daemon.pid 2>/dev/null || true

if pgrep -f "reachy-mini-daemon" >/dev/null 2>&1 || pgrep -f "reachy_mini_conversation_app" >/dev/null 2>&1; then
  notify "Reachy" "❌ 종료 실패 — 남은 프로세스"
  echo "❌ 남은 프로세스가 있습니다. 활성 상태 보기에서 강제 종료하세요."
else
  notify "Reachy" "🔴 종료 완료"
  echo "🔴 전체 종료 완료."
fi
sleep 1
