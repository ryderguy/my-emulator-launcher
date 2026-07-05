extends RefCounted
class_name Launcher

# Launches a Flatpak emulator with the given ROM.
# Equivalent to running, e.g.:
#   flatpak run org.libretro.RetroArch -L /path/to/core.so /path/to/rom.nes

static func launch_game(system: Dictionary, rom_path: String) -> int:
	var flatpak_id: String = system.get("flatpak_id", "")
	if flatpak_id == "":
		push_error("No flatpak_id set for system: %s" % system.get("name", "?"))
		return -1

	var template_args: Array = system.get("launch_args", [])
	var final_args: Array = ["run", flatpak_id]

	for arg in template_args:
		var s: String = str(arg)
		s = s.replace("{rom}", rom_path)
		s = _expand_home(s)
		final_args.append(s)

	print("Launching: flatpak ", " ".join(final_args))

	# create_process runs it detached, so the launcher UI stays responsive
	# and doesn't hang waiting for the emulator to close.
	var pid := OS.create_process("flatpak", final_args)
	if pid == -1:
		push_error("Failed to launch flatpak app: %s" % flatpak_id)
	return pid


static func _expand_home(path: String) -> String:
	if path.begins_with("~"):
		var home := OS.get_environment("HOME")
		return path.replace("~", home)
	return path
