# Survival Trail: Frontier

A modern trail-survival strategy game for mobile. Lead a five-person wagon party 800 miles across **The Ashford Reach** — manage supplies, sickness, morale, and moral choices, and survive procedural events. Original world; **not** affiliated with any existing trail game (see `docs/LEGAL_AND_NAMING.md`).

> *"Lead your wagon party across a brutal frontier where every choice costs food, health, trust, or time."*

## Status: Vertical Slice + Production foundation
The core loop is implemented and playable, plus the systems that make it a real game:
**leader → route → wagon → outfitter → day-by-day travel → consume → weather → procedural events → choices (incl. hunting mini-game) → illness/relationships → reach destination or fail.**

Included now:
- **5 routes** (temperate / desert / alpine / swamp / coast) · **3 wagon types** · **5 starting party + 20 recruitable characters** · **83 events** · **8 resources** · **3 endings**
- **Weather system** (per-biome), **named illness** conditions (daily drain + cure), **relationship/morale** (member bonds), **recruitment** (events add party members)
- **Real procedural audio** (`AudioManager.gd`): synthesized looping theme + SFX, **no external/IP assets**, mute toggle
- **Hunting mini-game**, outfitter economy, leader perks, **daily seeded challenge**
- **Save/load + auto-save** after every day and choice (offline, mobile-safe)
- **Battery/perf:** event-driven redraw (`OS.low_processor_usage_mode`) on static screens, 60 fps cap, full fps only during the mini-game
- **Monetization framework** (`Monetization.gd`): Remove-Ads IAP ($4.99) + cosmetic skins, **no pay-to-win** — SDK swap-in only
- **Analytics funnel** (`Analytics.gd`): run starts/ends, quit points, session length, "felt unfair" flags

All GDScript is parse-verified with `gdtoolkit` (`gdparse`). Visuals are code-drawn placeholder; painted art layers on top without touching logic.

## Testing
- `tests/run_tests.sh` (or GitHub Actions CI, `.github/workflows/ci.yml`) runs `tests/SimTest.gd` headless: **400 randomized playthroughs** across every leader/route/wagon, asserting no crashes, no negative resources, in-range health/miles, guaranteed termination, and a **save/load round-trip**.

## Launch readiness
All non-device launch artifacts are prepared: store listing copy (`docs/STORE_LISTING.md`), filled compliance answers (`docs/COMPLIANCE.md`), launch runbook (`docs/LAUNCH_RUNBOOK.md`), screenshot storyboard + 8 mockups, trailer script, press kit, and social/press drafts (`marketing/`). Remaining steps require devices, paid store accounts, and human testers — see `docs/LAUNCH_RUNBOOK.md`.

## Run it
1. Install **Godot 4.6.3 stable** (standard, not .NET).
2. Open `project.godot` in the Godot editor.
3. Press **F5** (main scene is `game/scenes/Main.tscn`).

No external assets required — UI is drawn in code (placeholder art phase). Real art/audio layer on top without touching game logic.

## Project layout
```
SurvivalTrailFrontier/
├─ project.godot            # Godot 4.6 config (autoloads, mobile renderer, portrait)
├─ icon.svg
├─ game/
│  ├─ autoload/             # EventDB (content), GameState (sim), SaveManager (save/load)
│  ├─ scenes/Main.tscn      # entry scene
│  ├─ scripts/Main.gd       # touch-first screen state machine (code-drawn UI)
│  └─ data/                 # (reserved for externalized content)
├─ docs/                    # design brief, legal & naming, ASO package
├─ assets/                  # art / audio / fonts (added in Vertical Slice)
├─ marketing/               # screenshots, trailer, landing page (Month 7)
└─ builds/                  # exported APK / IPA artifacts (gitignored)
```

## Architecture
- **EventDB** (autoload) — all static content: resources, leaders, party, route, 20 events, endings. Pure data; safe to expand to 80–150 events.
- **GameState** (autoload) — the simulation: resources, party health, morale, day/miles, event rolls, outcome application. Emits `state_changed` / `day_logged` / `run_ended`. **Holds all rules; UI never does.**
- **SaveManager** (autoload) — JSON snapshot to `user://savegame.json`.
- **Main.gd** — screen state machine (Title → Leader → Outfitter → Travel ↔ Event → Ending), large-button touch UI built in code.

## Branches
- `main` — release-ready.
- `develop` — integration.
- `feature/*` — per-feature work (`feature/playable-prototype` holds this MVP).

## Roadmap
See `docs/GAME_DESIGN_BRIEF.md`. Next milestone = **Vertical Slice**: real art/audio, 10 polished events, hunting mini-game, river crossing, illness system, destination screen.
