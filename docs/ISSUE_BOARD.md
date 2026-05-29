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

## Milestone 3 — Vertical Slice ✅ (mostly done; needs art/audio)
- [x] Real touch UI (large buttons, scroll, portrait)
- [x] 10+ polished events (38 total)
- [x] Hunting/scavenging mini-game (`HuntMiniGame.gd`)
- [x] River/crossing decisions (`river_ford`, `river_swell`)
- [x] Illness system (named conditions w/ daily drain + cure)
- [x] Final destination / ending screen
- [ ] Real music & SFX  *(needs audio assets)*
- [ ] Replace code-drawn UI with painted art  *(needs Aseprite/PS assets)*

## Milestone 4 — Full Production 🟡 (foundation in; expand content)
- [x] Weather system (per-biome tables)
- [x] Trading posts (`trade_post`, `wagon_trader`, `greywell`)
- [x] Injuries & illness, morale & relationship (member bonds)
- [x] Multiple wagon types (3)
- [x] Multiple endings (3)
- [x] Routes: 3 of 4–6  → **TODO: add 1–3 more**
- [ ] Events: 38 of 80–150  → **TODO: expand**
- [ ] Recruitable characters: 5 of 20+  → **TODO: recruitment system**

## Milestone 5 — Mobile Polish 🟡
- [x] Touch-first UI, large buttons, one-thumb nav
- [x] Auto-save (after each day + each choice)
- [x] Offline play (no network dependency)
- [ ] Battery/perf pass on low-end Android
- [ ] Cloud save (only if needed)

## Milestone 6 — Monetization 🟡 (framework in; needs SDK)
- [x] Free download model
- [x] Remove-Ads IAP interface ($4.99) + cosmetic skins (`Monetization.gd`)
- [x] No pay-to-win supplies (enforced by design)
- [ ] Integrate real ads SDK (rewarded) + Store billing
- [ ] Paid expansion routes (post-launch)

## Milestone 7 — Testing 🔴 (needs devices/testers)
- [x] Analytics funnel hooks (`Analytics.gd`: starts, ends, quit points, unfair flags, session length)
- [ ] 20 private testers; Android internal test; iOS TestFlight
- [ ] Crash / save-load / low-end perf testing; store policy review
- [ ] Track D1 retention, session length, completion rate, quit points

## Milestone 8 — Store Launch Prep 🔴
- [x] App icon (`icon.svg` master)
- [x] Privacy policy draft (`docs/PRIVACY_POLICY.md`)
- [x] Landing page (`marketing/landing-page/index.html`)
- [ ] 8 screenshots + 30s trailer  *(capture from running build)*
- [ ] Support email, age-rating forms, Play Data Safety, Apple privacy labels

## Milestone 9 — Soft Launch → Full Launch 🔴
- [ ] Limited Android open test in one English market; tune tutorial/difficulty/ads/first-10-min
- [ ] iOS + Android simultaneous full launch
- [ ] Marketing push (TikTok, YT Shorts, Reddit indie/historical/survival, press list)
