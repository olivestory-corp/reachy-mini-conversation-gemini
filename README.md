# Reachy Mini 대화앱 (Gemini Live)

Reachy Mini 로봇과 **음성으로 대화**하는 앱입니다. Google **Gemini Live** 를 사용하며,
Reachy Mini Control 앱 없이 **더블클릭 한 번으로** 실행됩니다.
(Pollen Robotics 공식 앱 **v0.8.0** 기반 — 공식 앱은 v0.9.0 부터 Gemini 지원을 없앴습니다.)

---

> # ⛔️ 절대 주의: Reachy Mini **Control 앱을 실행하지 마세요!**
>
> 이 앱은 Control 앱 **없이** 자체 데몬으로 돕니다. Control 앱을 켜면:
> - 로봇 포트(`:8000`)가 **충돌해서 이 앱이 안 켜집니다.**
> - Control 앱은 **자동 업데이트**로 Gemini 지원이 사라진 최신 버전으로 바뀝니다 — **바로 이것 때문에** 우리가 v0.8.0 을 따로 씁니다.
>
> ✅ 실행 전 Control 앱은 **완전히 종료(Quit)** 하고, 이 앱만 쓰세요.
> (이미 설치돼 있어도 열지만 않으면 됩니다.)

---

## 🚀 사용 방법 (처음부터 끝까지)

### 1) 내려받기
- 이 페이지 위쪽 초록색 **`<> Code`** 버튼 → **`Download ZIP`** 클릭.
- 받은 ZIP 을 **바탕화면**으로 옮기고 **압축을 풉니다.** (폴더가 하나 생깁니다.)

### 2) 준비물 (처음 한 번만)
- **Python 3.12** 설치 → https://www.python.org/downloads/
  > ⚠️ **반드시 3.12 를 받으세요.** 그 페이지의 큰 버튼은 최신(3.14 등)이라 **쓰면 안 됩니다.**
  > 페이지를 내려 **"Looking for a specific release?"** 에서 **Python 3.12.x** 를 선택해 설치하세요.
  > (이 앱은 3.12 에서 검증됐고, 3.13/3.14 는 부품(패키지)이 아직 없어 설치가 실패합니다.)
  - Windows 는 설치 화면에서 **"Add python.exe to PATH"** 체크 필수!
  - 이미 `uv` 가 깔려 있다면 Python 을 따로 안 깔아도 됩니다(3.12 를 알아서 받아 씁니다).
- Reachy Mini **로봇을 USB 로 연결**.
- 로봇 **Control 앱이 켜져 있으면 완전히 종료**하세요 (안 끄면 충돌합니다).

### 3) API 키 넣기 (처음 한 번만)
- [Google AI Studio](https://aistudio.google.com/apikey) 에서 키를 발급받습니다.
- 압축 푼 폴더 안 **`.env.example`** 을 복사해 이름을 **`.env`** 로 바꾸고,
  파일을 열어 `GEMINI_API_KEY=` 뒤에 키를 붙여넣고 저장합니다.
  > ⚠️ `.env` 에는 키가 들어있어 이 저장소에는 올라가지 않습니다. **각자 넣어야** 합니다.

### 4) 실행하기
- **Mac** : 폴더 안 **`0.실행`** → **`OSX_시작.command`** 더블클릭.
  - 처음 열 때 "확인되지 않은 개발자" 경고가 나오면 → 그 파일에서 **마우스 오른쪽 클릭 → 열기 → 열기**.
- **Windows** : 폴더 안 **`0.실행`** → **`WIN_시작.bat`** 더블클릭.
- 준비되면 **로봇에게 말을 걸면 됩니다.** 🎤

> ⏳ **첫 실행은 몇 분 걸립니다.** 처음엔 가상환경 생성 + 패키지 설치가 백그라운드로 진행돼서
> 창에 별 반응이 없어 보여도 정상입니다. 설치가 끝나 데몬·앱이 올라오면 그때부터 동작합니다.
> (다음부터는 바로 켜집니다. 인터넷 연결 필요.)

### 5) 끄기
- **Mac** : `0.실행/OSX_종료.command`  ·  **Windows** : `0.실행/WIN_종료.bat` 더블클릭.

---

📗 **자세한 설명 · 문제 해결 · 목소리 바꾸기** → **[`실행방법.md`](실행방법.md)**
🔊 기본 음성 = **Erinome**(여성)  ·  백엔드 = **Gemini Live**

---

## 📖 원본 문서 (Pollen Robotics v0.8.0 — 참고용)

<sub>아래는 원본 앱의 기술 문서입니다. 실행은 위 「사용 방법」만으로 충분합니다.</sub>

---
title: Reachy Mini Conversation App
emoji: 🎤
colorFrom: red
colorTo: blue
sdk: static
pinned: false
short_description: Talk with Reachy Mini!
suggested_storage: large
tags:
 - reachy_mini
 - reachy_mini_python_app
---

# Reachy Mini conversation app

Conversational app for the Reachy Mini robot combining realtime voice backends, vision pipelines, and choreographed motion libraries.

![Reachy Mini Dance](docs/assets/reachy_mini_dance.gif)

## Table of contents
- [Overview](#overview)
- [Architecture](#architecture)
- [Installation](#installation)
- [Configuration](#configuration)
- [Running the app](#running-the-app)
- [LLM tools](#llm-tools-exposed-to-the-assistant)
- [Advanced features](#advanced-features)
- [Contributing](#contributing)
- [License](#license)

## Overview
- Real-time audio conversation loop with `fastrtc` for low-latency streaming. Supported backends:
  - **Hugging Face** - default, using the built-in Hugging Face server or your own local endpoint.
  - **OpenAI Realtime** (`gpt-realtime-2`) - requires `OPENAI_API_KEY`.
  - **Gemini Live** (`gemini-3.1-flash-live-preview`) - requires `GEMINI_API_KEY`.
- Vision processing uses the selected realtime backend by default (when the camera tool is used), with optional on-device local vision using SmolVLM2 (CPU/GPU/MPS) via `--local-vision`.
- Layered motion system queues primary moves (dances, emotions, goto poses, breathing) while blending speech-reactive wobble and head-tracking.
- Async tool dispatch integrates robot motion, camera capture, and optional head-tracking capabilities. An optional web UI (`--ui`) provides personality selection, mic control, and settings.

## Architecture

The app follows a layered architecture connecting the user, AI services, and robot hardware:

<p align="center">
  <img src="docs/assets/conversation_app_arch.svg" alt="Architecture Diagram" width="600"/>
</p>

## Installation

> [!IMPORTANT]
> Before using this app, you need to install [Reachy Mini's SDK](https://github.com/pollen-robotics/reachy_mini/).<br>
> Windows support is currently experimental and has not been extensively tested. Use with caution.

<details open>
<summary><b>Using uv (recommended)</b></summary>

Set up the project quickly using [uv](https://docs.astral.sh/uv/):

```bash
# macOS (Homebrew)
uv venv --python /opt/homebrew/bin/python3.12 .venv

# Linux / Windows (Python in PATH)
uv venv --python python3.12 .venv

source .venv/bin/activate
uv sync
```

> **Note:** To reproduce the exact dependency set from this repo's `uv.lock`, run `uv sync --frozen`. This ensures `uv` installs directly from the lockfile without re-resolving or updating any versions.

**Install optional features:**
```bash
uv sync --extra local_vision         # Local PyTorch/Transformers vision
uv sync --extra yolo_vision          # YOLO face-detection backend for head tracking
uv sync --extra mediapipe_vision     # MediaPipe-based head-tracking
uv sync --extra all_vision           # All vision features
```

Combine extras or include dev dependencies:
```bash
uv sync --extra all_vision --group dev
```

</details>

<details>
<summary><b>Using pip</b></summary>

```bash
python -m venv .venv
source .venv/bin/activate
pip install -e .
```

**Install optional features:**
```bash
pip install -e .[local_vision]          # Local vision stack
pip install -e .[yolo_vision]           # YOLO face-detection backend for head tracking
pip install -e .[mediapipe_vision]      # MediaPipe-based vision
pip install -e .[remote_tools]          # Hugging Face Space tools over MCP
pip install -e .[all_vision]            # All vision features
pip install -e .[dev]                   # Development tools
```

Some wheels (like PyTorch) are large and require compatible CUDA or CPU builds—make sure your platform matches the binaries pulled in by each extra.

</details>

### Optional dependency groups

| Extra | Purpose | Notes |
|-------|---------|-------|
| `local_vision` | Run the local VLM (SmolVLM2) through PyTorch/Transformers | GPU recommended. Ensure compatible PyTorch builds for your platform. |
| `yolo_vision` | YOLOv11n face detection via `ultralytics` and `supervision` | Used as the `yolo` head-tracking backend. Runs on CPU (default). GPU improves performance. |
| `mediapipe_vision` | Lightweight landmark tracking with MediaPipe | Works on CPU. Enables `--head-tracker mediapipe`. |
| `all_vision` | Convenience alias installing every vision extra | Install when you want the flexibility to experiment with every provider. |
| `dev` | Developer tooling (`pytest`, `ruff`, `mypy`) | Development-only dependencies. Use `--group dev` with uv or `[dev]` with pip. |

**Note:** `dev` is a dependency group (not an optional dependency). With uv, use `--group dev`. With pip, use `[dev]`.

## Configuration

The default setup uses the Hugging Face backend and does not require an API key.

Copy `.env.example` to `.env` when you want to switch backends, provide API keys, or point Hugging Face at your own local endpoint.

| Variable | Description |
|----------|-------------|
| `OPENAI_API_KEY` | Required for OpenAI Realtime mode. |
| `GEMINI_API_KEY` | Required for Gemini mode. Also accepts `GOOGLE_API_KEY`. Get one at [aistudio.google.com](https://aistudio.google.com/apikey). |
| `BACKEND_PROVIDER` | Realtime backend to use: `huggingface` (default), `openai`, or `gemini`. |
| `MODEL_NAME` | Optional model override for OpenAI Realtime or Gemini Live. Defaults to `gpt-realtime-2` for OpenAI and `gemini-3.1-flash-live-preview` for Gemini. Hugging Face uses the server's model selection. |
| `REALTIME_TRANSCRIPTION_LANGUAGE` | Optional input transcription language for realtime backends. Defaults to `en`; set to a backend-supported code such as `zh` for Chinese. |
| `HF_REALTIME_CONNECTION_MODE` | Hugging Face connection selector: `deployed` uses the built-in Hugging Face server; `local` uses `HF_REALTIME_WS_URL`. Defaults to `deployed`. |
| `HF_REALTIME_WS_URL` | Direct websocket endpoint for your own Hugging Face backend. Accepts either a base URL like `ws://127.0.0.1:8765/v1` or the full websocket URL `ws://127.0.0.1:8765/v1/realtime`. Used when `HF_REALTIME_CONNECTION_MODE=local`. |
| `HF_HOME` | Cache directory for local Hugging Face downloads (only used with `--local-vision` flag, defaults to `./cache`). |
| `HF_TOKEN` | Optional token for Hugging Face access (for gated/private assets). |
| `LOCAL_VISION_MODEL` | Hugging Face model path for local vision processing (only used with `--local-vision` flag, defaults to `HuggingFaceTB/SmolVLM2-2.2B-Instruct`). |
| `REACHY_MINI_APP_TIMEOUT_MINUTES` | Minutes of inactivity before the app closes. Defaults to `1440` (one day); set to `0` to disable. |

### Hugging Face Connection Modes

Use the built-in Hugging Face server through the app-managed Space proxy. This is the default for a new install; set it explicitly only when you want to switch back from a saved local endpoint:

```env
BACKEND_PROVIDER=huggingface
HF_REALTIME_CONNECTION_MODE=deployed
```

Run your own realtime voice backend using [speech-to-speech](https://github.com/huggingface/speech-to-speech) on the same machine as the conversation app:

```env
BACKEND_PROVIDER=huggingface
HF_REALTIME_CONNECTION_MODE=local
HF_REALTIME_WS_URL=ws://127.0.0.1:8765/v1/realtime
```

Run your own Hugging Face backend on your laptop and connect to it from Reachy Mini Wireless over the same Wi-Fi network:

```env
BACKEND_PROVIDER=huggingface
HF_REALTIME_CONNECTION_MODE=local
HF_REALTIME_WS_URL=ws://<your-laptop-lan-ip>:8765/v1/realtime
```

For that LAN setup, make sure the backend listens on an address reachable from the robot, not only on `127.0.0.1`.

If the backend stays bound to loopback on your laptop, you can forward it into the robot over SSH instead:

```bash
ssh -N -R 8765:127.0.0.1:8765 <robot-user>@<robot-host>
```

Then set this on the robot:

```env
BACKEND_PROVIDER=huggingface
HF_REALTIME_CONNECTION_MODE=local
HF_REALTIME_WS_URL=ws://127.0.0.1:8765/v1/realtime
```

When using the web UI's Settings view, selecting `Hugging Face` lets you choose either the built-in server or a local `host:port` target. The UI writes `HF_REALTIME_CONNECTION_MODE` for you, and the local path writes `HF_REALTIME_WS_URL` with a default of `localhost:8765`.

## Running the app

Activate your virtual environment, then launch:

```bash
reachy-mini-conversation-app
```

> [!TIP]
> Make sure the Reachy Mini daemon is running before launching the app. If you see a `TimeoutError`, it means the daemon isn't started. See [Reachy Mini's SDK](https://github.com/pollen-robotics/reachy_mini/) for setup instructions.

The app runs in console mode by default. Add `--ui` to also serve a web UI at http://127.0.0.1:7860/ for picking a personality, controlling the mic, and changing settings. Vision and head-tracking options are described in the CLI table below.

### CLI options

| Option | Default | Description |
|--------|---------|-------------|
| `--head-tracker {yolo,mediapipe}` | `None` | Select a head-tracking backend when a camera is available. `yolo` uses a local YOLO face detector, `mediapipe` comes from the `reachy_mini_toolbox` package. Requires the matching optional extra. |
| `--no-camera` | `False` | Run without camera capture or head tracking. |
| `--local-vision` | `False` | Use the local vision model (SmolVLM2) for camera-tool requests instead of the selected realtime backend. Requires `local_vision` extra to be installed. |
| `--ui` | `False` | Serve the web UI at http://127.0.0.1:7860/, in addition to console mode. |
| `--robot-name` | `None` | Optional. Connect to a specific robot by name when running multiple daemons on the same subnet. See [Multiple robots on the same subnet](#advanced-features). |
| `--debug` | `False` | Enable verbose logging for troubleshooting. |

### Examples

```bash
# Run with MediaPipe head tracking
reachy-mini-conversation-app --head-tracker mediapipe

# Run with the YOLO face-detection backend for head tracking
reachy-mini-conversation-app --head-tracker yolo

# Run with local vision processing (requires local_vision extra)
reachy-mini-conversation-app --local-vision

# Audio-only conversation (no camera)
reachy-mini-conversation-app --no-camera

# Launch with the minimal web UI for personality/mic/settings control
reachy-mini-conversation-app --ui
```

> [!WARNING]
> `--local-vision` is not supported when running the conversation app directly on Reachy Mini Wireless / the Raspberry Pi. For local vision, keep the daemon running on the robot and start the conversation app from your laptop or workstation instead.

## LLM tools exposed to the assistant

| Tool | Action | Dependencies |
|------|--------|--------------|
| `move_head` | Queue a head pose change (left/right/up/down/front). | Core install only. |
| `camera` | Capture the latest camera frame and analyze it with the selected realtime backend or the local vision model. | Requires camera worker. Uses local vision when `--local-vision` is enabled. |
| `head_tracking` | Enable or disable head-tracking offsets (not identity recognition - only detects and tracks head position). | Camera worker with configured head tracker (`--head-tracker`). |
| `dance` | Queue a dance from `reachy_mini_dances_library`. | Core install only. |
| `stop_dance` | Clear queued dances. | Core install only. |
| `play_emotion` | Play a recorded emotion clip via Hugging Face datasets. | Core install only. Uses the default open emotions dataset: [`pollen-robotics/reachy-mini-emotions-library`](https://huggingface.co/datasets/pollen-robotics/reachy-mini-emotions-library). |
| `stop_emotion` | Clear queued emotions. | Core install only. |
| `remember` | Save one short, stable fact about the user for future sessions. | Core install only. Stored in the app instance data directory. |
| `forget` | Remove a saved memory fact by matching a short query. | Core install only. |
| `idle_do_nothing` | Explicitly remain idle during an idle turn. Not intended for normal conversation turns. | Core install only. |

> [!NOTE]
> `remember`/`forget` facts are stored in `memory.v1.json` inside the app's instance data directory (`~/.local/share/reachy_mini_conversation_app/` by default, or the instance path used by the desktop launcher). `forget` only removes facts matched by query. To reset all remembered facts, delete this file.

## Advanced features

Built-in motion content is published as open Hugging Face datasets:
- Emotions: [`pollen-robotics/reachy-mini-emotions-library`](https://huggingface.co/datasets/pollen-robotics/reachy-mini-emotions-library)
- Dances: [`pollen-robotics/reachy-mini-dances-library`](https://huggingface.co/datasets/pollen-robotics/reachy-mini-dances-library)

<details>
<summary><b>Custom profiles</b></summary>

Create custom profiles with dedicated instructions and enabled tools.

For normal usage, select a profile from the UI and save it for startup. That selection is persisted in `startup_settings.json`.

If no startup settings have been saved yet, you can still seed startup from the environment with `REACHY_MINI_CUSTOM_PROFILE=<name>` to load `profiles/<name>/`. If neither is set, the `default` profile is used.

Each profile should include `instructions.txt` (prompt text). `greeting.txt` is optional and controls how the robot should start the conversation after the backend connects. `tools.txt` (list of allowed tools) is recommended. If missing for a non-default profile, the app falls back to `profiles/default/tools.txt`. Profiles can optionally contain custom tool implementations.

**Custom instructions:**

Write plain-text prompts in `instructions.txt`. To reuse shared prompt pieces, add lines like:
```
[identities/witty_identity]
[behaviors/silent_robot]
```
Each placeholder pulls the matching file under `src/reachy_mini_conversation_app/prompts/` (nested paths allowed).

**Startup greeting:**

On startup, once the realtime backend is connected and ready, the app sends the active profile's `greeting.txt` as an internal text turn so the model opens with a fresh spoken greeting. Keep this file as a short instruction, not a fixed script, for example:
```
Greet me warmly in one sentence, in character, and vary the wording each time.
```
If `greeting.txt` is missing, the app uses the built-in default greeting prompt.

**Enabling tools:**

List enabled tools in `tools.txt`, one per line. Prefix with `#` to comment out:
```
play_emotion
# move_head

# My custom tool defined locally
sweep_look
```
Tools are resolved first from Python files in the profile folder (custom tools), then from the core library `src/reachy_mini_conversation_app/tools/` (like `dance`, `head_tracking`).
Installed public Hugging Face Space tools can also be enabled here after you add them with `tool-spaces`.

**Custom tools:**

On top of built-in tools found in the core library, you can implement custom tools specific to your profile by adding Python files in the profile folder.
Custom tools must subclass `reachy_mini_conversation_app.tools.core_tools.Tool` (see that module for the interface).

**Edit personalities from the UI:**

When running with `--ui`, the Home view lists available profiles (folders under `profiles/`) plus the built-in default:
- Tap a card to apply that personality and start talking.
- Tap "Custom" to create a new personality by entering a name, instructions, and an optional startup greeting prompt. It copies `tools.txt` from the `default` profile and stores the files under `user_personalities/<name>/` in the app instance directory (next to `.env`/`startup_settings.json`).

Note: switching a personality reloads its instructions and tools in place via a quick backend reconnect — no app restart. Editing the active profile's files on disk needs a re-select (or restart) to apply.

</details>

<details>
<summary><b>Locked profile mode</b></summary>

To create a locked variant of the app that cannot switch profiles, edit `src/reachy_mini_conversation_app/config.py` and set the `LOCKED_PROFILE` constant to the desired profile name:
```python
LOCKED_PROFILE: str | None = "mars_rover"  # Lock to this profile
```
When `LOCKED_PROFILE` is set, the app always uses that profile, ignoring saved startup settings, `REACHY_MINI_CUSTOM_PROFILE`, and the web UI. The UI shows "(locked)" and disables all profile editing controls.
This is useful for creating dedicated clones of the app with a fixed personality. Clone scripts can simply edit this constant to lock the variant.

</details>

<details>
<summary><b>External profiles and tools</b></summary>

You can extend the app with profiles/tools stored outside the repository defaults.

- Core profiles are under `profiles/`.
- Core tools are under `src/reachy_mini_conversation_app/tools/`.

**Recommended layout:**

```text
external_content/
├── external_profiles/
│   └── my_profile/
│       ├── instructions.txt
│       ├── greeting.txt     # optional startup greeting prompt
│       ├── tools.txt        # optional (see fallback behavior below)
│       └── voice.txt        # optional
├── external_tools/
│   └── my_custom_tool.py
└── installed_tool_spaces.json
```

**Environment variables:**

Set these values in your `.env` when you want env-driven external profile/tool selection:

```env
# Optional fallback/manual profile selector:
REACHY_MINI_CUSTOM_PROFILE=my_profile
REACHY_MINI_EXTERNAL_PROFILES_DIRECTORY=./external_content/external_profiles
REACHY_MINI_EXTERNAL_TOOLS_DIRECTORY=./external_content/external_tools
# Optional convenience mode:
# AUTOLOAD_EXTERNAL_TOOLS=1
```

**Loading behavior:**

- **Default/strict mode**: `tools.txt` defines enabled tools explicitly. Every name in `tools.txt` must resolve to either a built-in tool (`src/reachy_mini_conversation_app/tools/`) or an external tool module in `REACHY_MINI_EXTERNAL_TOOLS_DIRECTORY`.
- **Convenience mode** (`AUTOLOAD_EXTERNAL_TOOLS=1`): all valid `*.py` tool files in `REACHY_MINI_EXTERNAL_TOOLS_DIRECTORY` are auto-added.
- **External profile fallback**: if the selected external profile has no `tools.txt`, the app falls back to built-in `profiles/default/tools.txt`.
- **Duplicate safety**: every loaded tool class must expose a unique `Tool.name`. The app now fails fast if two tool implementations claim the same tool name.

This supports both:
1. Local external tools used with built-in/default profile.
2. Local external profiles used with built-in default tools.

</details>

<details>
<summary><b>Public Hugging Face Space tools</b></summary>

You can install public MCP-compatible Hugging Face Spaces as remote tool sources for this app.

```bash
# install + enable in active profile
reachy-mini-conversation-app tool-spaces add <owner/space-name>

# enable in a specific profile
reachy-mini-conversation-app tool-spaces add <owner/space-name> --profile NAME

# install without enabling
reachy-mini-conversation-app tool-spaces add <owner/space-name> --install-only

# list installed spaces
reachy-mini-conversation-app tool-spaces list

# remove an installed space
reachy-mini-conversation-app tool-spaces remove owner/space-name
```

The app validates the public Space slug through the Hugging Face Hub, probes the standard public MCP endpoint, discovers tools, enables them in the active profile's `tools.txt`, and writes the installed Space to:

- `installed_tool_spaces.json` in the managed app instance directory
- `external_content/installed_tool_spaces.json` in terminal mode

Recommended tags for discoverability on Hugging Face:

- `reachy-mini-tool`
- `mcp`

These tags are advisory only. Installation still relies on successful MCP validation, not on tag presence.

</details>

<details>
<summary><b>Multiple robots on the same subnet</b></summary>

If you run multiple Reachy Mini daemons on the same network, use:

```bash
reachy-mini-conversation-app --robot-name <name>
```

`<name>` must match the daemon's `--robot-name` value so the app connects to the correct robot.

</details>

## Contributing

We welcome bug fixes, features, profiles, and documentation improvements. Please review our
[contribution guide](CONTRIBUTING.md) for branch conventions, quality checks, and PR workflow.
Working with an AI coding assistant? Point it at [`AGENTS.md`](AGENTS.md) — it codifies our engineering standards for agents.

Quick start:
- Fork and clone the repo
- Follow the [installation steps](#installation) (include the `dev` dependency group)
- Run contributor checks listed in [CONTRIBUTING.md](CONTRIBUTING.md)

## License

Apache 2.0
