extends Node
## Captures real screenshots of the running game under a virtual display (xvfb).
## Run:  xvfb-run -s "-screen 0 720x1280x24" godot --path . res://tests/CaptureShots.tscn
## Writes PNGs into marketing/screenshots/ and a frame sequence into marketing/trailer/frames/.

const SHOT_DIR := "res://marketing/screenshots/"
const FRAME_DIR := "res://marketing/trailer/frames/"

var main: Control

func _ready() -> void:
	OS.low_processor_usage_mode = false
	await _run()
	get_tree().quit()

func _settle(n: int = 3) -> void:
	for i in n:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw

func _grab(path: String) -> void:
	await _settle()
	var img := get_viewport().get_texture().get_image()
	var abs := ProjectSettings.globalize_path(path)
	img.save_png(abs)
	print("saved %s  %dx%d" % [path.get_file(), img.get_width(), img.get_height()])

func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(FRAME_DIR))
	await get_tree().process_frame # leave _ready so the tree isn't busy
	main = load("res://game/scenes/Main.tscn").instantiate()
	add_child(main)
	await get_tree().process_frame # let Main._ready run...
	OS.low_processor_usage_mode = false # ...then override its battery setting so frames keep ticking
	await _settle(4)

	# 1 — title
	await _grab(SHOT_DIR + "shot_1_title.png")

	# 2 — route select
	main._show_route_select()
	await _grab(SHOT_DIR + "shot_2_routes.png")

	# set up a run for the in-game screens
	GameState.new_run(0, 0, "settler", false, 0)
	main._show_outfitter()
	await _grab(SHOT_DIR + "shot_3_outfitter.png")

	GameState.buy("food", 30)
	GameState.buy("water", 30)
	GameState.buy("feed", 15)
	GameState.buy("medicine", 2)
	GameState.advance_day("steady")
	GameState.advance_day("steady")

	# 4 — travel
	main._show_travel()
	await _grab(SHOT_DIR + "shot_4_travel.png")

	# 5 — event
	var ev: Dictionary = EventDB.EVENTS[0]
	main._current_event = ev
	main._show_event(ev)
	await _grab(SHOT_DIR + "shot_5_event.png")

	# 6 — result / party panel
	main._show_result("The wagon lurches across the cold ford. Everyone holds on — and you reach the far bank.")
	await _grab(SHOT_DIR + "shot_6_result.png")

	# 7 — hunting mini-game
	main.visible = false
	var hunt = load("res://game/scripts/HuntMiniGame.gd").new()
	add_child(hunt)
	await _settle(8)
	await _grab(SHOT_DIR + "shot_7_hunt.png")
	hunt.queue_free()
	main.visible = true

	# 8 — ending
	main._on_run_ended(EventDB.get_ending(5, 72))
	await _grab(SHOT_DIR + "shot_8_ending.png")

	# --- trailer frame sequence (a scripted run, sampled) ---
	await _capture_trailer_frames()

func _capture_trailer_frames() -> void:
	var frames := [
		func(): main._show_title(),
		func(): main._show_route_select(),
		func(): (GameState.new_run(2, 1, "scout", false, 0)),
		func(): main._show_outfitter(),
		func(): main._show_travel(),
		func(): main._show_event(EventDB.EVENTS[0]),
		func(): main._show_result("Every choice costs food, health, trust, or time."),
		func(): main._show_event(EventDB.EVENTS[1]),
		func(): main._show_travel(),
		func(): main._on_run_ended(EventDB.get_ending(5, 72)),
	]
	var idx := 0
	for f in frames:
		f.call()
		await _settle(2)
		var img := get_viewport().get_texture().get_image()
		img.save_png(ProjectSettings.globalize_path(FRAME_DIR + "frame_%02d.png" % idx))
		idx += 1
	print("saved %d trailer frames" % idx)
