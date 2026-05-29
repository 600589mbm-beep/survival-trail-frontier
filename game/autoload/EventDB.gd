extends Node
## EventDB — all static content. Original world ("The Reach"). No protected IP.
## Pure data: safe to expand toward the 80-150 event / 4-6 route production target.

# --- 8 resources (money is one of them) ---
const RESOURCES := ["food", "water", "medicine", "ammo", "parts", "clothing", "feed", "money"]

const RESOURCE_LABELS := {
	"food": "Food", "water": "Water", "medicine": "Medicine", "ammo": "Ammo",
	"parts": "Parts", "clothing": "Clothing", "feed": "Feed", "money": "Coin",
}

const OUTFITTER_PRICES := {
	"food": 1, "water": 1, "medicine": 6, "ammo": 2,
	"parts": 8, "clothing": 4, "feed": 1,
}

const DAILY_CONSUMPTION := {
	"food": 2, "water": 2, "feed": 1,
}

# --- 5 selectable leaders ---
const LEADERS := [
	{"name": "Captain Mara Voss", "trait": "Steady",   "bonus": "morale_decay_slow",
		"blurb": "A former caravan guard. Her calm keeps the party together longer."},
	{"name": "Doc Elias Renn",    "trait": "Healer",   "bonus": "medicine_efficient",
		"blurb": "A field surgeon. Medicine goes twice as far in his hands."},
	{"name": "Tess Bowery",       "trait": "Scout",    "bonus": "event_luck",
		"blurb": "Knows the wild. Risky choices fail less often."},
	{"name": "Old Hale",          "trait": "Tinker",   "bonus": "parts_efficient",
		"blurb": "A wagon-wright. Repairs cost fewer parts."},
	{"name": "Junia Cole",        "trait": "Trader",   "bonus": "cheap_outfit",
		"blurb": "A sharp haggler. Supplies cost 20% less at the outfitter."},
]

const PARTY_TEMPLATE := [
	{"name": "Sam",  "trait": "Tough"},
	{"name": "Rhea", "trait": "Cook"},
	{"name": "Boone","trait": "Hunter"},
	{"name": "Lila", "trait": "Quiet"},
]

# --- Wagon types (3) — tradeoffs, no pay-to-win ---
const WAGONS := [
	{"id":"scout",    "name":"Scout Cart",    "miles_mult":1.25, "parts_resist":0.0, "start_money":0,
		"blurb":"Light and fast (+25% miles) but fragile. For aggressive runs."},
	{"id":"settler",  "name":"Settler Wagon", "miles_mult":1.0,  "parts_resist":0.25, "start_money":10,
		"blurb":"Balanced and sturdy. The reliable default."},
	{"id":"freighter","name":"Freighter",     "miles_mult":0.8,  "parts_resist":0.5,  "start_money":20,
		"blurb":"Slow (-20% miles) but tough and roomy (+20 starting coin)."},
]

# --- Cosmetic skins (Month-6 monetization; purely visual, never affects play) ---
const SKINS := [
	{"id":"default", "name":"Trailworn",   "tint":"e0a458"},
	{"id":"crimson", "name":"Crimson Road", "tint":"eb5757"},
	{"id":"emerald", "name":"Greenway",     "tint":"6fcf97"},
	{"id":"ironclad","name":"Ironclad",     "tint":"9aa7bd"},
]

# --- Routes (3 of the 4-6 production target). biome drives weather table. ---
const ROUTES := [
	{"id":"ashford",  "name":"The Ashford Reach", "total_miles":800,  "biome":"temperate", "difficulty":"Medium",
		"intro":"Eight hundred miles of broken country lie between Fort Kestrel and the green valleys of Ashford. Load the wagon. Choose your road. Not everyone arrives."},
	{"id":"saltpan",  "name":"The Saltpan Crossing", "total_miles":600, "biome":"desert", "difficulty":"Hard",
		"intro":"Six hundred miles of salt flats and dead air. Water is everything here. Leave Greywell with full casks or don't leave at all."},
	{"id":"wintergale","name":"Wintergale Pass", "total_miles":1000, "biome":"alpine", "difficulty":"Brutal",
		"intro":"A thousand miles over the spine of the world. The cold does not negotiate. Clothing and feed matter as much as courage."},
]

# Weather tables per biome: id, label, consume_mult, event_bonus, morale, miles_mult
const WEATHER := {
	"clear": {"label":"Clear", "consume_mult":1.0, "event_bonus":0.0, "morale":1, "miles_mult":1.0},
	"rain":  {"label":"Rain",  "consume_mult":1.0, "event_bonus":0.05,"morale":-1,"miles_mult":0.9},
	"storm": {"label":"Storm", "consume_mult":1.1, "event_bonus":0.15,"morale":-3,"miles_mult":0.75},
	"heat":  {"label":"Heat",  "consume_mult":1.3, "event_bonus":0.1, "morale":-2,"miles_mult":0.9},
	"snow":  {"label":"Snow",  "consume_mult":1.2, "event_bonus":0.1, "morale":-2,"miles_mult":0.7},
	"fog":   {"label":"Fog",   "consume_mult":1.0, "event_bonus":0.1, "morale":-1,"miles_mult":0.85},
}

const BIOME_WEATHER := {
	"temperate": ["clear","clear","clear","rain","rain","storm","fog"],
	"desert":    ["clear","clear","heat","heat","heat","storm","clear"],
	"alpine":    ["clear","snow","snow","snow","storm","fog","clear"],
}

# --- Named illness conditions (original; no branded gags) ---
# A member can carry conditions; each drains health/day until cured by medicine or rest.
const ILLNESSES := {
	"fever":      {"name":"Trail Fever",   "drain":4, "cure_med":2},
	"campsick":   {"name":"Camp Sickness", "drain":5, "cure_med":2},
	"exhaustion": {"name":"Exhaustion",    "drain":3, "cure_med":0},  # cured by Rest
	"frostbite":  {"name":"Frostbite",     "drain":4, "cure_med":3},
	"heatstroke": {"name":"Heatstroke",    "drain":5, "cure_med":1},
	"injury":     {"name":"Broken Limb",   "drain":3, "cure_med":3},
}

# --- Events (38). choice schema unchanged + optional "minigame":"hunt" / "relationship". ---
const EVENTS := [
	{"id":"river_ford","title":"The Cold River","weight":3,
		"text":"A wide river blocks the trail. The ford looks shallow but the current is fast.",
		"choices":[
			{"text":"Ford it now (risky, free)","chance":0.6,
				"on_success":{"log":"You cross clean. Wheels hold."},
				"on_fail":{"res":{"parts":-2,"food":-8},"health":{"amount":-15,"target":"random"},
					"inflict":{"who":"random","cond":"injury"},
					"log":"The wagon lurches. Gear washes downstream and someone is hurt."}},
			{"text":"Pay the ferryman (6 coin)","effects":{"res":{"money":-6},"log":"Slow, dull, safe. You cross dry."}},
			{"text":"Wait two days for low water","effects":{"res":{"food":-4,"water":-4,"feed":-2},"morale":-3,
				"log":"The water drops. The waiting frays nerves."}},
		]},
	{"id":"fever","title":"Trail Fever","weight":3,
		"text":"One of the party wakes shivering and slick with sweat.",
		"choices":[
			{"text":"Dose with medicine","effects":{"res":{"medicine":-2},"cure":{"who":"worst","cond":"fever"},
				"health":{"amount":8,"target":"worst"},"log":"The fever breaks by morning."}},
			{"text":"Rest a day, no medicine","effects":{"res":{"food":-4,"water":-4},"morale":-2,
				"inflict":{"who":"worst","cond":"fever"},"log":"You lose a day. They mend, slowly."}},
			{"text":"Push on regardless","effects":{"inflict":{"who":"random","cond":"fever"},"morale":-4,
				"log":"You make miles, but the sickness deepens."}},
		]},
	{"id":"hunt","title":"Game on the Ridge","weight":3,
		"text":"A herd grazes on the next ridge. Steady your aim — fresh meat is on the line.",
		"choices":[
			{"text":"Hunt (mini-game, uses ammo)","minigame":"hunt","effects":{"res":{"ammo":-3}}},
			{"text":"Leave them be","effects":{"log":"You keep moving. The wagon stays quiet."}},
		]},
	{"id":"broken_axle","title":"Cracked Axle","weight":2,
		"text":"A wheel drops into a rut. The front axle splinters.",
		"choices":[
			{"text":"Repair with parts","effects":{"res":{"parts":-3},"log":"An afternoon's work and you roll again."}},
			{"text":"Lash it and limp on","effects":{"res":{"feed":-3},"morale":-3,"health":{"amount":-5,"target":"random"},
				"log":"The wagon groans for miles. Hard riding on everyone."}},
		]},
	{"id":"stranger","title":"A Stranger on the Road","weight":2,
		"text":"A lone traveler hails you, asking to join the party for safety.",
		"choices":[
			{"text":"Welcome them","effects":{"morale":6,"res":{"food":-6,"water":-6},
				"log":"Good company. Also one more belly to feed."}},
			{"text":"Send them off","effects":{"morale":-4,"log":"You move on. The choice sits heavy."}},
			{"text":"Trade news only","effects":{"morale":2,"res":{"money":2},
				"log":"They mark a shortcut on your map and tip you a coin for bread."}},
		]},
	{"id":"storm","title":"Black Sky","weight":3,
		"text":"A wall of storm rolls in fast across open ground.",
		"choices":[
			{"text":"Make camp and ride it out","effects":{"res":{"food":-3,"feed":-2},"log":"Soaked but safe."}},
			{"text":"Drive through it","chance":0.5,
				"on_success":{"log":"You outrun the worst of it and gain ground."},
				"on_fail":{"res":{"clothing":-3,"parts":-1},"health":{"amount":-10,"target":"all"},"morale":-3,
					"log":"Lightning, hail, panic. Everyone suffers."}},
		]},
	{"id":"contaminated_water","title":"Bad Water","weight":2,
		"text":"The only spring for miles smells of rot.",
		"choices":[
			{"text":"Boil it (costs a day)","effects":{"res":{"food":-3,"water":15},"morale":-1,
				"log":"Slow, but the casks are full and clean."}},
			{"text":"Drink it anyway","chance":0.4,
				"on_success":{"res":{"water":15},"log":"It was fine. You got lucky."},
				"on_fail":{"res":{"water":15},"inflict":{"who":"all","cond":"campsick"},
					"log":"By night the whole party is doubled over."}},
			{"text":"Press on dry","effects":{"res":{"water":-6},"morale":-3,"log":"Thirsty miles."}},
		]},
	{"id":"wagon_trader","title":"Wayside Trader","weight":2,
		"text":"A trading post sits at a crossroads, wares spread on a blanket.",
		"choices":[
			{"text":"Buy medicine (8 coin)","effects":{"res":{"money":-8,"medicine":3},"log":"A fair deal for hard times."}},
			{"text":"Sell spare parts (+10 coin)","effects":{"res":{"money":10,"parts":-3},"log":"Coin in hand, lighter load."}},
			{"text":"Just water the animals","effects":{"res":{"feed":4},"log":"The oxen drink their fill."}},
		]},
	{"id":"theft","title":"Night Raiders","weight":2,
		"text":"You wake to figures slipping among the supplies.",
		"choices":[
			{"text":"Fire a warning shot","chance":0.7,
				"on_success":{"res":{"ammo":-1},"log":"They scatter into the dark. Nothing lost."},
				"on_fail":{"res":{"ammo":-1,"food":-12,"money":-5},"log":"A scuffle. They get away with food and coin."}},
			{"text":"Stay hidden, let them take a little","effects":{"res":{"food":-8},"morale":-2,
				"log":"You keep your skin. They keep your bread."}},
		]},
	{"id":"lost_trail","title":"The Trail Forks","weight":2,
		"text":"The path splits and your map disagrees with the ground.",
		"choices":[
			{"text":"Take the canyon (faster, risky)","chance":0.6,
				"on_success":{"res":{"food":-2},"log":"A shortcut. You save half a day."},
				"on_fail":{"res":{"food":-8,"feed":-4},"morale":-3,"log":"A dead end. Backtracking costs you dearly."}},
			{"text":"Stay on the ridge road (safe)","effects":{"res":{"food":-4,"feed":-2},"log":"Longer, but sure."}},
		]},
	{"id":"snakebite","title":"Snakebite","weight":2,
		"text":"A rattler strikes from the brush.",
		"choices":[
			{"text":"Treat with medicine","effects":{"res":{"medicine":-2},"health":{"amount":4,"target":"worst"},
				"log":"You draw the venom in time."}},
			{"text":"Cut and pray","chance":0.45,
				"on_success":{"health":{"amount":-4,"target":"worst"},"log":"They pull through, shaken."},
				"on_fail":{"health":{"amount":-22,"target":"worst"},"morale":-5,"inflict":{"who":"worst","cond":"injury"},
					"log":"A bad night. The leg swells black."}},
		]},
	{"id":"morale_song","title":"A Fire and a Song","weight":2,
		"text":"The party is worn thin. Someone pulls out a fiddle.",
		"choices":[
			{"text":"Rest and sing (costs food)","effects":{"res":{"food":-4},"morale":10,"bond":{"who":"all","amount":6},
				"log":"Laughter for the first time in days."}},
			{"text":"No time — keep watch","effects":{"morale":-2,"log":"The fiddle stays in its case."}},
		]},
	{"id":"abandoned_wagon","title":"Abandoned Wagon","weight":2,
		"text":"A wrecked wagon sits half-buried in dust, its owners long gone.",
		"choices":[
			{"text":"Salvage it","effects":{"res":{"parts":2,"clothing":2,"food":4},"morale":-2,
				"log":"Useful gear. A grim reminder of the road."}},
			{"text":"Leave it untouched","effects":{"morale":2,"log":"You let the dead keep their things."}},
		]},
	{"id":"heat","title":"Dead Heat","weight":2,
		"text":"The sun hammers a treeless flat. The animals stagger.",
		"choices":[
			{"text":"Travel by night","effects":{"res":{"water":-4},"morale":-1,"log":"Cooler going, but no real rest."}},
			{"text":"Push through the day","effects":{"res":{"water":-10,"feed":-4},"inflict":{"who":"random","cond":"heatstroke"},
				"log":"Heat fells one of the party."}},
		]},
	{"id":"sick_ox","title":"Ailing Ox","weight":2,
		"text":"One of the draft animals goes lame.",
		"choices":[
			{"text":"Rest and feed it","effects":{"res":{"feed":-5,"food":-3},"log":"It recovers. You lose a little ground."}},
			{"text":"Press on, half team","effects":{"res":{"parts":-1},"morale":-2,"health":{"amount":-4,"target":"random"},
				"log":"Slow, jolting miles on a tired wagon."}},
		]},
	{"id":"gift","title":"Kindness of Strangers","weight":1,
		"text":"A settler family shares their table as you pass.",
		"choices":[
			{"text":"Accept gratefully","effects":{"res":{"food":12,"water":8},"morale":6,
				"log":"A warm meal and full casks. The world feels less cruel."}},
			{"text":"Pay them for it (4 coin)","effects":{"res":{"money":-4,"food":12,"water":8},"morale":3,
				"log":"You insist on paying. They wave you off with extra bread."}},
		]},
	{"id":"quarrel","title":"A Quarrel","weight":2,
		"text":"Two of the party come to blows over the last of the rations.",
		"choices":[
			{"text":"Side with one","effects":{"morale":-6,"bond":{"who":"random","amount":-10},"log":"The wagon splits into camps."}},
			{"text":"Ration fairly and mediate","effects":{"res":{"food":-3},"morale":4,"bond":{"who":"all","amount":3},
				"log":"You divide it even. Tempers cool."}},
		]},
	{"id":"cliff_road","title":"The Cliff Road","weight":2,
		"text":"The trail narrows to a ledge above a long drop.",
		"choices":[
			{"text":"Lead the team on foot","chance":0.75,
				"on_success":{"res":{"food":-2},"log":"Inch by inch, you make it across."},
				"on_fail":{"res":{"parts":-3,"clothing":-2},"health":{"amount":-18,"target":"random"},
					"inflict":{"who":"random","cond":"injury"},
					"log":"A wheel slips. You save the wagon but not unscathed."}},
			{"text":"Detour the long way","effects":{"res":{"food":-8,"water":-6,"feed":-4},"morale":-2,
				"log":"Safe, but it costs you days."}},
		]},
	{"id":"wolves","title":"Wolves at the Edge","weight":2,
		"text":"Eyes glint at the treeline. The pack is hungry.",
		"choices":[
			{"text":"Drive them off (ammo)","effects":{"res":{"ammo":-2},"log":"A few shots and they melt away."}},
			{"text":"Build up the fire (food)","effects":{"res":{"food":-4},"morale":-1,
				"log":"You burn through stores to keep the dark back."}},
		]},
	{"id":"clear_run","title":"Open Country","weight":3,
		"text":"For once the land is kind: flat, green, and quiet.",
		"choices":[
			{"text":"Make good miles","effects":{"morale":3,"log":"An easy day. Spirits lift."}},
			{"text":"Rest the animals and forage","effects":{"res":{"food":8,"feed":4},"morale":2,
				"log":"You gather wild greens and let the team graze."}},
		]},
	# --- expansion set ---
	{"id":"scavenge","title":"Scavenge the Hollow","weight":2,
		"text":"A wooded hollow might hide forage and game.",
		"choices":[
			{"text":"Forage carefully (mini-game)","minigame":"hunt","effects":{"res":{"ammo":-1}}},
			{"text":"Skip it","effects":{"log":"Not worth the daylight."}},
		]},
	{"id":"frost_night","title":"A Killing Frost","weight":2,
		"text":"The temperature plunges after dark.",
		"choices":[
			{"text":"Break out extra clothing","effects":{"res":{"clothing":-3},"log":"Bundled tight, you weather it."}},
			{"text":"Huddle and ration heat","effects":{"inflict":{"who":"random","cond":"frostbite"},"morale":-2,
				"log":"By dawn someone can't feel their fingers."}},
		]},
	{"id":"trade_post","title":"Greywell Post","weight":2,
		"text":"A proper trading post — a chance to rebalance the wagon.",
		"choices":[
			{"text":"Buy food x10 (8 coin)","effects":{"res":{"money":-8,"food":10},"log":"Stocked the larder."}},
			{"text":"Buy feed x10 (8 coin)","effects":{"res":{"money":-8,"feed":10},"log":"The animals will thank you."}},
			{"text":"Sell clothing for coin","effects":{"res":{"money":8,"clothing":-3},"log":"Lighter, richer, colder."}},
		]},
	{"id":"deserter","title":"One Wants to Turn Back","weight":2,
		"text":"A member loses heart and talks of going home.",
		"choices":[
			{"text":"Talk them down","chance":0.7,
				"on_success":{"morale":4,"bond":{"who":"random","amount":8},"log":"They stay. The bond holds."},
				"on_fail":{"morale":-6,"bond":{"who":"random","amount":-8},"log":"Words fail. The mood sours."}},
			{"text":"Let them stew","effects":{"morale":-3,"log":"You say nothing. The silence stretches."}},
		]},
	{"id":"mud","title":"Mired Wheels","weight":2,
		"text":"Spring melt turns the trail to a sea of mud.",
		"choices":[
			{"text":"Dig and push (hard labor)","effects":{"res":{"food":-3},"health":{"amount":-4,"target":"all"},
				"log":"Filthy, exhausting work — but you're free."}},
			{"text":"Wait for it to dry","effects":{"res":{"food":-5,"water":-3,"feed":-3},"morale":-2,
				"log":"Days lost to the mud."}},
		]},
	{"id":"berries","title":"Wild Berries","weight":1,
		"text":"A thicket heavy with unfamiliar berries.",
		"choices":[
			{"text":"Eat your fill","chance":0.6,
				"on_success":{"res":{"food":8},"morale":2,"log":"Sweet and safe. A small mercy."},
				"on_fail":{"inflict":{"who":"all","cond":"campsick"},"log":"They turn out to be the wrong kind."}},
			{"text":"Leave them","effects":{"log":"Better hungry than poisoned."}},
		]},
	{"id":"avalanche","title":"Loaded Slope","weight":2,
		"text":"Fresh snow hangs heavy above the pass.",
		"choices":[
			{"text":"Cross fast and quiet","chance":0.6,
				"on_success":{"log":"You slip across before the slope lets go."},
				"on_fail":{"res":{"parts":-3,"feed":-4},"health":{"amount":-16,"target":"random"},
					"inflict":{"who":"random","cond":"injury"},"log":"A slide catches the wagon's tail."}},
			{"text":"Wait for it to settle","effects":{"res":{"food":-6,"feed":-4,"clothing":-2},"morale":-2,
				"log":"A cold, anxious wait."}},
		]},
	{"id":"old_friend","title":"A Familiar Face","weight":1,
		"text":"Someone from the leader's past crosses the trail.",
		"choices":[
			{"text":"Share a fire and stories","effects":{"morale":6,"bond":{"who":"all","amount":5},"res":{"food":-3},
				"log":"Old ties, rekindled. The party feels lighter."}},
			{"text":"Keep it brief","effects":{"morale":1,"log":"A nod, a word, and onward."}},
		]},
	{"id":"dry_well","title":"The Dry Well","weight":2,
		"text":"The mapped waterhole is cracked mud.",
		"choices":[
			{"text":"Dig for seep water","chance":0.5,
				"on_success":{"res":{"water":10},"morale":-1,"log":"You find muddy water — enough."},
				"on_fail":{"res":{"water":-4},"morale":-3,"log":"Nothing but dust and blistered hands."}},
			{"text":"Push to the next source","effects":{"res":{"water":-8,"feed":-3},"log":"A long dry stretch."}},
		]},
	{"id":"toll","title":"The Tollkeeper","weight":1,
		"text":"An armed party controls the only bridge.",
		"choices":[
			{"text":"Pay the toll (8 coin)","effects":{"res":{"money":-8},"log":"Highway robbery, but you cross."}},
			{"text":"Refuse and detour","effects":{"res":{"food":-6,"feed":-4,"water":-4},"morale":-2,
				"log":"The long way around, on principle."}},
			{"text":"Intimidate them","chance":0.4,
				"on_success":{"log":"You stare them down. They wave you through."},
				"on_fail":{"res":{"money":-10,"food":-6},"morale":-3,"log":"It goes badly. They take more than coin."}},
		]},
	{"id":"medicine_cache","title":"A Doctor's Cache","weight":1,
		"text":"An old field-kit, abandoned but intact.",
		"choices":[
			{"text":"Take it","effects":{"res":{"medicine":4},"morale":2,"log":"A windfall of medicine."}},
		]},
	{"id":"exhausted","title":"Worn to the Bone","weight":2,
		"text":"The pace has caught up with the party. Heads droop.",
		"choices":[
			{"text":"Force a full rest day","effects":{"res":{"food":-4,"water":-4},"morale":6,
				"cure":{"who":"all","cond":"exhaustion"},"log":"A day's rest. The party comes back to life."}},
			{"text":"One more hard push","effects":{"inflict":{"who":"random","cond":"exhaustion"},"morale":-3,
				"log":"You squeeze out more miles, but at a cost."}},
		]},
	{"id":"river_swell","title":"A Risen River","weight":2,
		"text":"Heavy rain upstream has swollen the crossing.",
		"choices":[
			{"text":"Float the wagon across","chance":0.55,
				"on_success":{"res":{"food":-3},"log":"It floats true. You make the far bank."},
				"on_fail":{"res":{"food":-10,"clothing":-3,"parts":-2},"log":"The current nearly takes it all."}},
			{"text":"Wait it out","effects":{"res":{"food":-5,"feed":-3},"morale":-2,"log":"You camp and wait for the water to fall."}},
		]},
	{"id":"horse_trade","title":"Fresh Animals","weight":1,
		"text":"A rancher offers to swap your tired team for fresh stock.",
		"choices":[
			{"text":"Trade (10 coin)","effects":{"res":{"money":-10,"feed":4},"morale":3,"log":"Fresh legs under the wagon."}},
			{"text":"Decline","effects":{"log":"Your team has more in them yet."}},
		]},
	{"id":"funeral","title":"A Roadside Grave","weight":1,
		"text":"You pass a fresh grave marked only with a coat.",
		"choices":[
			{"text":"Pay your respects","effects":{"morale":-1,"bond":{"who":"all","amount":3},
				"log":"A quiet moment binds the party closer."}},
			{"text":"Hurry past","effects":{"morale":-2,"log":"No time for the dead."}},
		]},
	{"id":"fog_bank","title":"Into the Fog","weight":2,
		"text":"A thick fog swallows the trail.",
		"choices":[
			{"text":"Wait for it to lift","effects":{"res":{"food":-3,"feed":-2},"log":"You lose half a day to grey nothing."}},
			{"text":"Feel your way forward","chance":0.6,
				"on_success":{"log":"You keep the line and press on."},
				"on_fail":{"res":{"parts":-2},"morale":-2,"log":"You drift off-trail and clip a boulder."}},
		]},
	{"id":"stowaway","title":"A Hungry Child","weight":1,
		"text":"A child has been following the wagon, half-starved.",
		"choices":[
			{"text":"Feed and shelter them","effects":{"res":{"food":-6},"morale":8,"bond":{"who":"all","amount":6},
				"log":"The party rallies around the child. Spirits soar."}},
			{"text":"You can't spare it","effects":{"morale":-6,"log":"You drive on. No one speaks for miles."}},
		]},
]

# --- endings (relationship-aware) ---
func get_ending(survivors: int, avg_morale: float) -> Dictionary:
	if survivors <= 0:
		return {"id":"fail","title":"The Reach Claims All",
			"text":"The wagon rolls to a stop with no one left to drive it. The frontier keeps its toll. Somewhere ahead, the green valleys go unseen.",
			"good":false}
	if survivors >= 4 and avg_morale >= 55:
		return {"id":"triumph","title":"Into the Green Valleys",
			"text":"You crest the final pass together and the valley opens below — rivers, timber, room to breathe. You arrived whole, and you arrived as one.",
			"good":true}
	return {"id":"bittersweet","title":"What the Road Took",
		"text":"You reach the valley thinner, quieter, fewer. You made it — but the country exacted its price, and you'll carry the empty seats at the fire for a long time.",
		"good":true}
