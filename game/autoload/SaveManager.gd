extends Node
## SaveManager — JSON save/load to user:// (survives across sessions, mobile-safe).

const SAVE_PATH := "user://savegame.json"

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func save_game() -> bool:
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f == null:
		push_error("SaveManager: could not open save file for writing")
		return false
	f.store_string(JSON.stringify(GameState.snapshot()))
	f.close()
	return true

func load_game() -> bool:
	if not has_save():
		return false
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if f == null:
		return false
	var txt := f.get_as_text()
	f.close()
	var parsed = JSON.parse_string(txt)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("SaveManager: corrupt save")
		return false
	GameState.restore(parsed)
	return true

func clear_save() -> void:
	if has_save():
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
		# globalize may fail on some platforms; fall back
		if has_save():
			var d := DirAccess.open("user://")
			if d:
				d.remove("savegame.json")
