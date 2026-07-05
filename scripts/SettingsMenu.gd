extends Control

signal closed

var settings: Settings
var main_ref: Control
var listening_action: String = ""

const ACTIONS := ["ui_up", "ui_down", "ui_left", "ui_right", "ui_accept", "toggle_mode", "quit_app", "open_settings"]
const COLOR_KEYS := ["background", "text", "highlight", "accent"]

var bind_list: VBoxContainer
var status_label: Label


func setup(s: Settings, main: Control) -> void:
	settings = s
	main_ref = main
	_build_ui()


func _build_ui() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP

	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.75)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(dim)

	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.custom_minimum_size = Vector2(560, 480)
	panel.position = Vector2(-280, -240)
	add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_bottom", 24)
	panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	margin.add_child(vbox)

	var title := Label.new()
	title.text = "Settings  (Esc or O to close)"
	title.add_theme_font_size_override("font_size", 22)
	vbox.add_child(title)

	vbox.add_child(HSeparator.new())

	var colors_title := Label.new()
	colors_title.text = "Colors"
	vbox.add_child(colors_title)

	for key in COLOR_KEYS:
		vbox.add_child(_make_color_row(key))

	vbox.add_child(HSeparator.new())

	var binds_title := Label.new()
	binds_title.text = "Controls  (click a button, then press a key or gamepad button)"
	vbox.add_child(binds_title)

	bind_list = VBoxContainer.new()
	vbox.add_child(bind_list)
	_rebuild_bind_rows()

	vbox.add_child(HSeparator.new())

	var button_row := HBoxContainer.new()
	button_row.add_theme_constant_override("separation", 12)

	var save_btn := Button.new()
	save_btn.text = "Save"
	save_btn.pressed.connect(_on_save_pressed)
	button_row.add_child(save_btn)

	var reset_btn := Button.new()
	reset_btn.text = "Reset to Defaults"
	reset_btn.pressed.connect(_on_reset_pressed)
	button_row.add_child(reset_btn)

	var close_btn := Button.new()
	close_btn.text = "Close"
	close_btn.pressed.connect(_close)
	button_row.add_child(close_btn)

	vbox.add_child(button_row)

	var download_btn := Button.new()
	download_btn.text = "Download Missing Icons (uses icon_url in systems.json)"
	download_btn.pressed.connect(_on_download_pressed)
	vbox.add_child(download_btn)

	status_label = Label.new()
	status_label.text = ""
	vbox.add_child(status_label)


func _make_color_row(key: String) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)

	var label := Label.new()
	label.text = key.capitalize()
	label.custom_minimum_size.x = 140
	row.add_child(label)

	var picker := ColorPickerButton.new()
	picker.color = settings.colors[key]
	picker.custom_minimum_size = Vector2(80, 28)
	picker.color_changed.connect(func(c): _on_color_changed(key, c))
	row.add_child(picker)

	return row


func _on_color_changed(key: String, c: Color) -> void:
	settings.colors[key] = c
	if main_ref.has_method("apply_color_theme"):
		main_ref.apply_color_theme()


func _rebuild_bind_rows() -> void:
	for child in bind_list.get_children():
		child.queue_free()
	for action in ACTIONS:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 12)

		var label := Label.new()
		label.text = action
		label.custom_minimum_size.x = 140
		row.add_child(label)

		var btn := Button.new()
		btn.text = settings.describe_bind(action)
		btn.custom_minimum_size.x = 200
		btn.pressed.connect(func(): _start_listening(action, btn))
		row.add_child(btn)

		bind_list.add_child(row)


func _start_listening(action: String, btn: Button) -> void:
	listening_action = action
	btn.text = "Press a key or button..."


func _unhandled_input(event: InputEvent) -> void:
	if listening_action != "":
		if event is InputEventKey and event.pressed and not event.echo:
			settings.set_keybind(listening_action, event)
			listening_action = ""
			_rebuild_bind_rows()
			get_viewport().set_input_as_handled()
		elif event is InputEventJoypadButton and event.pressed:
			settings.set_keybind(listening_action, event)
			listening_action = ""
			_rebuild_bind_rows()
			get_viewport().set_input_as_handled()
		return

	if event.is_action_pressed("quit_app") or event.is_action_pressed("open_settings"):
		_close()
		get_viewport().set_input_as_handled()


func _on_save_pressed() -> void:
	settings.save_settings()
	status_label.text = "Saved."


func _on_download_pressed() -> void:
	if main_ref.has_method("start_icon_download"):
		main_ref.start_icon_download()
		status_label.text = "Downloading icons... check the status bar behind this menu."


func _on_reset_pressed() -> void:
	settings.colors = Settings.new().colors
	settings.keybinds = Settings.new().keybinds
	settings.apply_keybinds()
	if main_ref.has_method("apply_color_theme"):
		main_ref.apply_color_theme()
	_build_ui_refresh()
	status_label.text = "Reset (not yet saved — click Save to keep it)."


func _build_ui_refresh() -> void:
	for child in get_children():
		child.queue_free()
	_build_ui()


func _close() -> void:
	closed.emit()
	queue_free()
