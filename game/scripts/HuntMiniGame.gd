extends Control
## Hunting mini-game — a sweeping marker; tap SHOOT inside the green zone.
## 3 shots. Emits finished(hits). Built in code; no art deps.

signal finished(hits)

const SHOTS := 3
const BG := Color("0e1726")
const PANEL := Color("1b2740")
const ACCENT := Color("e0a458")
const TEXT := Color("e8edf4")
const GOOD := Color("6fcf97")

var _marker_x: float = 0.0
var _dir: float = 1.0
var _speed: float = 520.0
var _shots_left: int = SHOTS
var _hits: int = 0
var _bar_rect: Rect2
var _zone_min: float
var _zone_max: float
var _active: bool = true
var _bar: ColorRect
var _zone: ColorRect
var _needle: ColorRect
var _status: Label

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var bg := ColorRect.new()
	bg.color = BG
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var v := VBoxContainer.new()
	v.set_anchors_preset(Control.PRESET_FULL_RECT)
	v.add_theme_constant_override("separation", 22)
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	var m := MarginContainer.new()
	m.set_anchors_preset(Control.PRESET_FULL_RECT)
	m.add_theme_constant_override("margin_left", 28)
	m.add_theme_constant_override("margin_right", 28)
	m.add_child(v)
	add_child(m)

	v.add_child(_mklabel("The Hunt", 36, ACCENT))
	v.add_child(_mklabel("Tap SHOOT when the needle is in the green.", 20, TEXT))
	_status = _mklabel("Shots left: %d   Hits: %d" % [_shots_left, _hits], 22, GOOD)
	v.add_child(_status)

	# track bar
	var track := Control.new()
	track.custom_minimum_size = Vector2(0, 80)
	track.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	v.add_child(track)

	_bar = ColorRect.new()
	_bar.color = PANEL
	_bar.set_anchors_preset(Control.PRESET_FULL_RECT)
	track.add_child(_bar)

	_zone = ColorRect.new()
	_zone.color = GOOD
	track.add_child(_zone)

	_needle = ColorRect.new()
	_needle.color = ACCENT
	track.add_child(_needle)

	var shoot := Button.new()
	shoot.text = "SHOOT"
	shoot.custom_minimum_size = Vector2(0, 96)
	shoot.add_theme_font_size_override("font_size", 32)
	var sb := StyleBoxFlat.new()
	sb.bg_color = ACCENT
	sb.set_corner_radius_all(16)
	shoot.add_theme_stylebox_override("normal", sb)
	shoot.add_theme_color_override("font_color", BG)
	shoot.pressed.connect(_on_shoot)
	v.add_child(shoot)

	# defer layout until the track has a real size
	call_deferred("_layout_bar", track)

func _layout_bar(track: Control) -> void:
	await get_tree().process_frame
	var w: float = track.size.x
	_bar_rect = Rect2(0, 0, w, 80)
	_bar.size = Vector2(w, 80)
	# green zone ~22% of the bar, centered-ish
	var zone_w: float = w * 0.22
	var zone_left: float = w * 0.39
	_zone.position = Vector2(zone_left, 0)
	_zone.size = Vector2(zone_w, 80)
	_zone_min = zone_left
	_zone_max = zone_left + zone_w
	_needle.size = Vector2(6, 80)
	_marker_x = 0.0

func _process(delta: float) -> void:
	if not _active or _bar_rect.size.x <= 0:
		return
	_marker_x += _dir * _speed * delta
	if _marker_x >= _bar_rect.size.x - 6:
		_marker_x = _bar_rect.size.x - 6
		_dir = -1.0
	elif _marker_x <= 0:
		_marker_x = 0
		_dir = 1.0
	_needle.position = Vector2(_marker_x, 0)

func _on_shoot() -> void:
	if not _active:
		return
	AudioManager.play_sfx("shot")
	var center: float = _marker_x + 3.0
	if center >= _zone_min and center <= _zone_max:
		_hits += 1
		_speed += 60.0 # gets harder
	_shots_left -= 1
	_status.text = "Shots left: %d   Hits: %d" % [_shots_left, _hits]
	if _shots_left <= 0:
		_active = false
		emit_signal("finished", _hits)

func _mklabel(t: String, s: int, c: Color) -> Label:
	var l := Label.new()
	l.text = t
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", s)
	l.add_theme_color_override("font_color", c)
	return l
