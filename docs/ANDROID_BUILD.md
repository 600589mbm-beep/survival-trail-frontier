# Android Build — toolchain ready, 1-click in the Godot GUI

A full Android build toolchain was installed and an APK export was attempted **headless** in this environment. Everything needed is configured; the only blocker is that **headless Godot 4.6 reports Android export-config errors only into the editor GUI dialog, not to the CLI** — so a `--headless --export-debug` run fails with a message-less "configuration errors" that can't be diagnosed without the editor. In the Godot **editor GUI**, this export is Project → Export → Android → "Export Project", and the dialog names any remaining field.

## What's already set up (verified)
- **JDK 17** (`keytool`, `java`).
- **Android SDK** at `/root/android-sdk`: `platform-tools`, `build-tools;34.0.0` (apksigner, zipalign), `platforms;android-34`/`-35`, `ndk;23.2.8568313`, `cmake;3.22.1`.
- **Godot export templates 4.6.3.stable** installed (`~/.local/share/godot/export_templates/4.6.3.stable/`).
- **Debug keystore** at `/root/android-sdk/debug.keystore` (alias `androiddebugkey`, pass `android`).
- **Editor settings** (`~/.config/godot/editor_settings-4.6.tres`) point at the SDK / JDK / keystore.
- **Android build template** installed into `android/build/` (gitignored; regenerate via Project → Install Android Build Template).
- **Export preset** committed: `export_presets.cfg` (preset "Android", arm64-v8a, Gradle build on, min/target SDK 24/34, offline — no network/internet permission).

## What's verified vs blocked
- **Verified:** `godot --headless --export-pack "Android" game.pck` succeeds (629 KB) — the project **data export works**; the engine/project are export-ready.
- **Blocked headless:** the full APK packaging runs Godot's Android export-config *validation*, whose failure reasons Godot 4.6 emits **only into the editor GUI dialog**, not the CLI. Hand-assembling the APK from the prebuilt template is possible but cannot be **verified to boot** here (no Android device/emulator in this environment), so it isn't shipped — a 1-click GUI export is the correct, verifiable path.

## Finish the build (on a machine with the Godot 4.6 editor)
1. Open the project in the Godot editor (the SDK/JDK paths above, or your own, in Editor Settings → Export → Android).
2. Project → Install Android Build Template (if `android/build/` isn't present).
3. Project → Export → Android → **Export Project** → `builds/SurvivalTrailFrontier-debug.apk`.
   - The export dialog shows a green check when config is valid, or names the missing field.
4. Or headless once the GUI has validated the preset:
   `godot --headless --export-debug "Android" builds/SurvivalTrailFrontier-debug.apk`

## Then (needs a Play account — see LAUNCH_RUNBOOK.md)
Upload the AAB/APK to the Play Console **Internal testing** track and invite testers.
