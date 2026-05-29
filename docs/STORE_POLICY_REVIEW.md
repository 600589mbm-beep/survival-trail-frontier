# Store Policy Review — Survival Trail: Frontier

A clause-by-clause self-review of the current build against the Apple App Store Review Guidelines and Google Play policies. **PASS** = compliant now · **RISK** = compliant only if noted action is taken before submission · **N/A** = not applicable to current build.

## Apple — App Store Review Guidelines
| § | Area | Verdict | Notes / action |
|---|---|---|---|
| 1.1–1.2 | Safety: objectionable / UGC | PASS | No user-generated content, no chat, no social. Survival peril + mild violence only. |
| 1.4 | Physical harm | PASS | Fictional survival; no real-world dangerous instructions. |
| 2.1 | App completeness | RISK | Must submit a complete, non-crashing build with final (non-placeholder) art. Crash-tested (400 runs) but **art is placeholder** — replace before submission. |
| 2.3 | Accurate metadata | PASS | Screenshots are real captures of actual gameplay (`marketing/screenshots/`); description matches features. Recapture with final art. |
| 2.3.1 | No hidden features | PASS | No undocumented functionality. |
| 2.5.1 | Private APIs / standard tech | PASS | Pure Godot/GDScript; no private APIs. |
| 3.1.1 | In-app purchase | RISK | "Remove Ads" must use **StoreKit IAP** and provide a **Restore Purchases** control (Apple requires it). Interface stubbed in `Monetization.gd`; wire real StoreKit + a Restore button. |
| 3.1.2 | Subscriptions | N/A | No subscriptions. |
| 4.0 | Design / minimum functionality | RISK | Replace code-drawn placeholder UI with finished art for a polished submission. |
| 4.2 | Minimum functionality | PASS | Full game loop, multiple routes/events/endings — substantial. |
| 5.1.1 | Data collection & storage | PASS | Current build collects **no** personal data; analytics are local-only. Privacy labels = "Data Not Collected". ⚠️ Re-declare if SDKs added. |
| 5.1.2 | Data use / ATT | RISK | If an ads SDK using IDFA ships, present the **App Tracking Transparency** prompt and declare tracking. |
| 5.1.5 | Location | N/A | No location use. |
| 5.6 | Developer code of conduct | PASS | No manipulation, no spam. |

## Google Play — Developer Program Policies
| Area | Verdict | Notes / action |
|---|---|---|
| Restricted content — Violence | PASS | Mild, non-realistic (text-described hunting/raiders/illness); no gore. Rated Teen/PEGI 12. |
| Restricted content — Gambling | PASS | One "card game" event is simulated, **no real money**, no payouts. Disclose as *simulated gambling* in IARC. |
| Restricted content — Alcohol/Drugs | PASS | One optional "celebrate" event references alcohol, mild, no encouragement; disclose in IARC. |
| User Data / Data Safety | PASS | Current build: no data collected/shared/transmitted. Data Safety = "No data collected". ⚠️ Update when SDKs ship. |
| Permissions | PASS | No sensitive permissions requested (no location/contacts/camera/mic). Offline. |
| Ads policy | RISK | When ads ship: rewarded ads must be opt-in, not deceptive, not on first launch, and respect Families policy. |
| Monetization & Ads — IAP | RISK | "Remove Ads" must use **Google Play Billing**. Stubbed in `Monetization.gd`. |
| Families policy | PASS | Not targeted at children; target 13+. No mixed-audience declaration needed unless you opt in. |
| Intellectual Property | PASS | Original world/characters/art; **no Oregon Trail IP** (see `LEGAL_AND_NAMING.md`). |
| Spam & minimum functionality | PASS | Substantial, functional game. |
| Impersonation | PASS | Original title; name/domain/TM checks run. |
| Store listing & promotion | PASS | Real screenshots; honest description; no fake reviews/incentivized installs. |

## Summary of blockers before submission (all already tracked)
1. **Replace placeholder art** (Apple 2.1/4.0) — issue #3.
2. **Wire real IAP/Billing + Restore Purchases** (Apple 3.1.1 / Play Billing) — issue #8.
3. **If ads SDK ships:** ATT prompt + re-declare privacy labels & Data Safety (Apple 5.1.2 / Play ads) — issue #8.
4. Recapture screenshots/trailer with final art (cosmetic).

Nothing in the current design violates policy outright; the open items are integration steps, not redesigns.
