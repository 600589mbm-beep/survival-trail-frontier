# Survival Trail: Frontier — Game Design Brief

*Two-page concept lock. Working title locked. World: original ("The Ashford Reach").*

## 1. Player Goal
Lead a five-person wagon party 800 miles across the **Ashford Reach** — from Fort Kestrel to the green valleys of Ashford — keeping as many people alive, fed, and willing as possible. Success is not just *arriving*; it's arriving *whole*.

## 2. Core Loop (one in-game day)
1. **Read state** — supplies, party health, morale, miles remaining.
2. **Choose pace** — Steady / Grueling / Rest. Pace trades miles against consumption and morale.
3. **Resolve the day** — consume food/water/feed; scarcity damages health; morale drifts.
4. **Procedural event (≈50%/day)** — a situation with 2–3 choices, each with deterministic or risk-rolled outcomes.
5. **Consequences** — resources, health, morale, and relationships shift; deaths are permanent.
6. **Repeat** until arrival (one of 3 endings) or total party loss (fail ending).

A full run is **8–15 minutes** — a complete mobile session.

## 3. Target Audience
- Fans of choice-driven survival/management games (FTL, *This War of Mine*, *80 Days*, classic trail sims) who want **short, replayable runs on mobile**.
- Age 16+, English-first launch markets.
- Players who enjoy **permadeath tension + narrative texture**, not twitch reflexes.

## 4. Art Style
- **Stylized flat 2D**, warm dusk palette (deep navy `#0e1726`, ember gold `#e0a458`, bone white `#e8edf4`).
- Hand-painted route vignettes + simple rigged character portraits with light idle animation.
- Readable, high-contrast, **legible at arm's length on a phone**. Prototype ships code-drawn UI; art layers on top without logic changes.

## 5. Monetization (ethical, see Month-6 plan)
- Free download.
- Optional **rewarded ads** (e.g. "scout ahead" reroll).
- **$4.99 one-time "Remove Ads."**
- Cosmetic wagon/leader skins.
- Paid **expansion routes** later.
- **No pay-to-win supplies** — buying survival breaks the core tension and trust.

## 6. MVP Scope (this prototype)
- ✅ **1 complete route** — The Ashford Reach (800 mi).
- ✅ **5 party members** (selectable leader + 4 fixed companions).
- ✅ **20 events** with branching choices and risk rolls.
- ✅ **8 resources** — food, water, medicine, ammo, parts, clothing, feed, coin.
- ✅ **3 endings** — Triumph / Bittersweet / Fail.
- ✅ **Save/load** (JSON to `user://`).
- ✅ Bonus already in: outfitter economy, leader perks, daily challenge (seeded), trail log.

*Out of MVP scope (deliberately): menus, cosmetics, ads, big story arcs, weather, trading-post network. Prove the loop is fun first.*

## 7. Launch Platforms
- **iOS** (TestFlight → App Store) — requires macOS + Xcode for builds.
- **Android** (Internal Testing → Play) — buildable from Windows; ships first.

## ASO summary
| Field | Value |
|---|---|
| App title | Survival Trail: Frontier *(26 chars, under 30 limit)* |
| Apple subtitle | Wagon Strategy RPG |
| Google short desc | Lead a wagon party through choices, sickness, supplies, and danger. |
| Apple keywords | wagon,route,choice,rpg,strategy,simulation,journey,resource,craft,offline,party |

**Marketing hook:** *"Lead your wagon party across a brutal frontier where every choice costs food, health, trust, or time."*
