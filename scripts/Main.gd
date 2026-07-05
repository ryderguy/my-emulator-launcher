extends Control

@onready var background: ColorRect = $Background
@onready var system_list: ItemList = $Margin/VBox/HBox/SystemList
@onready var console_icon: TextureRect = $Margin/VBox/HBox/RightPanel/ConsoleIcon
@onready var game_list: ItemList = $Margin/VBox/HBox/RightPanel/GameList
@onready var status_label: Label = $Margin/VBox/StatusLabel

var library := Library.new()
var settings := Settings.new()
var settings_menu: Control = null
var icon_downloader: IconDownloader
var big_screen_mode := true  # default, as requested

const SettingsMenuScript := preload("res://scripts/SettingsMenu.gd")


func _ready() -> void:
	settings.load_settings()
	library.load_config()
	_populate_systems()
	_apply_mode(big_screen_mode)

	icon_downloader = IconDownloader.new()
	add_child(icon_downloader)
	icon_downloader.progress.connect(func(text): status_label.text = text)
	icon_downloader.finished.connect(func(): status_label.text = "Icon download finished.")

	system_list.item_selected.connect(_on_system_selected)
	game_list.item_activated.connect(_on_game_activated)

	# Let D-pad left/right (or arrow keys) move focus between the two lists.
	system_list.focus_neighbor_right = game_list.get_path()
	game_list.focus_neighbor_left = system_list.get_path()

	system_list.grab_focus()
	if system_list.item_count > 0:
		system_list.select(0)
		_on_system_selected(0)


func _unhandled_input(event: InputEvent) -> void:
	if settings_menu != null:
		return  # the settings overlay handles its own input while open

	if event.is_action_pressed("open_settings"):
		_open_settings()
	elif event.is_action_pressed("toggle_mode"):
		big_screen_mode = not big_screen_mode
		_apply_mode(big_screen_mode)
	elif event.is_action_pressed("quit_app"):
		get_tree().quit()


func _open_settings() -> void:
	settings_menu = SettingsMenuScript.new()
	add_child(settings_menu)
	settings_menu.setup(settings, self)
	settings_menu.closed.connect(_on_settings_closed)


func _on_settings_closed() -> void:
	settings_menu = null
	apply_color_theme()
	if system_list.item_count > 0:
		system_list.grab_focus()


func _populate_systems() -> void:
	system_list.clear()
	for name in library.get_system_names():
		system_list.add_item(name)


func _on_system_selected(index: int) -> void:
	game_list.clear()
	var system := library.get_system(index)
	var games := library.get_games(system)
	for g in games:
		game_list.add_item(g["display_name"])
	game_list.set_meta("games", games)
	game_list.set_meta("system", system)
	status_label.text = "%d game(s) found for %s" % [games.size(), system["name"]]
	_update_console_icon(system)


func _update_console_icon(system: Dictionary) -> void:
	var icon_path: String = system.get("icon", "")
	if icon_path != "" and ResourceLoader.exists(icon_path):
		console_icon.texture = load(icon_path)
	else:
		console_icon.texture = null


func start_icon_download() -> void:
	icon_downloader.download_all(library.systems)


func _on_game_activated(index: int) -> void:
	var games: Array = game_list.get_meta("games")
	var system: Dictionary = game_list.get_meta("system")
	var rom_path: String = games[index]["full_path"]
	status_label.text = "Launching %s..." % games[index]["display_name"]
	Launcher.launch_game(system, rom_path)


func _apply_mode(is_big_screen: bool) -> void:
	if is_big_screen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	apply_color_theme()
	status_label.text = "Big-screen mode  (F11 = desktop, O = settings, Esc = quit)" if is_big_screen \
		else "Desktop mode  (F11 = big-screen, O = settings, Esc = quit)"


# Called by SettingsMenu whenever a color changes, and after mode toggles.
func apply_color_theme() -> void:
	var font_size := 28 if big_screen_mode else 16
	background.color = settings.colors["background"]
	theme = _build_theme(font_size)


func _build_theme(font_size: int) -> Theme:
	var t := Theme.new()
	t.set_font_size("font_size", "Label", font_size)
	t.set_font_size("font_size", "ItemList", font_size)
	t.set_color("font_color", "Label", settings.colors["text"])
	t.set_color("font_color", "ItemList", settings.colors["text"])
	t.set_color("font_selected_color", "ItemList", settings.colors["text"])

	var selected_box := StyleBoxFlat.new()
	selected_box.bg_color = settings.colors["highlight"]
	selected_box.corner_radius_top_left = 4
	selected_box.corner_radius_top_right = 4
	selected_box.corner_radius_bottom_left = 4
	selected_box.corner_radius_bottom_right = 4
	t.set_stylebox("selected", "ItemList", selected_box)
	t.set_stylebox("selected_focus", "ItemList", selected_box)

	return t
