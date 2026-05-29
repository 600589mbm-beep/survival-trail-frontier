extends Node
## Analytics — lightweight local event log. Swap _emit for GameAnalytics /
## Firebase at launch; call sites stay the same.
##
## Tracks the funnel the test plan needs: run starts/completions, quit points,
## session length, and "felt unfair" flags from events.

const LOG_PATH := "user://analytics.jsonl"
const ENABLED := true

var _session_start_ms: int = 0
var _events_this_session: int = 0

func _ready() -> void:
	_session_start_ms = Time.get_ticks_msec()
	track("session_start", {})

func track(event: String, props: Dictionary) -> void:
	if not ENABLED:
		return
	_events_this_session += 1
	var record := {
		"event": event,
		"props": props,
		"t_ms": Time.get_ticks_msec(),
		"day": GameState.day if GameState.running else 0,
	}
	_emit(record)

# Replace this body with the real SDK call. Everything else is stable.
func _emit(record: Dictionary) -> void:
	var f := FileAccess.open(LOG_PATH, FileAccess.READ_WRITE) if FileAccess.file_exists(LOG_PATH) else FileAccess.open(LOG_PATH, FileAccess.WRITE)
	if f == null:
		return
	f.seek_end()
	f.store_line(JSON.stringify(record))
	f.close()
	print("[analytics] %s %s" % [record.event, JSON.stringify(record.props)])

# --- funnel helpers (named so call sites read clearly) ---
func run_started(route_id: String, leader: String, wagon: String) -> void:
	track("run_started", {"route": route_id, "leader": leader, "wagon": wagon})

func run_ended(ending_id: String, day: int, miles: int, survivors: int) -> void:
	track("run_ended", {"ending": ending_id, "day": day, "miles": miles, "survivors": survivors})

func event_shown(event_id: String) -> void:
	track("event_shown", {"id": event_id})

func choice_made(event_id: String, choice_text: String) -> void:
	track("choice_made", {"id": event_id, "choice": choice_text})

# Player-reported "this felt unfair" — surfaces the events to retune.
func flag_unfair(event_id: String) -> void:
	track("event_flagged_unfair", {"id": event_id})

func session_seconds() -> int:
	return int((Time.get_ticks_msec() - _session_start_ms) / 1000.0)
