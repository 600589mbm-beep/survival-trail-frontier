#!/usr/bin/env bash
# Headless automated test run. Requires Godot 4.6 on PATH as `godot`.
# Exits non-zero if any invariant fails (CI-friendly).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
GODOT="${GODOT:-godot}"

if ! command -v "$GODOT" >/dev/null 2>&1; then
  echo "Godot not found. Install Godot 4.6 and set GODOT=/path/to/godot, then re-run." >&2
  exit 127
fi

echo "Running SimTest (crash / invariant / save-load) headless..."
"$GODOT" --headless --path "$ROOT" res://tests/SimTest.tscn
echo "SimTest finished with code $?"
