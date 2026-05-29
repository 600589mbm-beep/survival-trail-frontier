extends Control
## Main — touch-first screen state machine, UI built in code (no art deps yet).
## TITLE -> LEADER -> ROUTE -> WAGON -> OUTFITTER -> TRAVEL <-> EVENT <-> HUNT -> ENDING
## + SETTINGS/STORE from the title.

const BG := Color("0e1726")
const PANEL := Color("1b2740")
const TEXT := Color("e8edf4")
const GOOD := Color("6fcf97")
const BAD := Color("eb5757")
const DIM := Color("9aa7bd")

var _root: VBoxContainer
var _current_event: Dictionary = {}
# pending selections before the run is created
var _sel := {"leader": 0, "route": 0, "wagon": "settler", "daily": false, "seed": 0}

func _ready() -> void:
	# Battery: this is a turn-based, mostly-static UI. Redraw only on input
	# (low-processor mode) and cap FPS. The hunt mini-game flips this off while
	# it animates (see _launch_hunt / _on_hunt_finished).
	Engine.max_fps = 60
	OS.low_processor_usage_mode = true
	GameState.run_ended.connect(_on_run_ended)
	_show_title()

func _accent() -> Color:
	return Monetization.active_skin_tint()

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

func _label(text: String, size: int = 28, color: Color = TEXT, _bold: bool = false) -> Label:
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
	b.custom_minimum_size = Vector2(0, 76)
	b.add_theme_font_size_override("font_size", 24)
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var sb := StyleBoxFlat.new()
	sb.bg_color = _accent() if accent else PANEL
	sb.set_corner_radius_all(14)
	sb.content_margin_left = 18
	sb.content_margin_right = 18
	b.add_theme_stylebox_override("normal", sb)
	var sbh := sb.duplicate()
	sbh.bg_color = (_accent().lightened(0.1)) if accent else PANEL.lightened(0.15)
	b.add_theme_stylebox_override("hover", sbh)
	b.add_theme_stylebox_override("pressed", sbh)
	b.add_theme_color_override("font_color", BG if accent else TEXT)
	b.pressed.connect(func(): AudioManager.play_sfx("click"))
	b.pressed.connect(cb)
	return b

func _panel(into: VBoxContainer) -> VBoxContainer:
	var p := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = PANEL
	sb.set_corner_radius_all(16)
	sb.content_margin_left = 18
	sb.content_margin_right = 18
	sb.content_margin_top = 16
	sb.content_margin_bottom = 16
	p.add_theme_stylebox_override("panel", sb)
	var inner := VBoxContainer.new()
	inner.add_theme_constant_override("separation", 10)
	p.add_child(inner)
	into.add_child(p)
	return inner

func _spacer(h: int = 8) -> Control:
	var c := Control.new()
	c.custom_minimum_size = Vector2(0, h)
	return c

# ---------- TITLE ----------
func _show_title() -> void:
	var vb := _fresh()
	vb.add_child(_spacer(20))
	vb.add_child(_label("SURVIVAL TRAIL", 44, _accent(), true))
	vb.add_child(_label("FRONTIER", 30, TEXT))
	vb.add_child(_spacer(8))
	vb.add_child(_label("Lead a wagon party across a brutal frontier where every choice costs food, health, trust, or time.", 22, DIM))
	vb.add_child(_spacer(24))
	vb.add_child(_button("New Journey", func(): _show_leader_select(false), true))
	vb.add_child(_button("Daily Challenge", _start_daily))
	if SaveManager.has_save():
		vb.add_child(_button("Continue", _continue_run))
	vb.add_child(_button("Settings & Store", _show_settings))
	vb.add_child(_spacer(20))
	vb.add_child(_label("3 routes · 5 party · 38 events · weather · illness · 3 endings", 16, DIM.darkened(0.2)))

func _continue_run() -> void:
	if SaveManager.load_game():
		_show_travel()

func _start_daily() -> void:
	var t := Time.get_date_dict_from_system()
	_sel.seed = t.year * 10000 + t.month * 100 + t.day
	_sel.daily = true
	_sel.route = _sel.seed % EventDB.ROUTES.size()
	_show_leader_select(true)

# ---------- LEADER ----------
func _show_leader_select(daily: bool) -> void:
	_sel.daily = daily
	var vb := _fresh()
	vb.add_child(_label("Choose Your Leader", 34, _accent(), true))
	if daily:
		vb.add_child(_label("Daily run — fixed seed & route for everyone today.", 18, DIM))
	for i in EventDB.LEADERS.size():
		var ldr: Dictionary = EventDB.LEADERS[i]
		var card := _panel(vb)
		card.add_child(_label("%s — %s" % [ldr.name, ldr.trait], 24, _accent(), true))
		card.add_child(_label(ldr.blurb, 19, TEXT))
		var idx := i
		card.add_child(_button("Choose", func(): _pick_leader(idx), true))
	vb.add_child(_button("Back", _show_title))

func _pick_leader(idx: int) -> void:
	_sel.leader = idx
	if _sel.daily:
		_show_wagon_select() # route is fixed for daily
	else:
		_show_route_select()

# ---------- ROUTE ----------
func _show_route_select() -> void:
	var vb := _fresh()
	vb.add_child(_label("Choose Your Route", 34, _accent(), true))
	for i in EventDB.ROUTES.size():
		var rt: Dictionary = EventDB.ROUTES[i]
		var card := _panel(vb)
		card.add_child(_label("%s — %s" % [rt.name, rt.difficulty], 24, _accent(), true))
		card.add_child(_label("%d miles · %s country" % [rt.total_miles, rt.biome], 18, DIM))
		card.add_child(_label(rt.intro, 18, TEXT))
		var idx := i
		card.add_child(_button("Take this road", func(): _pick_route(idx), true))
	vb.add_child(_button("Back", func(): _show_leader_select(false)))

func _pick_route(idx: int) -> void:
	_sel.route = idx
	_show_wagon_select()

# ---------- WAGON ----------
func _show_wagon_select() -> void:
	var vb := _fresh()
	vb.add_child(_label("Choose Your Wagon", 34, _accent(), true))
	for w in EventDB.WAGONS:
		var card := _panel(vb)
		card.add_child(_label(w.name, 24, _accent(), true))
		card.add_child(_label(w.blurb, 19, TEXT))
		var wid := String(w.id)
		card.add_child(_button("Hitch up", func(): _pick_wagon(wid), true))
	vb.add_child(_button("Back", func(): _show_route_select() if not _sel.daily else _show_leader_select(true)))

func _pick_wagon(wid: String) -> void:
	_sel.wagon = wid
	GameState.new_run(_sel.leader, _sel.route, _sel.wagon, _sel.daily, _sel.seed)
	_show_outfitter()

# ---------- OUTFITTER ----------
func _show_outfitter() -> void:
	var vb := _fresh()
	vb.add_child(_label("Fort Outfitter", 32, _accent(), true))
	vb.add_child(_label("Stock up before the road. Coin: %d" % GameState.resources.money, 22, GOOD))
	vb.add_child(_label(GameState.route.intro, 18, DIM))
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
	vb.add_child(_button("Hit the Trail", _start_trail, true))

func _buy(res_name: String, qty: int) -> void:
	GameState.buy(res_name, qty)
	_show_outfitter()

func _start_trail() -> void:
	Analytics.run_started(GameState.route.id, GameState.leader.name, GameState.wagon.id)
	_show_travel()

# ---------- TRAVEL ----------
func _show_travel() -> void:
	var vb := _fresh()
	vb.add_child(_label(GameState.route.name, 30, _accent(), true))
	var wx: Dictionary = EventDB.WEATHER[GameState.weather]
	vb.add_child(_label("Weather: %s" % wx.label, 20, DIM))
	vb.add_child(_stat_panel())

	var bar := ProgressBar.new()
	bar.min_value = 0
	bar.max_value = GameState.total_miles
	bar.value = GameState.miles
	bar.custom_minimum_size = Vector2(0, 26)
	bar.show_percentage = false
	vb.add_child(bar)
	vb.add_child(_label("Day %d · %d / %d miles" % [GameState.day, GameState.miles, GameState.total_miles], 20))

	vb.add_child(_spacer(8))
	vb.add_child(_label("Set the day's pace:", 22, _accent()))
	for key in GameState.PACES.keys():
		var p: Dictionary = GameState.PACES[key]
		var k := String(key)
		vb.add_child(_button("%s — %d mi/day" % [p.label, p.miles], func(): _do_day(k)))

	vb.add_child(_spacer(6))
	vb.add_child(_label("Or stop for the day:", 22, _accent()))
	vb.add_child(_button("Go Hunting  (uses ammo)", _go_hunting))
	vb.add_child(_button("Visit Trading Post", _show_town))

	vb.add_child(_spacer(10))
	vb.add_child(_button("Save & Quit to Title", func():
		SaveManager.save_game()
		_show_title(), false))

	if GameState.log_lines.size() > 0:
		vb.add_child(_spacer(8))
		vb.add_child(_label("Trail Log", 20, _accent()))
		var n: int = min(5, GameState.log_lines.size())
		for i in range(GameState.log_lines.size() - n, GameState.log_lines.size()):
			vb.add_child(_label("· " + GameState.log_lines[i], 16, DIM))

func _stat_panel() -> Control:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 24)
	grid.add_theme_constant_override("v_separation", 6)
	for r in EventDB.RESOURCES:
		var col: Color = GOOD if GameState.resources[r] > 0 else BAD
		grid.add_child(_label("%s: %d" % [EventDB.RESOURCE_LABELS[r], GameState.resources[r]], 18, col))
	box.add_child(grid)
	# party with health + conditions
	for m in GameState.party:
		var line := ""
		if m.alive:
			line = "%s — %d%%" % [m.name, m.health]
			if m.conditions.size() > 0:
				var names := []
				for c in m.conditions:
					names.append(EventDB.ILLNESSES[c].name)
				line += " (" + ", ".join(names) + ")"
		else:
			line = "%s — lost" % m.name
		var col2: Color = GOOD if (m.alive and m.health >= 50 and m.conditions.is_empty()) else (BAD if (not m.alive or m.health < 25) else _accent())
		box.add_child(_label(line, 18, col2))
	box.add_child(_label("Party morale: %d%%" % int(GameState.avg_morale()), 18, _accent()))
	return box

func _do_day(pace_key: String) -> void:
	AudioManager.play_sfx("travel")
	var ev := GameState.advance_day(pace_key)
	if not GameState.running:
		return
	if ev.is_empty():
		_show_travel()
	else:
		Analytics.event_shown(ev.id)
		_show_event(ev)

# ---------- EVENT ----------
func _show_event(ev: Dictionary) -> void:
	_current_event = ev
	var vb := _fresh()
	vb.add_child(_label(ev.title, 32, _accent(), true))
	vb.add_child(_spacer(2))
	vb.add_child(_label(ev.text, 22))
	vb.add_child(_spacer(12))
	for choice in ev.choices:
		var ch: Dictionary = choice
		vb.add_child(_button(ch.text, func(): _resolve_choice(ch)))

func _resolve_choice(choice: Dictionary) -> void:
	Analytics.choice_made(_current_event.id, choice.text)
	if choice.get("minigame", "") == "hunt":
		GameState.apply_choice(choice) # spends ammo
		_launch_hunt()
		return
	var result := GameState.apply_choice(choice)
	if not GameState.running:
		return
	_show_result(result if result != "" else "You move on.")

func _show_result(text: String) -> void:
	var vb := _fresh()
	vb.add_child(_label(_current_event.title, 30, _accent(), true))
	vb.add_child(_spacer(6))
	vb.add_child(_label(text, 24))
	vb.add_child(_spacer(16))
	vb.add_child(_stat_panel())
	vb.add_child(_spacer(16))
	vb.add_child(_button("Continue", _show_travel, true))
	# testing aid: let players flag an event as unfair (feeds Analytics funnel)
	vb.add_child(_button("Felt unfair", func():
		Analytics.flag_unfair(_current_event.id)
		_show_travel()))

# ---------- HUNT MINI-GAME ----------
func _launch_hunt() -> void:
	OS.low_processor_usage_mode = false # smooth animation during the mini-game
	for c in get_children():
		c.queue_free()
	var hunt = load("res://game/scripts/HuntMiniGame.gd").new()
	hunt.finished.connect(_on_hunt_finished.bind(hunt))
	add_child(hunt)

func _on_hunt_finished(hits: int, hunt) -> void:
	hunt.queue_free()
	OS.low_processor_usage_mode = true # back to battery-friendly static UI
	AudioManager.play_sfx("success" if hits > 0 else "fail")
	GameState.apply_hunt_result(hits)
	if not GameState.running:
		return
	var msg := "You bagged %d this time." % hits if hits > 0 else "Nothing. The herd got away."
	_show_result(msg)

# ---------- ON-DEMAND HUNT (player-initiated, classic-style) ----------
func _go_hunting() -> void:
	if GameState.resources["ammo"] < 1:
		_info("Out of Ammo", "You have no ammunition. Buy some at a trading post before you can hunt.")
		return
	if not GameState.begin_hunt(): # spends ammo + a day
		_info("Out of Ammo", "You have no ammunition.")
		return
	if not GameState.running:
		return # the day spent hunting was fatal; ending shown via signal
	_launch_hunt()

# ---------- TRADING POST / TOWN ----------
func _show_town() -> void:
	var vb := _fresh()
	vb.add_child(_label("Trading Post", 32, _accent(), true))
	vb.add_child(_label("Coin: %d" % GameState.resources.money, 22, GOOD))
	vb.add_child(_stat_panel())
	vb.add_child(_spacer(6))
	vb.add_child(_label("Buy supplies:", 20, _accent()))
	for r in EventDB.OUTFITTER_PRICES.keys():
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var name_l := _label("%s  (have %d)" % [EventDB.RESOURCE_LABELS[r], GameState.resources[r]], 20)
		name_l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(name_l)
		var res_name := String(r)
		var b5 := _button("+5  (%d)" % (GameState.outfitter_price(r) * 5), func(): _town_buy(res_name))
		b5.custom_minimum_size = Vector2(150, 64)
		b5.size_flags_horizontal = 0
		row.add_child(b5)
		vb.add_child(row)
	vb.add_child(_spacer(8))
	vb.add_child(_button("Rest here 1 day (recover health & morale)", func():
		GameState.rest_in_town()
		if GameState.running:
			_show_town()))
	vb.add_child(_button("Back to the trail", _show_travel, true))

func _town_buy(res_name: String) -> void:
	GameState.buy(res_name, 5)
	_show_town()

# ---------- simple info/notice screen ----------
func _info(title: String, text: String) -> void:
	var vb := _fresh()
	vb.add_child(_spacer(40))
	vb.add_child(_label(title, 30, _accent(), true))
	vb.add_child(_spacer(6))
	vb.add_child(_label(text, 22))
	vb.add_child(_spacer(20))
	vb.add_child(_button("OK", _show_travel, true))

# ---------- SETTINGS / STORE ----------
func _show_settings() -> void:
	var vb := _fresh()
	vb.add_child(_label("Settings & Store", 32, _accent(), true))

	var ads := _panel(vb)
	ads.add_child(_label("Remove Ads", 24, _accent(), true))
	if Monetization.is_ads_removed():
		ads.add_child(_label("Purchased — thank you.", 18, GOOD))
	else:
		ads.add_child(_label("One-time %s. No pay-to-win, ever." % Monetization.REMOVE_ADS_PRICE, 18, TEXT))
		ads.add_child(_button("Buy Remove Ads (%s)" % Monetization.REMOVE_ADS_PRICE, func():
			Monetization.purchase_remove_ads()
			_show_settings(), true))

	var skins := _panel(vb)
	skins.add_child(_label("Wagon Skins (cosmetic)", 24, _accent(), true))
	for s in EventDB.SKINS:
		var sid := String(s.id)
		var owned: bool = Monetization.owns_skin(sid)
		var active: bool = Monetization.active_skin() == sid
		var lbl := "%s%s" % [s.name, ("  ✓" if active else "")]
		if owned:
			skins.add_child(_button(lbl, func():
				Monetization.set_active_skin(sid)
				_show_settings()))
		else:
			skins.add_child(_button("Unlock %s (free in MVP)" % s.name, func():
				Monetization.unlock_skin(sid)
				_show_settings()))

	var audio := _panel(vb)
	audio.add_child(_label("Audio", 24, _accent(), true))
	audio.add_child(_button("Sound: %s" % ("Off" if AudioManager.is_muted() else "On"), func():
		AudioManager.set_muted(not AudioManager.is_muted())
		_show_settings()))

	var data := _panel(vb)
	data.add_child(_label("Save Data", 24, _accent(), true))
	data.add_child(_button("Erase saved run", func():
		SaveManager.clear_save()
		_show_settings()))

	vb.add_child(_button("Back", _show_title))

# ---------- ENDING ----------
func _on_run_ended(ending: Dictionary) -> void:
	AudioManager.play_sfx("success" if ending.good else "fail")
	Analytics.run_ended(ending.id, GameState.day - 1, GameState.miles, GameState.living_count())
	var vb := _fresh()
	vb.add_child(_spacer(30))
	vb.add_child(_label(ending.title, 38, GOOD if ending.good else BAD, true))
	vb.add_child(_spacer(10))
	vb.add_child(_label(ending.text, 24))
	vb.add_child(_spacer(20))
	vb.add_child(_label("Route: %s" % GameState.route.name, 20, _accent()))
	vb.add_child(_label("Days on the road: %d" % (GameState.day - 1), 20, _accent()))
	vb.add_child(_label("Survivors: %d / %d" % [GameState.living_count(), GameState.party.size()], 20, _accent()))
	vb.add_child(_label("Miles: %d / %d" % [GameState.miles, GameState.total_miles], 20, _accent()))
	if GameState.daily_challenge:
		vb.add_child(_label("Daily Challenge (seed %d)" % GameState.seed_value, 18, DIM))
	vb.add_child(_spacer(24))
	vb.add_child(_button("Back to Title", _show_title, true))
