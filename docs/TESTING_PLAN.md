# Testing Plan

## Builds
- **Android (from Windows):** Godot → Export → Android. Internal Testing track on Play Console. APK/AAB lands in `builds/` (gitignored).
- **iOS (needs macOS + Xcode):** Godot → Export → iOS → open Xcode project → Archive → TestFlight.

## Cohort
- 20 private testers (mix of mobile-only + survival/strategy fans).
- Required device spread: at least 3 low-end Android (≤3 GB RAM) for perf.

## What to test
- [ ] Crash testing — full run on each route, all endings.
- [ ] Save/load — quit mid-run, force-kill app, reload; verify auto-save after each day/choice.
- [ ] Low-end Android perf — frame pacing on travel/event screens, mini-game.
- [ ] Store policy review — ads/IAP disclosure, age rating, data safety consistency.

## Metrics (already instrumented in `Analytics.gd`)
| Metric | Source event |
|---|---|
| Day-1 retention | `session_start` timestamps per install |
| Avg session length | `Analytics.session_seconds()` on `session_start`→exit |
| Route completion rate | `run_started` vs `run_ended` (good endings) |
| Where players quit | last `event_shown` / `choice_made` before drop |
| Which events feel unfair | `event_flagged_unfair` (in-game "Felt unfair" button) |

`Analytics._emit` currently writes `user://analytics.jsonl` + console. Swap that one function for GameAnalytics/Firebase before soft launch; call sites don't change.

## Soft-launch focus (one small English market / limited open test)
- Tutorial clarity, difficulty curve, crash rate, ad frequency, first-10-minutes hook.
