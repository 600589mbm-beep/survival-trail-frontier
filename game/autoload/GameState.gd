extends Node
## GameState — run simulation + signals. UI listens; it never holds rules.

signal state_changed
signal day_logged(text)
signal run_ended(ending)

# Pace presets: miles/day and consumption multiplier for travel items.
const PACES := {
	"steady":   {"label":"Steady",   "miles":45, "mult":1.0,  "morale":0},
	"grueling": {"label":"Grueling", "miles":70, "mult":1.4,  "morale":-3},
	"rest":     {"label":"Rest",     "miles":0,  "mult":0.5,  "morale":4},
}

var leader_index: int = 0
var leader: Dictionary = {}
var party: Array = []          # [{name, trait, health(0-100), alive, morale_bonus}]
var resources: Dictionary = {} # res_name -> int
var day: int = 1
var miles: int = 0
var total_miles: int = 0
var running: bool = false
var seed_value: int = 0
var daily_challenge: bool = false
var _rng := RandomNumberGenerator.new()
var log_lines: Array = []      # rolling recent log

func _ready() -> void:
	pass

# --- run lifecycle ---
func new_run(leader_idx: int, starting_money: int = 60, is_daily: bool = false, daily_seed: int = 0) -> void:
	leader_index = leader_idx
	leader = EventDB.LEADERS[leader_idx]
	daily_challenge = is_daily
	if is_daily:
		seed_value = daily_seed
	else:
		seed_value = randi()
	_rng.seed = seed_value
	day = 1
	miles = 0
	total_miles = EventDB.ROUTE.total_miles
	running = true
	log_lines.clear()

	# Resources start near-empty except money; player buys at outfitter.
	resources = {}
	for r in EventDB.RESOURCES:
		resources[r] = 0
	resources["money"] = starting_money
	# small free starter so a no-buy run isn't instantly dead
	resources["food"] = 20
	resources["water"] = 20
	resources["feed"] = 10

	# Build party: leader at index 0, then template members.
	party = []
	party.append({"name": leader.name, "trait": leader.trait, "health": 100, "alive": true})
	for m in EventDB.PARTY_TEMPLATE:
		party.append({"name": m.name, "trait": m.trait, "health": 100, "alive": true})

	emit_signal("state_changed")

func outfitter_price(res_name: String) -> int:
	var base := int(EventDB.OUTFITTER_PRICES.get(res_name, 999))
	if leader.get("bonus") == "cheap_outfit":
		return int(ceil(base * 0.8))
	return base

func buy(res_name: String, qty: int) -> bool:
	var cost := outfitter_price(res_name) * qty
	if cost > resources["money"] or qty <= 0:
		return false
	resources["money"] -= cost
	resources[res_name] += qty
	emit_signal("state_changed")
	return true

# --- daily tick. Returns an event dict to present, or {} if none. ---
func advance_day(pace_key: String) -> Dictionary:
	if not running:
		return {}
	var pace: Dictionary = PACES[pace_key]
	var alive := living_count()

	# consume
	for r in EventDB.DAILY_CONSUMPTION.keys():
		var amt: int = int(round(EventDB.DAILY_CONSUMPTION[r] * alive * pace.mult))
		resources[r] = max(0, resources[r] - amt)

	# starvation / thirst -> health loss
	_apply_scarcity()

	# pace morale
	_adjust_morale(pace.morale)
	if leader.get("bonus") != "morale_decay_slow":
		_adjust_morale(-1) # slow natural grind

	# travel
	miles = min(total_miles, miles + int(pace.miles))
	day += 1

	# resolve health -> deaths
	_resolve_health()

	var line := "Day %d — %d/%d miles. %s pace." % [day - 1, miles, total_miles, pace.label]
	_log(line)

	emit_signal("state_changed")

	# arrival?
	if miles >= total_miles or living_count() <= 0:
		_finish()
		return {}

	# event roll: rest days are calmer
	var event_chance := 0.55 if pace_key != "rest" else 0.3
	if _rng.randf() < event_chance:
		return _pick_event()
	return {}

func _pick_event() -> Dictionary:
	var pool: Array = EventDB.EVENTS
	var total_w := 0
	for e in pool:
		total_w += int(e.get("weight", 1))
	var roll := _rng.randi_range(1, total_w)
	for e in pool:
		roll -= int(e.get("weight", 1))
		if roll <= 0:
			return e
	return pool[0]

# --- apply a chosen option's outcome dict. Returns result log text. ---
func apply_choice(choice: Dictionary) -> String:
	var outcome: Dictionary
	if choice.has("chance"):
		var c: float = float(choice.chance)
		if leader.get("bonus") == "event_luck":
			c = min(0.95, c + 0.1)
		outcome = choice.on_success if _rng.randf() < c else choice.on_fail
	else:
		outcome = choice.get("effects", {})
	_apply_outcome(outcome)
	emit_signal("state_changed")
	if miles >= total_miles or living_count() <= 0:
		_finish()
	var txt: String = outcome.get("log", "")
	if txt != "":
		_log(txt)
	return txt

func _apply_outcome(o: Dictionary) -> void:
	if o.has("res"):
		for r in o.res.keys():
			var delta: int = int(o.res[r])
			# leader efficiencies soften costs
			if delta < 0 and r == "medicine" and leader.get("bonus") == "medicine_efficient":
				delta = int(delta / 2)
			if delta < 0 and r == "parts" and leader.get("bonus") == "parts_efficient":
				delta = int(ceil(delta / 2.0))
			resources[r] = max(0, resources.get(r, 0) + delta)
	if o.has("morale"):
		_adjust_morale(int(o.morale))
	if o.has("health"):
		_apply_health(int(o.health.amount), String(o.health.get("target", "random")))
	_resolve_health()

# --- party stat helpers ---
func living_count() -> int:
	var n := 0
	for m in party:
		if m.alive:
			n += 1
	return n

func avg_morale() -> float:
	# morale modeled as average health proxy + a run morale meter
	return clampf(_run_morale, 0, 100)

var _run_morale: float = 60.0

func _adjust_morale(d: int) -> void:
	_run_morale = clampf(_run_morale + d, 0, 100)

func _apply_scarcity() -> void:
	var penalty := 0
	if resources["food"] <= 0:
		penalty += 8
	if resources["water"] <= 0:
		penalty += 10
	if penalty > 0:
		_apply_health(-penalty, "all")
		_adjust_morale(-3)

func _apply_health(amount: int, target: String) -> void:
	if amount == 0:
		return
	if target == "all":
		for m in party:
			if m.alive:
				m.health = clampi(m.health + amount, 0, 100)
	elif target == "worst":
		var worst = null
		for m in party:
			if m.alive and (worst == null or m.health < worst.health):
				worst = m
		if worst != null:
			worst.health = clampi(worst.health + amount, 0, 100)
	else: # random
		var alive_members := []
		for m in party:
			if m.alive:
				alive_members.append(m)
		if alive_members.size() > 0:
			var pick = alive_members[_rng.randi_range(0, alive_members.size() - 1)]
			pick.health = clampi(pick.health + amount, 0, 100)

func _resolve_health() -> void:
	for m in party:
		if m.alive and m.health <= 0:
			m.alive = false
			_adjust_morale(-12)
			_log("%s did not make it." % m.name)

func _finish() -> void:
	running = false
	var ending := EventDB.get_ending(living_count(), avg_morale())
	emit_signal("run_ended", ending)

func _log(text: String) -> void:
	log_lines.append(text)
	if log_lines.size() > 30:
		log_lines.pop_front()
	emit_signal("day_logged", text)

# --- save snapshot ---
func snapshot() -> Dictionary:
	return {
		"leader_index": leader_index, "party": party, "resources": resources,
		"day": day, "miles": miles, "total_miles": total_miles,
		"run_morale": _run_morale, "seed": seed_value, "running": running,
		"daily_challenge": daily_challenge, "log_lines": log_lines,
	}

func restore(d: Dictionary) -> void:
	leader_index = int(d.leader_index)
	leader = EventDB.LEADERS[leader_index]
	party = d.party
	resources = d.resources
	day = int(d.day)
	miles = int(d.miles)
	total_miles = int(d.total_miles)
	_run_morale = float(d.run_morale)
	seed_value = int(d.seed)
	running = bool(d.running)
	daily_challenge = bool(d.get("daily_challenge", false))
	log_lines = d.get("log_lines", [])
	_rng.seed = seed_value
	emit_signal("state_changed")
