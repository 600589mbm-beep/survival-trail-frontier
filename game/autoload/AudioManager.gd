extends Node
## AudioManager — 100% procedural sound (no external assets, no IP).
## Synthesizes SFX + a looping ambient theme as AudioStreamWAV at startup.
## Real audio for the vertical slice; can be replaced with composed tracks later.

const RATE := 22050
const PREFS_PATH := "user://audio.json"

var _music_player: AudioStreamPlayer
var _sfx_player: AudioStreamPlayer
var _sfx := {}
var _muted := false

func _ready() -> void:
	_load_prefs()
	_music_player = AudioStreamPlayer.new()
	_music_player.volume_db = -12.0
	add_child(_music_player)
	_sfx_player = AudioStreamPlayer.new()
	_sfx_player.volume_db = -4.0
	add_child(_sfx_player)

	_sfx["click"]   = _tone([440.0], 0.06, 0.35, "square")
	_sfx["shot"]    = _noise(0.10, 0.5)
	_sfx["success"] = _seq([[523.25, 0.10], [659.25, 0.10], [783.99, 0.16]], 0.4)
	_sfx["fail"]    = _seq([[349.23, 0.12], [277.18, 0.18]], 0.45)
	_sfx["travel"]  = _tone([196.0, 392.0], 0.12, 0.3, "sine")
	_music_player.stream = _build_theme()
	if not _muted:
		_music_player.play()

func is_muted() -> bool:
	return _muted

func set_muted(m: bool) -> void:
	_muted = m
	_save_prefs()
	if _muted:
		_music_player.stop()
	elif not _music_player.playing:
		_music_player.play()

func play_sfx(name: String) -> void:
	if _muted or not _sfx.has(name):
		return
	_sfx_player.stream = _sfx[name]
	_sfx_player.play()

# --- synthesis helpers ---
func _sample_to_bytes(samples: PackedFloat32Array) -> PackedByteArray:
	var bytes := PackedByteArray()
	bytes.resize(samples.size() * 2)
	for i in samples.size():
		var v: int = int(clampf(samples[i], -1.0, 1.0) * 32767.0)
		bytes.encode_s16(i * 2, v)
	return bytes

func _wav(samples: PackedFloat32Array, loop: bool = false) -> AudioStreamWAV:
	var s := AudioStreamWAV.new()
	s.format = AudioStreamWAV.FORMAT_16_BITS
	s.mix_rate = RATE
	s.stereo = false
	s.data = _sample_to_bytes(samples)
	if loop:
		s.loop_mode = AudioStreamWAV.LOOP_FORWARD
		s.loop_begin = 0
		s.loop_end = samples.size()
	return s

func _env(i: int, n: int) -> float:
	# simple attack/release to avoid clicks
	var a: int = int(n * 0.1)
	var r: int = int(n * 0.25)
	if i < a:
		return float(i) / max(1, a)
	if i > n - r:
		return float(n - i) / max(1, r)
	return 1.0

func _tone(freqs: Array, dur: float, vol: float, wave: String) -> AudioStreamWAV:
	var n: int = int(dur * RATE)
	var out := PackedFloat32Array()
	out.resize(n)
	for i in n:
		var t: float = float(i) / RATE
		var v := 0.0
		for f in freqs:
			var ph: float = fmod(t * float(f), 1.0)
			match wave:
				"square":
					v += 1.0 if ph < 0.5 else -1.0
				"saw":
					v += 2.0 * ph - 1.0
				_:
					v += sin(TAU * float(f) * t)
		v = (v / freqs.size()) * vol * _env(i, n)
		out[i] = v
	return _wav(out)

func _noise(dur: float, vol: float) -> AudioStreamWAV:
	var n: int = int(dur * RATE)
	var out := PackedFloat32Array()
	out.resize(n)
	var rng := RandomNumberGenerator.new()
	rng.seed = 12345
	for i in n:
		out[i] = rng.randf_range(-1.0, 1.0) * vol * _env(i, n)
	return _wav(out)

func _seq(notes: Array, vol: float) -> AudioStreamWAV:
	var out := PackedFloat32Array()
	for note in notes:
		var f: float = note[0]
		var dur: float = note[1]
		var n: int = int(dur * RATE)
		for i in n:
			var t: float = float(i) / RATE
			out.append(sin(TAU * f * t) * vol * _env(i, n))
	return _wav(out)

# A calm, loopable pentatonic theme (drone + arpeggio).
func _build_theme() -> AudioStreamWAV:
	var melody := [220.0, 261.63, 329.63, 261.63, 293.66, 220.0, 196.0, 261.63]
	var note_dur := 0.5
	var drone := 110.0
	var out := PackedFloat32Array()
	for m in melody:
		var n: int = int(note_dur * RATE)
		for i in n:
			var t: float = float(i) / RATE
			var lead: float = sin(TAU * float(m) * t) * 0.28 * _env(i, n)
			var bass: float = sin(TAU * drone * t) * 0.16
			out.append(lead + bass)
	return _wav(out, true)

# --- persistence ---
func _load_prefs() -> void:
	if not FileAccess.file_exists(PREFS_PATH):
		return
	var f := FileAccess.open(PREFS_PATH, FileAccess.READ)
	if f == null:
		return
	var parsed = JSON.parse_string(f.get_as_text())
	f.close()
	if typeof(parsed) == TYPE_DICTIONARY:
		_muted = bool(parsed.get("muted", false))

func _save_prefs() -> void:
	var f := FileAccess.open(PREFS_PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify({"muted": _muted}))
		f.close()
