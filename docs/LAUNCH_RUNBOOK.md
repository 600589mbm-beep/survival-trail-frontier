# Launch Runbook (Months 6–7)

Step-by-step for the phases that need accounts/devices/humans. Each box is an action **you** take; the codebase, copy, and compliance answers are already prepared (linked).

## 0. Prerequisites (one-time, paid/external)
- [ ] Apple Developer Program ($99/yr) + a **macOS machine with Xcode** (required for iOS builds — Android can build from Windows/Linux).
- [ ] Google Play Developer account ($25 one-time).
- [ ] Register `survivaltrailfrontier.com`; create `support@survivaltrailfrontier.com`.
- [ ] Host `docs/PRIVACY_POLICY.md` at `/privacy` and deploy `marketing/landing-page/`.

## 1. Testing (Milestone 7)
- [ ] **Automated first:** run `tests/run_tests.sh` (or let GitHub Actions CI run `SimTest`) — 400 randomized runs assert no crashes, no negative resources, save/load round-trip. Green before building.
- [ ] **Android internal testing:** Godot → Export → Android (AAB) → upload to Play Console *Internal testing* track → add up to 100 testers by email.
- [ ] **iOS TestFlight:** Godot → Export → iOS → open in Xcode → Archive → upload → TestFlight → invite testers.
- [ ] Recruit **20 testers** (mix of mobile-only + survival/strategy fans; ≥3 on low-end Android ≤3 GB RAM).
- [ ] Manual matrix from `docs/TESTING_PLAN.md`: crash, save/load (force-kill mid-run), low-end perf, store-policy review.
- [ ] Collect metrics already instrumented in `Analytics.gd` (point `_emit` at GameAnalytics/Firebase first): D1 retention, session length, completion rate, quit points, "felt unfair" flags.
- [ ] Triage: fix top crashes + the 3 most-flagged "unfair" events; retune difficulty.

## 2. Store Launch Prep (Milestone 8)
- [ ] App icon: export `icon.svg` → 1024² PNG.
- [ ] **8 screenshots:** capture per `marketing/screenshots/STORYBOARD.md` at the device sizes in `docs/STORE_LISTING.md`; add caption overlays.
- [ ] **30s trailer:** record per `marketing/trailer/SCRIPT.md`; export portrait 1080×1920.
- [ ] Paste listing copy from `docs/STORE_LISTING.md`.
- [ ] Fill **Play Data Safety** + **Apple privacy labels** + **age rating** from `docs/COMPLIANCE.md`.
- [ ] Privacy policy URL + support email into both listings.

## 3. Soft Launch
- [ ] Release to **one small English-speaking market** (e.g. Play open testing in Canada/NZ/Ireland, or a phased Android rollout).
- [ ] Watch the funnel for ~1–2 weeks. Improve: **tutorial clarity, difficulty curve, crash rate, ad frequency, first-10-minutes**.
- [ ] Gate full launch on: crash-free sessions ≥99%, D1 retention at target, completion rate sane.

## 4. Full Launch
- [ ] Release iOS + Android together (staged rollout on Play; phased on App Store).
- [ ] Marketing push using prepared assets in `marketing/`:
  - TikTok + YouTube Shorts (hooks in `marketing/social/POSTS.md`)
  - Reddit indie / historical-gaming / survival-gaming communities (drafts in `POSTS.md`; **read each sub's self-promo rules first**)
  - Mobile game press (template + list in `marketing/press-kit/`)
- [ ] Lead hook everywhere: *"Lead your wagon party across a brutal frontier where every choice costs food, health, trust, or time."*

## 5. Post-launch
- [ ] Monitor reviews + crash dashboards daily for week 1.
- [ ] First content drop: 1–2 new routes (system already supports 4–6) + paid expansion route experiment.
