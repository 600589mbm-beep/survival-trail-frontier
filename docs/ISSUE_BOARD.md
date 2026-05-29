# Issue Board & Milestones

Mirror these into GitHub Issues + Milestones (`gh issue create` / Projects board) once the repo is pushed. Status reflects this codebase.

## Milestone 1 — Concept Lock & Setup ✅ (done)
- [x] Game design brief (`docs/GAME_DESIGN_BRIEF.md`)
- [x] Legal & naming doc + check **checklist** (`docs/LEGAL_AND_NAMING.md`)
- [x] ASO package (`docs/ASO_PACKAGE.md`)
- [x] Godot 4.6 project + folders (game/docs/assets/marketing/builds)
- [x] git branches: `main`, `develop`, `feature/*`
- [ ] Push private GitHub repo (needs account auth)
- [ ] Create GitHub Issues/Projects board from this file

## Milestone 2 — Playable Prototype ✅ (done)
- [x] Core loop: party → outfitter → day-by-day travel → consumption → events → choices → end/fail
- [x] 5 party, 8 resources, 3 endings, save/load
- [x] Leader perks, outfitter economy, daily challenge, trail log

## Milestone 3 — Vertical Slice ✅ (code complete; needs painted art)
- [x] Real touch UI (large buttons, scroll, portrait)
- [x] 10+ polished events (83 total)
- [x] Hunting/scavenging mini-game (`HuntMiniGame.gd`)
- [x] River/crossing decisions (`river_ford`, `river_swell`, `tide_crossing`, `bridge_out`)
- [x] Illness system (named conditions w/ daily drain + cure)
- [x] Final destination / ending screen
- [x] **Real music & SFX** — procedural synth (`AudioManager.gd`), no external assets
- [ ] Replace code-drawn UI with painted art  *(needs Aseprite/PS assets — human)*

## Milestone 4 — Full Production ✅ (content targets met; tune & art ongoing)
- [x] Weather system (per-biome tables; 5 biomes)
- [x] Trading posts (`trade_post`, `wagon_trader`, `town_doctor`, `blacksmith`)
- [x] Injuries & illness, morale & relationship (member bonds)
- [x] Multiple wagon types (3)
- [x] Multiple endings (3)
- [x] **Routes: 5** (target 4–6) — temperate/desert/alpine/swamp/coast
- [x] **Events: 83** (target 80–150)
- [x] **Recruitable characters: 20** + 5 leaders (target 20+) — recruitment via events
- [ ] Balance pass once telemetry from testers is in

## Milestone 5 — Mobile Polish ✅ (perf done; cloud save optional)
- [x] Touch-first UI, large buttons, one-thumb nav
- [x] Auto-save (after each day + each choice)
- [x] Offline play (no network dependency)
- [x] **Battery/perf:** `OS.low_processor_usage_mode` (idle redraw) + 60 fps cap; full fps only in mini-game
- [ ] On-device low-end Android profiling  *(needs hardware — human)*
- [ ] Cloud save (only if needed)

## Milestone 6 — Monetization 🟡 (framework in; needs SDK)
- [x] Free download model
- [x] Remove-Ads IAP interface ($4.99) + cosmetic skins (`Monetization.gd`)
- [x] No pay-to-win supplies (enforced by design)
- [ ] Integrate real ads SDK (rewarded) + Store billing
- [ ] Paid expansion routes (post-launch)

## Milestone 7 — Testing 🟡 (automated harness done; live testing needs devices/testers)
- [x] Analytics funnel hooks (`Analytics.gd`: starts, ends, quit points, unfair flags, session length)
- [x] **Automated crash/invariant/save-load harness** (`tests/SimTest.gd` — 400 randomized runs) + `tests/run_tests.sh`
- [x] **CI** (`.github/workflows/ci.yml`) runs SimTest headless on push
- [x] **Crash testing — EXECUTED on Godot 4.6.3:** 400 runs, 0 crashes/violations (`docs/TEST_RESULTS.md`)
- [x] **Save/load testing — EXECUTED:** round-trip PASS
- [x] **Balance verified & fixed:** was 100% fail → now 38% arrival (found+fixed 3 real bugs this pass)
- [x] **Store policy review — DONE:** clause-by-clause audit vs Apple/Google guidelines (`docs/STORE_POLICY_REVIEW.md`); no outright violations, open items are integration steps
- [x] **Android build toolchain installed + export preset** (`export_presets.cfg`, `docs/ANDROID_BUILD.md`); APK export is 1-click in the Godot GUI (headless CLI can't surface config-validation reasons)
- [ ] 20 private testers; Android internal test; iOS TestFlight  *(needs devices/accounts — human)*
- [ ] Low-end Android perf testing on device  *(needs hardware — human)*

## Milestone 8 — Store Launch Prep 🟡 (all copy/compliance prepped; capture needs build)
- [x] App icon (`icon.svg` master)
- [x] Privacy policy draft (`docs/PRIVACY_POLICY.md`)
- [x] Landing page (`marketing/landing-page/index.html`)
- [x] **Store listing copy** (`docs/STORE_LISTING.md`) + **support email defined**
- [x] **Filled compliance answers** (`docs/COMPLIANCE.md`: Play Data Safety, Apple privacy labels, age rating)
- [x] **8 real screenshots CAPTURED** from the running game (Godot 4.6.3 under xvfb) → `marketing/screenshots/shot_*.png` (placeholder-art UI; recapture after painted art)
- [x] **30-second trailer RENDERED** (`marketing/trailer/trailer.mp4`, 30.0s, from 10 captured frames via ffmpeg; add music/VO per `SCRIPT.md`)
- [ ] Deploy landing page live (gh-pages ready; **awaiting your OK** — auto-mode blocked publishing a public site from a private repo)

## Milestone 9 — Soft Launch → Full Launch 🟡 (runbook + marketing kit ready)
- [x] **Launch runbook** (`docs/LAUNCH_RUNBOOK.md`), **press kit** (`marketing/press-kit/`), **social/Reddit/press drafts** (`marketing/social/POSTS.md`)
- [ ] Limited Android open test in one English market; tune tutorial/difficulty/ads/first-10-min  *(needs published build — human)*
- [ ] iOS + Android simultaneous full launch; marketing push  *(needs store accounts — human)*
