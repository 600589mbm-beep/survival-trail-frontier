extends Node
## Automated simulation test — headless crash / invariant / save-load harness.
## Run:  godot --headless SurvivalTrailFrontier/tests/SimTest.tscn
## (or via tests/run_tests.sh). Plays many randomized runs across every
## leader/route/wagon, asserting invariants, then quits with code 0 (pass) / 1 (fail).

const RUNS := 400
const MAX_DAYS := 400

var _fails: Array = []
var _ending_counts := {}
var _last_ending := {}
var _rng := RandomNumberGenerator.new()

func _ready() -> void:
	GameState.run_ended.connect(func(e): _last_ending = e)
	_rng.seed = 20260529
	var total_days := 0
	for i in RUNS:
		total_days += _play_one(i)
	_test_save_load_roundtrip()

	print("\n==== SimTest results ====")
	print("runs: %d   avg days/run: %.1f" % [RUNS, float(total_days) / RUNS])
	print("endings: %s" % JSON.stringify(_ending_counts))
	if _fails.is_empty():
		print("PASS — no invariant violations across %d runs" % RUNS)
		get_tree().quit(0)
	else:
		print("FAIL — %d violations:" % _fails.size())
		for f in _fails:
			print("  - " + f)
		get_tree().quit(1)

func _fail(msg: String) -> void:
	if _fails.size() < 50:
		_fails.append(msg)

func _play_one(idx: int) -> int:
	var leader := _rng.randi_range(0, EventDB.LEADERS.size() - 1)
	var route := _rng.randi_range(0, EventDB.ROUTES.size() - 1)
	var wagon: String = EventDB.WAGONS[_rng.randi_range(0, EventDB.WAGONS.size() - 1)].id
	_last_ending = {}
	GameState.new_run(leader, route, wagon, false, 0)

	# provision like a competent player: spread coin, weighted to food/water
	var shop := ["food", "water", "food", "water", "feed", "medicine", "ammo"]
	var s := 0
	while GameState.resources.money >= 8 and s < 300:
		GameState.buy(shop[s % shop.size()], 5)
		s += 1

	var days := 0
	var paces := GameState.PACES.keys()
	while GameState.running and days < MAX_DAYS:
		var pace: String = paces[_rng.randi_range(0, paces.size() - 1)]
		var ev: Dictionary = GameState.advance_day(pace)
		days += 1
		_check_invariants(idx, days)
		if not GameState.running:
			break
		if not ev.is_empty():
			var choice: Dictionary = ev.choices[_rng.randi_range(0, ev.choices.size() - 1)]
			if choice.get("minigame", "") == "hunt":
				GameState.apply_choice(choice)
				GameState.apply_hunt_result(_rng.randi_range(0, 3))
			else:
				GameState.apply_choice(choice)
			_check_invariants(idx, days)

	if GameState.running and days >= MAX_DAYS:
		_fail("run %d did not terminate within %d days" % [idx, MAX_DAYS])
	var eid: String = _last_ending.get("id", "none")
	_ending_counts[eid] = int(_ending_counts.get(eid, 0)) + 1
	return days

func _check_invariants(idx: int, day: int) -> void:
	for r in EventDB.RESOURCES:
		if GameState.resources[r] < 0:
			_fail("run %d day %d: resource %s negative (%d)" % [idx, day, r, GameState.resources[r]])
	if GameState.miles < 0 or GameState.miles > GameState.total_miles:
		_fail("run %d day %d: miles out of range (%d/%d)" % [idx, day, GameState.miles, GameState.total_miles])
	for m in GameState.party:
		if m.health < 0 or m.health > 100:
			_fail("run %d day %d: %s health out of range (%d)" % [idx, day, m.name, m.health])
		if m.alive and m.health <= 0:
			_fail("run %d day %d: %s alive but health<=0" % [idx, day, m.name])

func _test_save_load_roundtrip() -> void:
	GameState.new_run(0, 0, "settler", false, 0)
	GameState.buy("food", 15)
	GameState.advance_day("steady")
	var before := JSON.stringify(GameState.snapshot())
	SaveManager.save_game()
	# mutate, then reload and compare
	GameState.resources["food"] = -999
	GameState.miles = 99999
	if not SaveManager.load_game():
		_fail("save/load: load_game() returned false")
		return
	var after := JSON.stringify(GameState.snapshot())
	if before != after:
		_fail("save/load: snapshot mismatch after round-trip")
	else:
		print("save/load round-trip: OK")
	SaveManager.clear_save()
