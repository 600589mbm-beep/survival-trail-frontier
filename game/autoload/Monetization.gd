extends Node
## Monetization — feature-flagged stub. NO real SDK yet (Month-6 work).
## Model: free download · optional rewarded ads · $4.99 one-time Remove Ads ·
## cosmetic skins. NO pay-to-win supplies — by design (see GAME_DESIGN_BRIEF).
##
## Swap _do_purchase / _serve_rewarded for the real store/ads SDK at launch;
## the rest of the game only talks to this interface.

signal ads_removed_changed(removed)
signal rewarded_granted

const PREFS_PATH := "user://prefs.json"
const REMOVE_ADS_SKU := "remove_ads"
const REMOVE_ADS_PRICE := "$4.99"

# Master switch: ads are OFF in this prototype build (no SDK). Flip on at integration.
const ADS_ENABLED := false

var _prefs := {"ads_removed": false, "owned_skins": ["default"], "active_skin": "default"}

func _ready() -> void:
	_load_prefs()

func is_ads_removed() -> bool:
	return bool(_prefs.ads_removed)

func should_show_ads() -> bool:
	return ADS_ENABLED and not is_ads_removed()

# Returns true on success. Real build: route to StoreKit / Play Billing.
func purchase_remove_ads() -> bool:
	if is_ads_removed():
		return true
	_prefs.ads_removed = true
	_save_prefs()
	Analytics.track("iap_purchase", {"sku": REMOVE_ADS_SKU})
	emit_signal("ads_removed_changed", true)
	return true

# Rewarded ad. Real build: load+show ad, grant on completion callback.
# Here it grants immediately so the reward flow is testable.
func show_rewarded_ad(reward_id: String) -> void:
	if not should_show_ads():
		# Ads removed or disabled: grant the reward anyway (player paid / no inventory).
		_grant_reward(reward_id)
		return
	Analytics.track("rewarded_ad_view", {"reward": reward_id})
	_grant_reward(reward_id)

func _grant_reward(reward_id: String) -> void:
	Analytics.track("rewarded_ad_complete", {"reward": reward_id})
	emit_signal("rewarded_granted")

# --- cosmetic skins (visual only) ---
func owned_skins() -> Array:
	return _prefs.owned_skins.duplicate()

func owns_skin(id: String) -> bool:
	return _prefs.owned_skins.has(id)

func unlock_skin(id: String) -> void:
	if not owns_skin(id):
		_prefs.owned_skins.append(id)
		_save_prefs()
		Analytics.track("skin_unlock", {"skin": id})

func active_skin() -> String:
	return String(_prefs.active_skin)

func set_active_skin(id: String) -> void:
	if owns_skin(id):
		_prefs.active_skin = id
		_save_prefs()

func active_skin_tint() -> Color:
	for s in EventDB.SKINS:
		if s.id == active_skin():
			return Color(s.tint)
	return Color("e0a458")

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
		for k in parsed.keys():
			_prefs[k] = parsed[k]

func _save_prefs() -> void:
	var f := FileAccess.open(PREFS_PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(_prefs))
		f.close()
