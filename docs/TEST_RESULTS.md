# Test Results (executed on real Godot 4.6.3)

Run on Godot Engine v4.6.3.stable.official, headless Linux, 2026-05-29.

## Automated suite — `tests/SimTest.gd` (400 randomized runs)
```
==== SimTest results ====
runs: 400   avg days/run: 19.6
endings: {"bittersweet":150,"fail":249,"triumph":1}
PASS — no invariant violations across 400 runs
save/load round-trip: OK
exit code: 0
```
- **Crash testing:** PASS — 400 full playthroughs across randomized leader/route/wagon, no crashes, no script errors.
- **Invariant testing:** PASS — no negative resources, health/miles always in range, every run terminated.
- **Save/load testing:** PASS — snapshot → save → mutate → load round-trips exactly.
- **Balance read:** ~38% reach the destination (bittersweet), ~62% perish, triumph rare — under *random* pace/choice play (a competent player does better). Reasonable for a "brutal frontier."

## Boot test
- `--quit-after 120` on the main scene: PASS — UI builds and runs headless with no runtime errors (audio falls back to a dummy device under headless root, expected).

## Bugs found & fixed by this run (static parsing missed both)
1. **Type-inference compile errors** in `GameState.gd` (`var x := untyped_fn()`) — Godot refused to compile; gdparse passed. Fixed (`:=` → `=`).
2. **All runs died (100% fail)** — consumption/scarcity too lethal to be winnable. Rebalanced: daily consumption 2→1 (food/water), starvation penalty 8/10→4/5, starting coin 60→90, starting provisions raised. Now winnable (38% arrival).
3. **save/load mismatch** — JSON parses numbers as float, so restored state wasn't type-clean. Fixed: `restore()` coerces resources/health/bond back to int.

## How to reproduce
```
GODOT=/path/to/godot bash tests/run_tests.sh
# or:
godot --headless --path . res://tests/SimTest.tscn
```

## Still requires devices/humans (not executable in CI)
20 private testers, Android Internal track, iOS TestFlight, low-end Android perf profiling, store policy review — see `docs/LAUNCH_RUNBOOK.md`.
