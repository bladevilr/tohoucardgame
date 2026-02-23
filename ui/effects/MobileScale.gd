extends Node

## MobileScale — runtime DPI scaling for all platforms.
## Detects physical screen size at startup and sets content_scale_factor
## so UI remains readable everywhere. Even desktop gets a slight boost.

const MOBILE_WIDTH_THRESHOLD := 768.0
const TABLET_WIDTH_THRESHOLD := 1200.0
const DESKTOP_WIDTH_THRESHOLD := 1800.0

const MOBILE_SCALE := 2.2
const TABLET_SCALE := 1.6
const SMALL_DESKTOP_SCALE := 1.3
const DESKTOP_SCALE := 1.15

func _ready() -> void:
	call_deferred("_apply_scale")

func _apply_scale() -> void:
	var factor := _calculate_scale_factor()
	get_window().content_scale_factor = factor
	print("[MobileScale] screen_width=", _get_physical_width(), " content_scale_factor=", factor)

func _calculate_scale_factor() -> float:
	var screen_width := _get_physical_width()
	if screen_width <= 0.0:
		screen_width = float(get_viewport().get_visible_rect().size.x)
	if screen_width < MOBILE_WIDTH_THRESHOLD:
		return MOBILE_SCALE
	elif screen_width < TABLET_WIDTH_THRESHOLD:
		return TABLET_SCALE
	elif screen_width < DESKTOP_WIDTH_THRESHOLD:
		return SMALL_DESKTOP_SCALE
	else:
		return DESKTOP_SCALE

func _get_physical_width() -> float:
	if OS.has_feature("web"):
		return _get_web_screen_width()
	var dpi := DisplayServer.screen_get_dpi()
	if dpi > 0:
		var pixel_width := float(DisplayServer.screen_get_size().x)
		var dp_width := pixel_width / (float(dpi) / 160.0)
		return dp_width
	return float(DisplayServer.screen_get_size().x)

func _get_web_screen_width() -> float:
	if ClassDB.class_exists("JavaScriptBridge"):
		var result = JavaScriptBridge.eval("window.innerWidth", true)
		if result is float or result is int:
			return float(result)
	return float(get_viewport().get_visible_rect().size.x)
