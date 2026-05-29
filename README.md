# Survival Trail: Frontier

A modern trail-survival strategy game for mobile. Lead a five-person wagon party 800 miles across **The Ashford Reach** — manage supplies, sickness, morale, and moral choices, and survive procedural events. Original world; **not** affiliated with any existing trail game (see `docs/LEGAL_AND_NAMING.md`).

> *"Lead your wagon party across a brutal frontier where every choice costs food, health, trust, or time."*

## Status: MVP prototype (Weeks 2–4 — Playable Prototype)
The core loop is implemented and playable:
**start party → buy supplies → travel day-by-day → consume food/water/feed → procedural events → choices → reach destination or fail.**
Includes: 1 route, 5 party members, 20 events, 8 resources, 3 endings, save/load, leader perks, outfitter economy, daily challenge.

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
