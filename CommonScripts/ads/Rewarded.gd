extends Node2D

var _rewarded_ad : RewardedAd
var _full_screen_content_callback := FullScreenContentCallback.new()
var on_user_earned_reward_listener := OnUserEarnedRewardListener.new()
var _mobile_ads_initialized := false
var _is_loading := false
var auto_show_when_loaded := false

func _ready() -> void:
	_full_screen_content_callback.on_ad_clicked = func() -> void:
		print("on_ad_clicked")
	_full_screen_content_callback.on_ad_dismissed_full_screen_content = func() -> void:
		print("on_ad_dismissed_full_screen_content")
	_full_screen_content_callback.on_ad_failed_to_show_full_screen_content = func(ad_error : AdError) -> void:
		print("on_ad_failed_to_show_full_screen_content")
	_full_screen_content_callback.on_ad_impression = func() -> void:
		print("on_ad_impression")
	_full_screen_content_callback.on_ad_showed_full_screen_content = func() -> void:
		print("on_ad_showed_full_screen_content")
	on_user_earned_reward_listener.on_user_earned_reward = func(rewarded_item : RewardedItem):
		print("on_user_earned_reward, rewarded_item: rewarded", rewarded_item.amount, rewarded_item.type)

func _ensure_mobile_ads_ready() -> void:
	if _mobile_ads_initialized:
		return

	MobileAds.initialize()
	_mobile_ads_initialized = true
	# Give iOS SDK a short warm-up before first load.
	await get_tree().process_frame
	await get_tree().process_frame

func _on_load_pressed():
	if _is_loading:
		return

	_is_loading = true
	await _ensure_mobile_ads_ready()
	call_deferred("_deferred_load_rewarded")

func _deferred_load_rewarded() -> void:

	#free memory
	if _rewarded_ad:
		#always call this method on all AdFormats to free memory on Android/iOS
		_rewarded_ad.destroy()
		_rewarded_ad = null

	var unit_id : String
	if OS.get_name() == "iOS":
		unit_id = "ca-app-pub-3940256099942544/1712485313"
	else:
		unit_id = "ca-app-pub-3940256099942544/5224354917"

	var rewarded_ad_load_callback := RewardedAdLoadCallback.new()
	rewarded_ad_load_callback.on_ad_failed_to_load = func(adError : LoadAdError) -> void:
		_is_loading = false
		print(adError.message)

	rewarded_ad_load_callback.on_ad_loaded = func(rewarded_ad : RewardedAd) -> void:
		_is_loading = false
		print("rewarded ad loaded" + str(rewarded_ad._uid))
		
		_rewarded_ad = rewarded_ad
		_rewarded_ad.full_screen_content_callback = _full_screen_content_callback
		if auto_show_when_loaded:
			auto_show_when_loaded = false
			_on_show_pressed()

	RewardedAdLoader.new().load(unit_id, AdRequest.new(), rewarded_ad_load_callback)

func _on_show_pressed():
	if _rewarded_ad:
		call_deferred("_deferred_show_rewarded")

func _deferred_show_rewarded() -> void:
	if _rewarded_ad:
		_rewarded_ad.show(on_user_earned_reward_listener)

func is_loaded() -> bool:
	return _rewarded_ad != null

func _destroy():
	if _rewarded_ad:
		_rewarded_ad.destroy()
		_rewarded_ad = null
