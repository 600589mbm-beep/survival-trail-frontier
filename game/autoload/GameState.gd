extends Node
## GameState — run simulation + signals. UI listens; it never holds rules.

signal state_changed
signal day_logged(text)
signal run_ended(ending)

const PACES := {
	"steady":   {"label":"Steady",   "miles":45, "mult":1.0, "morale":0},
	"grueling": {"label":"Grueling", "miles":70, "mult":1.4, "morale":-3},
	"rest":     {"label":"Rest",     "miles":0,  "mult":0.5, "morale":4},
}

const BASE_MONEY := 90

var leader_index: int = 0
var leader: Dictionary = {}
var route_index: int = 0
var route: Dictionary = {}
var wagon: Dictionary = {}
var party: Array = []           # [{name,trait,health,alive,bond,conditions:[String]}]
var resources: Dictionary = {}
var day: int = 1
var miles: int = 0
var total_miles: int = 0
var weather: String = "clear"
var running: bool = false
var seed_value: int = 0
var daily_challenge: bool = false
var log_lines: Array = []
var recruited_names: Array = []   # names already used so we don't recruit duplicates
var _rng := RandomNumberGenerator.new()
var _run_morale: float = 60.0

# --- run lifecycle ---
func new_run(leader_idx: int, route_idx: int, wagon_id: String, is_daily: bool = false, daily_seed: int = 0) -> void:
	leader_index = leader_idx
	leader = EventDB.LEADERS[leader_idx]
	route_index = route_idx
	route = EventDB.ROUTES[route_idx]
	wagon = _wagon_by_id(wagon_id)
	daily_challenge = is_daily
	seed_value = daily_seed if is_daily else randi()
	_rng.seed = seed_value
	day = 1
	miles = 0
	total_miles = int(route.total_miles)
	running = true
	_run_morale = 60.0
	log_lines.clear()
	recruited_names.clear()

	resources = {}
	for r in EventDB.RESOURCES:
		resources[r] = 0
	resources["money"] = BASE_MONEY + int(wagon.get("start_money", 0))
	resources["food"] = 30
	resources["water"] = 30
	resources["feed"] = 15

	party = []
	party.append(_make_member(leader.name, leader.trait))
	for m in EventDB.PARTY_TEMPLATE:
		party.append(_make_member(m.name, m.trait))

	_roll_weather()
	emit_signal("state_changed")

func _make_member(nm: String, tr: String) -> Dictionary:
	return {"name": nm, "trait": tr, "health": 100, "alive": true, "bond": 60, "conditions": []}

func _wagon_by_id(id: String) -> Dictionary:
	for w in EventDB.WAGONS:
		if w.id == id:
			return w
	return EventDB.WAGONS[1] # settler default

func _roll_weather() -> void:
	var table: Array = EventDB.BIOME_WEATHER.get(route.get("biome", "temperate"), ["clear"])
	weather = table[_rng.randi_range(0, table.size() - 1)]

# --- outfitter ---
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

# --- a day spent NOT travelling (hunting / resting at a town). No miles, no random event. ---
func pass_day_no_travel(pace_key: String, food_mult: float = 1.0) -> void:
	if not running:
		return
	var alive := living_count()
	for r in EventDB.DAILY_CONSUMPTION.keys():
		var amt: int = int(round(EventDB.DAILY_CONSUMPTION[r] * alive * food_mult))
		resources[r] = max(0, resources[r] - amt)
	_apply_scarcity()
	_progress_illness(pace_key) # "rest" clears exhaustion; "hunt" does not
	day += 1
	_roll_weather()
	_resolve_health()
	_log("Day %d — you %s." % [day - 1, ("rested in town" if pace_key == "rest" else "went hunting")])
	emit_signal("state_changed")
	if running:
		SaveManager.save_game()
	if living_count() <= 0:
		_finish()

# Spend ammo to begin a hunt (player-initiated). Returns false if no ammo.
func begin_hunt() -> bool:
	if resources["ammo"] < 1:
		return false
	resources["ammo"] = max(0, resources["ammo"] - 3)
	pass_day_no_travel("hunt")
	emit_signal("state_changed")
	return true

# Rest a day at a town: recover health + morale (costs the day's food/water).
func rest_in_town() -> void:
	pass_day_no_travel("rest")
	if not running:
		return
	_apply_health(8, "all")
	_adjust_morale(6)
	_log("A night in town. The party recovers a little.")
	emit_signal("state_changed")
	if running:
		SaveManager.save_game()

# --- daily tick ---
func advance_day(pace_key: String) -> Dictionary:
	if not running:
		return {}
	var pace: Dictionary = PACES[pace_key]
	var wx: Dictionary = EventDB.WEATHER[weather]
	var alive := living_count()

	# consume (weather raises consumption)
	for r in EventDB.DAILY_CONSUMPTION.keys():
		var amt: int = int(round(EventDB.DAILY_CONSUMPTION[r] * alive * pace.mult * wx.consume_mult))
		resources[r] = max(0, resources[r] - amt)

	_apply_scarcity()
	_progress_illness(pace_key)

	# morale: pace + weather + slow grind (leader Steady cancels grind)
	_adjust_morale(int(pace.morale) + int(wx.morale))
	if leader.get("bonus") != "morale_decay_slow":
		_adjust_morale(-1)

	# travel (weather + wagon modify miles)
	var miles_today := int(round(pace.miles * float(wx.miles_mult) * float(wagon.get("miles_mult", 1.0))))
	miles = min(total_miles, miles + miles_today)
	day += 1
	_roll_weather()

	_resolve_health()
	_log("Day %d — %d/%d mi · %s pace · %s." % [day - 1, miles, total_miles, pace.label, EventDB.WEATHER[weather].label])
	emit_signal("state_changed")

	if running:
		SaveManager.save_game() # auto-save (mobile polish)

	if miles >= total_miles or living_count() <= 0:
		_finish()
		return {}

	var event_chance := (0.55 if pace_key != "rest" else 0.3) + float(wx.event_bonus)
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

# --- choice resolution ---
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
	if running and miles < total_miles and living_count() > 0:
		SaveManager.save_game()
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
			if delta < 0 and r == "medicine" and leader.get("bonus") == "medicine_efficient":
				delta = int(delta / 2)
			if delta < 0 and r == "parts":
				var resist: float = float(wagon.get("parts_resist", 0.0))
				if leader.get("bonus") == "parts_efficient":
					resist = min(0.75, resist + 0.5)
				delta = int(ceil(delta * (1.0 - resist)))
			resources[r] = max(0, resources.get(r, 0) + delta)
	if o.has("morale"):
		_adjust_morale(int(o.morale))
	if o.has("health"):
		_apply_health(int(o.health.amount), String(o.health.get("target", "random")))
	if o.has("inflict"):
		_inflict(String(o.inflict.who), String(o.inflict.cond))
	if o.has("cure"):
		_cure(String(o.cure.who), String(o.cure.cond))
	if o.has("bond"):
		_adjust_bond(String(o.bond.who), int(o.bond.amount))
	if o.has("recruit") and bool(o.recruit):
		_recruit()
	_resolve_health()

# Add a new member from the recruit roster (skips names already used / present).
func _recruit() -> void:
	var pool := []
	for r in EventDB.RECRUITS:
		if not recruited_names.has(r.name) and not _has_member(r.name):
			pool.append(r)
	if pool.is_empty():
		return
	var pick: Dictionary = pool[_rng.randi_range(0, pool.size() - 1)]
	var member := _make_member(pick.name, pick.trait)
	member.bond = 50
	party.append(member)
	recruited_names.append(pick.name)
	_log("%s (%s) joins the party." % [pick.name, pick.trait])

func _has_member(nm: String) -> bool:
	for m in party:
		if m.name == nm:
			return true
	return false

# Apply the hunting mini-game outcome (called by UI after the mini-game ends).
func apply_hunt_result(hits: int) -> void:
	var food := hits * 12
	resources["food"] += food
	if food > 0:
		_adjust_morale(2)
		_log("The hunt brought in %d food (%d clean shots)." % [food, hits])
	else:
		_adjust_morale(-2)
		_log("The hunt came up empty. Ammo spent for nothing.")
	emit_signal("state_changed")
	if running:
		SaveManager.save_game()

# --- party stats ---
func living_count() -> int:
	var n := 0
	for m in party:
		if m.alive:
			n += 1
	return n

func _avg_bond() -> float:
	var total := 0.0
	var n := 0
	for m in party:
		if m.alive:
			total += float(m.bond)
			n += 1
	return (total / n) if n > 0 else 0.0

func avg_morale() -> float:
	# cohesion (run morale) blended with relationship bonds
	return clampf(0.6 * _run_morale + 0.4 * _avg_bond(), 0, 100)

func _adjust_morale(d: int) -> void:
	_run_morale = clampf(_run_morale + d, 0, 100)

func _adjust_bond(who: String, amount: int) -> void:
	if who == "all":
		for m in party:
			if m.alive:
				m.bond = clampi(m.bond + amount, 0, 100)
	else:
		var pick = _pick_alive()
		if pick != null:
			pick.bond = clampi(pick.bond + amount, 0, 100)

func _apply_scarcity() -> void:
	var penalty := 0
	if resources["food"] <= 0:
		penalty += 4
	if resources["water"] <= 0:
		penalty += 5
	if penalty > 0:
		_apply_health(-penalty, "all")
		_adjust_morale(-3)

func _progress_illness(pace_key: String) -> void:
	for m in party:
		if not m.alive:
			continue
		var keep: Array = []
		for cond in m.conditions:
			var info: Dictionary = EventDB.ILLNESSES[cond]
			m.health = clampi(m.health - int(info.drain), 0, 100)
			# Exhaustion clears on a Rest day; others linger until treated.
			if cond == "exhaustion" and pace_key == "rest":
				continue
			keep.append(cond)
		m.conditions = keep

func _inflict(who: String, cond: String) -> void:
	if who == "all":
		for m in party:
			if m.alive and not m.conditions.has(cond):
				m.conditions.append(cond)
	else:
		var pick = _pick_alive() if who == "random" else _worst()
		if pick != null and not pick.conditions.has(cond):
			pick.conditions.append(cond)

func _cure(who: String, cond: String) -> void:
	if who == "all":
		for m in party:
			m.conditions.erase(cond)
	else:
		var pick = _pick_alive() if who == "random" else _worst()
		if pick != null:
			pick.conditions.erase(cond)

func _apply_health(amount: int, target: String) -> void:
	if amount == 0:
		return
	if target == "all":
		for m in party:
			if m.alive:
				m.health = clampi(m.health + amount, 0, 100)
	elif target == "worst":
		var w = _worst()
		if w != null:
			w.health = clampi(w.health + amount, 0, 100)
	else:
		var pick = _pick_alive()
		if pick != null:
			pick.health = clampi(pick.health + amount, 0, 100)

func _pick_alive():
	var alive_members := []
	for m in party:
		if m.alive:
			alive_members.append(m)
	if alive_members.is_empty():
		return null
	return alive_members[_rng.randi_range(0, alive_members.size() - 1)]

func _worst():
	var w = null
	for m in party:
		if m.alive and (w == null or m.health < w.health):
			w = m
	return w

func _resolve_health() -> void:
	for m in party:
		if m.alive and m.health <= 0:
			m.alive = false
			_adjust_morale(-12)
			_log("%s did not make it." % m.name)

func _finish() -> void:
	running = false
	SaveManager.clear_save()
	emit_signal("run_ended", EventDB.get_ending(living_count(), avg_morale()))

func _log(text: String) -> void:
	log_lines.append(text)
	if log_lines.size() > 30:
		log_lines.pop_front()
	emit_signal("day_logged", text)

# --- save snapshot ---
func snapshot() -> Dictionary:
	return {
		"leader_index": leader_index, "route_index": route_index,
		"wagon_id": wagon.get("id", "settler"), "party": party, "resources": resources,
		"day": day, "miles": miles, "total_miles": total_miles, "weather": weather,
		"run_morale": _run_morale, "seed": seed_value, "running": running,
		"daily_challenge": daily_challenge, "log_lines": log_lines,
		"recruited_names": recruited_names,
	}

func restore(d: Dictionary) -> void:
	leader_index = int(d.leader_index)
	leader = EventDB.LEADERS[leader_index]
	route_index = int(d.get("route_index", 0))
	route = EventDB.ROUTES[route_index]
	wagon = _wagon_by_id(String(d.get("wagon_id", "settler")))
	# JSON parses all numbers as float; coerce back to int so state stays type-clean.
	var p := []
	for m in d.party:
		p.append({
			"name": String(m.name), "trait": String(m.trait),
			"health": int(m.health), "alive": bool(m.alive),
			"bond": int(m.get("bond", 60)), "conditions": m.get("conditions", []),
		})
	party = p
	var res := {}
	for k in d.resources.keys():
		res[k] = int(d.resources[k])
	resources = res
	day = int(d.day)
	miles = int(d.miles)
	total_miles = int(d.total_miles)
	weather = String(d.get("weather", "clear"))
	_run_morale = float(d.run_morale)
	seed_value = int(d.seed)
	running = bool(d.running)
	daily_challenge = bool(d.get("daily_challenge", false))
	log_lines = d.get("log_lines", [])
	recruited_names = d.get("recruited_names", [])
	_rng.seed = seed_value
	emit_signal("state_changed")
