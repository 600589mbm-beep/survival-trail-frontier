extends Control
## Main — touch-first screen state machine, UI built in code (no art deps yet).
## Screens: TITLE -> OUTFITTER -> TRAVEL <-> EVENT -> ENDING

enum Screen { TITLE, OUTFITTER, TRAVEL, EVENT, ENDING }

const BG := Color("0e1726")
const PANEL := Color("1b2740")
const ACCENT := Color("e0a458")
const TEXT := Color("e8edf4")
const GOOD := Color("6fcf97")
const BAD := Color("eb5757")

var _root: VBoxContainer
var _current_event: Dictionary = {}

func _ready() -> void:
	GameState.run_ended.connect(_on_run_ended)
	_show_title()

# ---------- shared layout ----------
func _fresh() -> VBoxContainer:
	for c in get_children():
		c.queue_free()
	var bg := ColorRect.new()
	bg.color = BG
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_top", 48)
	margin.add_theme_constant_override("margin_bottom", 36)
	add_child(margin)

	var scroll := ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	margin.add_child(scroll)

	var vb := VBoxContainer.new()
	vb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vb.add_theme_constant_override("separation", 16)
	scroll.add_child(vb)
	_root = vb
	return vb

func _label(text: String, size: int = 28, color: Color = TEXT, bold: bool = false) -> Label:
	var l := Label.new()
	l.text = text
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return l

func _button(text: String, cb: Callable, accent := false) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(0, 76)            # large, one-thumb friendly
	b.add_theme_font_size_override("font_size", 24)
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var sb := StyleBoxFlat.new()
	sb.bg_color = ACCENT if accent else PANEL
	sb.set_corner_radius_all(14)
	sb.content_margin_left = 18
	sb.content_margin_right = 18
	b.add_theme_stylebox_override("normal", sb)
	var sbh := sb.duplicate()
	sbh.bg_color = (ACCENT.lightened(0.1)) if accent else PANEL.lightened(0.15)
	b.add_theme_stylebox_override("hover", sbh)
	b.add_theme_stylebox_override("pressed", sbh)
	b.add_theme_color_override("font_color", BG if accent else TEXT)
	b.pressed.connect(cb)
	return b

func _spacer(h: int = 8) -> Control:
	var c := Control.new()
	c.custom_minimum_size = Vector2(0, h)
	return c

# ---------- TITLE ----------
func _show_title() -> void:
	var vb := _fresh()
	vb.add_child(_spacer(20))
	vb.add_child(_label("SURVIVAL TRAIL", 44, ACCENT, true))
	vb.add_child(_label("FRONTIER", 30, TEXT))
	vb.add_child(_spacer(8))
	vb.add_child(_label("Lead a wagon party across the Ashford Reach. Every choice costs food, health, trust, or time.", 22, TEXT.darkened(0.1)))
	vb.add_child(_spacer(24))
	vb.add_child(_button("New Journey", _show_leader_select, true))
	vb.add_child(_button("Daily Challenge", _start_daily))
	if SaveManager.has_save():
		vb.add_child(_button("Continue", _continue_run))
	vb.add_child(_spacer(20))
	vb.add_child(_label("MVP prototype · 1 route · 5 party · 20 events · 3 endings", 16, TEXT.darkened(0.35)))

func _continue_run() -> void:
	if SaveManager.load_game():
		_show_travel()

func _start_daily() -> void:
	# Deterministic seed from today's date (set by the device clock at runtime).
	var t := Time.get_date_dict_from_system()
	var seed_v: int = t.year * 10000 + t.month * 100 + t.day
	GameState.new_run(0, 60, true, seed_v)
	_show_leader_select(true)

# ---------- LEADER SELECT ----------
func _show_leader_select(daily := false) -> void:
	var vb := _fresh()
	vb.add_child(_label("Choose Your Leader", 34, ACCENT, true))
	if daily:
		vb.add_child(_label("Daily run — same seed for everyone today.", 18, TEXT.darkened(0.2)))
	vb.add_child(_spacer(4))
	for i in EventDB.LEADERS.size():
		var ldr: Dictionary = EventDB.LEADERS[i]
		var panel := PanelContainer.new()
		var sb := StyleBoxFlat.new()
		sb.bg_color = PANEL
		sb.set_corner_radius_all(16)
		sb.content_margin_left = 18
		sb.content_margin_right = 18
		sb.content_margin_top = 16
		sb.content_margin_bottom = 16
		panel.add_theme_stylebox_override("panel", sb)
		var inner := VBoxContainer.new()
		inner.add_theme_constant_override("separation", 10)
		panel.add_child(inner)
		inner.add_child(_label("%s — %s" % [ldr.name, ldr.trait], 24, ACCENT, true))
		inner.add_child(_label(ldr.blurb, 19, TEXT.darkened(0.05)))
		var idx := i
		inner.add_child(_button("Lead the party", func(): _begin_run(idx, daily), true))
		vb.add_child(panel)
	vb.add_child(_button("Back", _show_title))

func _begin_run(idx: int, daily: bool) -> void:
	if daily:
		# run already created with seed in _start_daily; just set leader
		GameState.new_run(idx, 60, true, GameState.seed_value)
	else:
		GameState.new_run(idx, 60, false)
	_show_outfitter()

# ---------- OUTFITTER ----------
func _show_outfitter() -> void:
	var vb := _fresh()
	vb.add_child(_label("Fort Kestrel Outfitter", 32, ACCENT, true))
	vb.add_child(_label("Stock up before the road. Coin: %d" % GameState.resources.money, 22, GOOD))
	vb.add_child(_label(EventDB.ROUTE.intro, 18, TEXT.darkened(0.1)))
	vb.add_child(_spacer(6))

	for r in EventDB.OUTFITTER_PRICES.keys():
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var name_l := _label("%s  (have %d)" % [EventDB.RESOURCE_LABELS[r], GameState.resources[r]], 20)
		name_l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(name_l)
		var price := GameState.outfitter_price(r)
		var res_name := String(r)
		var b5 := _button("+5  (%d)" % (price * 5), func(): _buy(res_name, 5))
		b5.custom_minimum_size = Vector2(150, 64)
		b5.size_flags_horizontal = 0
		row.add_child(b5)
		vb.add_child(row)

	vb.add_child(_spacer(12))
	vb.add_child(_button("Hit the Trail", _show_travel, true))

func _buy(res_name: String, qty: int) -> void:
	GameState.buy(res_name, qty)
	_show_outfitter()

# ---------- TRAVEL ----------
func _show_travel() -> void:
	var vb := _fresh()
	vb.add_child(_label(EventDB.ROUTE.name, 30, ACCENT, true))
	vb.add_child(_stat_panel())

	# progress bar
	var bar := ProgressBar.new()
	bar.min_value = 0
	bar.max_value = GameState.total_miles
	bar.value = GameState.miles
	bar.custom_minimum_size = Vector2(0, 26)
	bar.show_percentage = false
	vb.add_child(bar)
	vb.add_child(_label("Day %d · %d / %d miles" % [GameState.day, GameState.miles, GameState.total_miles], 20))

	vb.add_child(_spacer(8))
	vb.add_child(_label("Set the day's pace:", 22, ACCENT))
	for key in GameState.PACES.keys():
		var p: Dictionary = GameState.PACES[key]
		var k := String(key)
		vb.add_child(_button("%s — %d mi/day" % [p.label, p.miles], func(): _do_day(k)))

	vb.add_child(_spacer(10))
	vb.add_child(_button("Save & Quit to Title", func():
		SaveManager.save_game()
		_show_title(), false))

	# recent log
	if GameState.log_lines.size() > 0:
		vb.add_child(_spacer(8))
		vb.add_child(_label("Trail Log", 20, ACCENT))
		var n := min(5, GameState.log_lines.size())
		for i in range(GameState.log_lines.size() - n, GameState.log_lines.size()):
			vb.add_child(_label("· " + GameState.log_lines[i], 16, TEXT.darkened(0.25)))

func _stat_panel() -> Control:
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 24)
	grid.add_theme_constant_override("v_separation", 6)
	for r in EventDB.RESOURCES:
		var col: Color = GOOD if GameState.resources[r] > 0 else BAD
		grid.add_child(_label("%s: %d" % [EventDB.RESOURCE_LABELS[r], GameState.resources[r]], 18, col))
	# party health
	for m in GameState.party:
		var status := "%d%%" % m.health if m.alive else "lost"
		var col := GOOD if (m.alive and m.health >= 50) else (BAD if not m.alive or m.health < 25 else ACCENT)
		grid.add_child(_label("%s: %s" % [m.name, status], 18, col))
	grid.add_child(_label("Party morale: %d%%" % int(GameState.avg_morale()), 18, ACCENT))
	return grid

func _do_day(pace_key: String) -> void:
	var ev := GameState.advance_day(pace_key)
	if not GameState.running:
		return # ending handled by signal
	if ev.is_empty():
		_show_travel()
	else:
		_show_event(ev)

# ---------- EVENT ----------
func _show_event(ev: Dictionary) -> void:
	_current_event = ev
	var vb := _fresh()
	vb.add_child(_label(ev.title, 32, ACCENT, true))
	vb.add_child(_spacer(2))
	vb.add_child(_label(ev.text, 22))
	vb.add_child(_spacer(12))
	for choice in ev.choices:
		var ch: Dictionary = choice
		vb.add_child(_button(ch.text, func(): _resolve_choice(ch)))

func _resolve_choice(choice: Dictionary) -> void:
	var result := GameState.apply_choice(choice)
	if not GameState.running:
		return
	var vb := _fresh()
	vb.add_child(_label(_current_event.title, 30, ACCENT, true))
	vb.add_child(_spacer(6))
	vb.add_child(_label(result if result != "" else "You move on.", 24))
	vb.add_child(_spacer(16))
	vb.add_child(_stat_panel())
	vb.add_child(_spacer(16))
	vb.add_child(_button("Continue", _show_travel, true))

# ---------- ENDING ----------
func _on_run_ended(ending: Dictionary) -> void:
	SaveManager.clear_save()
	var vb := _fresh()
	vb.add_child(_spacer(30))
	vb.add_child(_label(ending.title, 38, GOOD if ending.good else BAD, true))
	vb.add_child(_spacer(10))
	vb.add_child(_label(ending.text, 24))
	vb.add_child(_spacer(20))
	vb.add_child(_label("Days on the road: %d" % (GameState.day - 1), 20, ACCENT))
	vb.add_child(_label("Survivors: %d / %d" % [GameState.living_count(), GameState.party.size()], 20, ACCENT))
	vb.add_child(_label("Miles: %d / %d" % [GameState.miles, GameState.total_miles], 20, ACCENT))
	if GameState.daily_challenge:
		vb.add_child(_label("Daily Challenge (seed %d)" % GameState.seed_value, 18, TEXT.darkened(0.3)))
	vb.add_child(_spacer(24))
	vb.add_child(_button("Back to Title", _show_title, true))
