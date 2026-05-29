extends Node
## EventDB — all static content for the MVP.
## Original world ("The Ashford Reach"). No protected IP, no Oregon Trail names/art/jokes.

# --- 8 resources (money is one of them) ---
const RESOURCES := ["food", "water", "medicine", "ammo", "parts", "clothing", "feed", "money"]

const RESOURCE_LABELS := {
	"food": "Food", "water": "Water", "medicine": "Medicine", "ammo": "Ammo",
	"parts": "Parts", "clothing": "Clothing", "feed": "Feed", "money": "Coin",
}

# Outfitter buy prices (coin per unit). Player starts with money and stocks up.
const OUTFITTER_PRICES := {
	"food": 1, "water": 1, "medicine": 6, "ammo": 2,
	"parts": 8, "clothing": 4, "feed": 1,
}

# Per-day base consumption per living party member (pace multiplies travel-only items).
const DAILY_CONSUMPTION := {
	"food": 2, "water": 2, "feed": 1,
}

# --- 5 selectable leaders (Week-1 MVP: pick 1 to lead the run) ---
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

# 5 party members travel together (leader is index 0, set at run start).
const PARTY_TEMPLATE := [
	{"name": "Sam",  "trait": "Tough"},
	{"name": "Rhea", "trait": "Cook"},
	{"name": "Boone","trait": "Hunter"},
	{"name": "Lila", "trait": "Quiet"},
]

# Single MVP route. Months-3+ adds 4-6 routes.
const ROUTE := {
	"name": "The Ashford Reach",
	"total_miles": 800,
	"intro": "Eight hundred miles of broken country lie between Fort Kestrel and the green valleys of Ashford. Load the wagon. Choose your road. Not everyone arrives.",
}

# --- 20 procedural events ---
# choice schema:
#   {text, effects:{...}}                              deterministic
#   {text, chance:0.6, on_success:{...}, on_fail:{...}} rolled (Scout leader +0.1)
# effects schema:
#   res:{food:-10,...}  morale:int  health:{amount:int,target:"random"|"all"|"worst"}  log:String
const EVENTS := [
	{"id":"river_ford","title":"The Cold River","weight":3,
		"text":"A wide river blocks the trail. The ford looks shallow but the current is fast.",
		"choices":[
			{"text":"Ford it now (risky, free)","chance":0.6,
				"on_success":{"log":"You cross clean. Wheels hold."},
				"on_fail":{"res":{"parts":-2,"food":-8},"health":{"amount":-15,"target":"random"},
					"log":"The wagon lurches. Gear washes downstream and someone is hurt."}},
			{"text":"Pay the ferryman (6 coin)","effects":{"res":{"money":-6},"log":"Slow, dull, safe. You cross dry."}},
			{"text":"Wait two days for low water","effects":{"res":{"food":-4,"water":-4,"feed":-2},"morale":-3,
				"log":"The water drops. The waiting frays nerves."}},
		]},
	{"id":"fever","title":"Trail Fever","weight":3,
		"text":"One of the party wakes shivering and slick with sweat.",
		"choices":[
			{"text":"Dose with medicine","effects":{"res":{"medicine":-2},"health":{"amount":12,"target":"worst"},
				"log":"The fever breaks by morning."}},
			{"text":"Rest a day, no medicine","effects":{"res":{"food":-4,"water":-4},"morale":-2,
				"health":{"amount":4,"target":"worst"},"log":"You lose a day. They mend, slowly."}},
			{"text":"Push on regardless","effects":{"health":{"amount":-14,"target":"worst"},"morale":-4,
				"log":"You make miles, but the sickness deepens."}},
		]},
	{"id":"hunt","title":"Game on the Ridge","weight":3,
		"text":"A herd grazes on the next ridge. Fresh meat — if your shots land.",
		"choices":[
			{"text":"Hunt (uses ammo)","chance":0.65,
				"on_success":{"res":{"ammo":-3,"food":35},"log":"A clean kill. The party eats well."},
				"on_fail":{"res":{"ammo":-3},"morale":-2,"log":"The herd spooks. Ammo wasted."}},
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
			{"text":"Welcome them (morale up, more mouths)","effects":{"morale":6,"res":{"food":-6,"water":-6},
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
				"on_fail":{"res":{"water":15},"health":{"amount":-12,"target":"all"},
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
			{"text":"Treat with medicine","effects":{"res":{"medicine":-2},"health":{"amount":8,"target":"worst"},
				"log":"You draw the venom in time."}},
			{"text":"Cut and pray","chance":0.45,
				"on_success":{"health":{"amount":-4,"target":"worst"},"log":"They pull through, shaken."},
				"on_fail":{"health":{"amount":-22,"target":"worst"},"morale":-5,"log":"A bad night. The leg swells black."}},
		]},
	{"id":"morale_song","title":"A Fire and a Song","weight":2,
		"text":"The party is worn thin. Someone pulls out a fiddle.",
		"choices":[
			{"text":"Rest and sing (costs food)","effects":{"res":{"food":-4},"morale":10,
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
			{"text":"Push through the day","effects":{"res":{"water":-10,"feed":-4},"health":{"amount":-8,"target":"all"},
				"log":"Heatstroke nips at the whole party."}},
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
			{"text":"Side with one","effects":{"morale":-6,"log":"The wagon splits into camps."}},
			{"text":"Ration fairly and mediate","effects":{"res":{"food":-3},"morale":4,
				"log":"You divide it even. Tempers cool."}},
		]},
	{"id":"cliff_road","title":"The Cliff Road","weight":2,
		"text":"The trail narrows to a ledge above a long drop.",
		"choices":[
			{"text":"Lead the team on foot","chance":0.75,
				"on_success":{"res":{"food":-2},"log":"Inch by inch, you make it across."},
				"on_fail":{"res":{"parts":-3,"clothing":-2},"health":{"amount":-18,"target":"random"},
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
]

# --- 3 endings ---
func get_ending(survivors: int, avg_morale: float) -> Dictionary:
	if survivors <= 0:
		return {"id":"fail","title":"The Reach Claims All",
			"text":"The wagon rolls to a stop with no one left to drive it. The Ashford Reach keeps its toll. Somewhere ahead, the green valleys go unseen.",
			"good":false}
	if survivors >= 4 and avg_morale >= 55:
		return {"id":"triumph","title":"Into the Green Valleys",
			"text":"You crest the final pass together and the valley opens below — rivers, timber, room to breathe. You arrived whole, and you arrived as one. The Reach is behind you now.",
			"good":true}
	return {"id":"bittersweet","title":"What the Road Took",
		"text":"You reach Ashford thinner, quieter, fewer. You made it — but the country exacted its price, and you'll carry the empty seats at the fire for a long time.",
		"good":true}
