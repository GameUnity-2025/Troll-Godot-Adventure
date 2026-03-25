extends Node2D

var _interstitial_ad : InterstitialAd
var _full_screen_content_callback := FullScreenContentCallback.new()
var _mobile_ads_initialized := false
var _is_loading := false

func _ready() -> void:
	#The initializate needs to be done only once, ideally at app launch.
	
	_full_screen_content_callback.on_ad_clicked = func() -> void:
		print("on_ad_clicked")
	_full_screen_content_callback.on_ad_dismissed_full_screen_content = func() -> void:
		print("on_ad_dismissed_full_screen_content")
	_full_screen_content_callback.on_ad_failed_to_show_full_screen_content = func(_ad_error : AdError) -> void:
		print("on_ad_failed_to_show_full_screen_content")
	_full_screen_content_callback.on_ad_impression = func() -> void:
		print("on_ad_impression")
	_full_screen_content_callback.on_ad_showed_full_screen_content = func() -> void:
		print("on_ad_showed_full_screen_content")

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
	call_deferred("_deferred_load_interstitial")

func _deferred_load_interstitial() -> void:

	#free memory
	if _interstitial_ad:
		#always call this method on all AdFormats to free memory on Android/iOS
		_interstitial_ad.destroy()
		_interstitial_ad = null

	var unit_id : String
	if OS.get_name() == "iOS":
		unit_id = "ca-app-pub-3940256099942544/4411468910"
	else:
		unit_id = "ca-app-pub-3940256099942544/1033173712"

	var interstitial_ad_load_callback := InterstitialAdLoadCallback.new()
	interstitial_ad_load_callback.on_ad_failed_to_load = func(adError : LoadAdError) -> void:
		_is_loading = false
		print(adError.message)

	interstitial_ad_load_callback.on_ad_loaded = func(interstitial_ad : InterstitialAd) -> void:
		_is_loading = false
		print("interstitial ad loaded" + str(interstitial_ad._uid))
		_interstitial_ad = interstitial_ad
		_interstitial_ad.full_screen_content_callback = _full_screen_content_callback
	InterstitialAdLoader.new().load(unit_id, AdRequest.new(), interstitial_ad_load_callback)
	
func _on_show_pressed():
	if _interstitial_ad:
		call_deferred("_deferred_show_interstitial")

func _deferred_show_interstitial() -> void:
	if _interstitial_ad:
		_interstitial_ad.show()

func is_loaded() -> bool:
	return _interstitial_ad != null

func _destroy():
	if _interstitial_ad:
		_interstitial_ad.destroy()
		_interstitial_ad = null
