extends RefCounted
class_name Settings

# Persists to user:// (on Linux this is ~/.local/share/godot/app_userdata/<project>/)
const SAVE_PATH := "user://settings.json"

var colors := {
	"background": Color(0.08, 0.08, 0.1),
	"text": Color(0.92, 0.92, 0.92),
	"highlight": Color(0.25, 0.55, 0.95),
	"accent": Color(0.95, 0.65, 0.15)
}

# action name -> a small JSON-friendly dict describing the bound key/button
var keybinds := {
	"ui_up": {"type": "key", "keycode": KEY_UP},
	"ui_down": {"type": "key", "keycode": KEY_DOWN},
	"ui_left": {"type": "key", "keycode": KEY_LEFT},
	"ui_right": {"type": "key", "keycode": KEY_RIGHT},
	"ui_accept": {"type": "key", "keycode": KEY_ENTER},
	"toggle_mode": {"type": "key", "keycode": KEY_F11},
	"quit_app": {"type": "key", "keycode": KEY_ESCAPE},
	"open_settings": {"type": "key", "keycode": KEY_O}
}


func load_settings() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
		var parsed = JSON.parse_string(f.get_as_text())
		f.close()
		if parsed != null:
			if parsed.has("colors"):
				for key in parsed["colors"]:
					colors[key] = Color(parsed["colors"][key])
			if parsed.has("keybinds"):
				for key in parsed["keybinds"]:
					keybinds[key] = parsed["keybinds"][key]
	apply_keybinds()


func save_settings() -> void:
	var color_data := {}
	for key in colors:
		color_data[key] = colors[key].to_html()
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	f.store_string(JSON.stringify({"colors": color_data, "keybinds": keybinds}, "\t"))
	f.close()


func apply_keybinds() -> void:
	for action in keybinds:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		InputMap.action_erase_events(action)
		var event := _build_event(keybinds[action])
		if event:
			InputMap.action_add_event(action, event)


func set_keybind(action: String, event: InputEvent) -> void:
	var described := _describe_event(event)
	if described.is_empty():
		return
	keybinds[action] = described
	apply_keybinds()


func describe_bind(action: String) -> String:
	var bind: Dictionary = keybinds.get(action, {})
	if bind.get("type") == "key":
		return OS.get_keycode_string(bind.get("keycode", 0))
	elif bind.get("type") == "joy_button":
		return "Joypad button %d" % bind.get("button", 0)
	return "Unbound"


static func _build_event(bind: Dictionary) -> InputEvent:
	if bind.get("type") == "key":
		var e := InputEventKey.new()
		e.physical_keycode = bind.get("keycode", 0)
		return e
	elif bind.get("type") == "joy_button":
		var e := InputEventJoypadButton.new()
		e.button_index = bind.get("button", 0)
		return e
	return null


static func _describe_event(event: InputEvent) -> Dictionary:
	if event is InputEventKey:
		return {"type": "key", "keycode": event.physical_keycode}
	elif event is InputEventJoypadButton:
		return {"type": "joy_button", "button": event.button_index}
	return {}
