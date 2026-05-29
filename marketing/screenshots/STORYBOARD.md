# Screenshot Storyboard (8)

**Real captures done:** `shot_1_title.png … shot_8_ending.png` are actual frames grabbed from the running game (Godot 4.6.3 under xvfb, 720×1280). They use the current placeholder (code-drawn) UI — recapture at full device resolutions after painted art lands. The `mock_*.svg` files are the earlier caption/framing mockups, kept for the overlay text.

Original capture pipeline: `tests/CaptureShots.gd` + `tests/CaptureShots.tscn` (drives the real screens, saves PNGs; also dumps 10 trailer frames → `marketing/trailer/frames/` → `trailer.mp4`).

| # | Screen to capture | Caption overlay |
|---|---|---|
| 1 | Title screen | **Lead your wagon party across a brutal frontier.** |
| 2 | Route select (5 routes) | **Five routes. Five climates. One survives.** |
| 3 | Travel screen w/ stats + weather | **Every day: how far, what to spend, who to save.** |
| 4 | A hard event w/ 3 choices | **80+ events. No perfect answer — only trade-offs.** |
| 5 | Hunting mini-game | **Hunt to eat. Steady your aim.** |
| 6 | Party panel w/ illness + bonds | **Keep them alive. Keep them together.** |
| 7 | River crossing decision | **Ford it… or pay the ferryman?** |
| 8 | Ending screen (triumph) | **Reach the green valleys — if you can.** |

Order on the store: 1 (hook) → 3 (core loop) → 4 (choices) → 6 (party) → 5 (mini-game) → 7 (drama) → 2 (variety) → 8 (payoff).
