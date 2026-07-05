extends RefCounted
class_name Library

# Loads systems.json and scans each system's rom_dir for matching files.

var systems: Array = []

func load_config(path: String = "res://systems.json") -> void:
	systems.clear()
	if not FileAccess.file_exists(path):
		push_error("systems.json not found at %s" % path)
		return

	var f := FileAccess.open(path, FileAccess.READ)
	var text := f.get_as_text()
	f.close()

	var parsed = JSON.parse_string(text)
	if parsed == null or not parsed.has("systems"):
		push_error("systems.json is malformed")
		return

	systems = parsed["systems"]


func get_system_names() -> Array:
	var names := []
	for s in systems:
		names.append(s["name"])
	return names


func get_system(index: int) -> Dictionary:
	return systems[index]


# Returns an array of {display_name, full_path} for a system's rom_dir.
func get_games(system: Dictionary) -> Array:
	var games := []
	var dir_path: String = _expand_home(system.get("rom_dir", ""))
	var extensions: Array = system.get("extensions", [])

	var dir := DirAccess.open(dir_path)
	if dir == null:
		push_warning("Could not open rom_dir: %s" % dir_path)
		return games

	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir():
			var ext := file_name.get_extension().to_lower()
			if extensions.has(ext):
				games.append({
					"display_name": file_name.get_basename(),
					"full_path": dir_path.path_join(file_name)
				})
		file_name = dir.get_next()
	dir.list_dir_end()

	games.sort_custom(func(a, b): return a["display_name"] < b["display_name"])
	return games


static func _expand_home(path: String) -> String:
	if path.begins_with("~"):
		var home := OS.get_environment("HOME")
		return path.replace("~", home)
	return path
