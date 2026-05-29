# Store Compliance — filled answers (paste into consoles)

These answers describe the **current build** (single-player, offline, local-only analytics, no accounts, no data leaves the device). **Re-answer if you integrate ad/analytics SDKs** that collect data — the lines marked ⚠️ change then.

## Google Play — Data Safety form
- **Does your app collect or share any user data?** → **No** *(current build: analytics are written only to local device storage, never transmitted).*
  - ⚠️ When a real analytics/ads SDK ships: **Yes** → declare "App activity / Analytics" + "Device or other IDs (Advertising ID)" as **collected**, purpose *Analytics* and *Advertising*, **not** linked to identity, **not** sold; mark data **encrypted in transit** and a deletion path.
- **Is all data encrypted in transit?** → N/A now (no transmission). ⚠️ Yes once SDKs ship.
- **Do you provide a way to request data deletion?** → Yes — Settings → "Erase saved run"; uninstall clears all local data.
- **Target audience / Families:** Not designed for children; target 13+.

## Apple — App Privacy ("nutrition labels")
- **Data collection:** → **"Data Not Collected"** for the current build.
  - ⚠️ With analytics SDK: declare **Usage Data → Analytics** (not linked, not for tracking).
  - ⚠️ With ads SDK: declare **Identifiers → Device ID** under **"Data Used to Track You"** and present the **App Tracking Transparency** prompt before any tracking.
- **Account required?** No. **Sign in with Apple?** Not applicable.

## Age rating
- **Apple age rating:** expect **12+** — answers: *Cartoon/Fantasy Violence = Infrequent/Mild*, *Realistic Violence = None*, *Horror = None*, *Mature/Suggestive = None*, *Simulated Gambling = None* (the in-game card game has no real currency; if flagged, answer *Infrequent/Mild*), *Alcohol/Tobacco/Drugs = Infrequent/Mild* (one optional "celebrate"/liquor event).
- **Google Play (IARC questionnaire):** expect **Teen / PEGI 12**. Key answers: *Violence = mild, non-realistic (hunting, raiders, illness/death described in text)*; *No blood/gore*; *No sexual content*; *Reference to alcohol = yes, mild, no encouragement*; *Gambling = simulated, no real money*; *No user-to-user communication*; *No location sharing*; *No personal info shared*.

## Privacy policy
- Draft at `docs/PRIVACY_POLICY.md`. Host at `https://survivaltrailfrontier.com/privacy` and link in both listings. Keep it consistent with the SDKs you actually ship.

## Pre-submission policy self-check
- [ ] No use of "Oregon Trail" / protected IP anywhere in app, store text, or art (verified — see `LEGAL_AND_NAMING.md`).
- [ ] Ads (when added) are not deceptive, not on first launch, and rewarded ads are clearly opt-in.
- [ ] IAP "Remove Ads" is restorable (Apple requires a Restore Purchases control).
- [ ] Privacy policy URL live and reachable.
- [ ] Support email monitored.
