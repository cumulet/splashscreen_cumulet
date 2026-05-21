@tool
extends EditorPlugin

const SPLASH_SCENE := "res://addons/splashscreen_easier/splash_screen.tscn"
const NEXT_SCENE_SETTING := "addons/splashscreen_cumulet/next_scene"

var dock: VBoxContainer
var label: Label
var pick_button: Button
var clear_button: Button
var dialog: EditorFileDialog


func _enable_plugin() -> void:
	print("[splashscreen_cumulet] _enable_plugin")
	if ProjectSettings.get_setting("application/run/main_scene", "") != SPLASH_SCENE:
		ProjectSettings.set_setting("application/run/main_scene", SPLASH_SCENE)
	_ensure_next_scene_setting()
	ProjectSettings.save()


func _enter_tree() -> void:
	print("[splashscreen_cumulet] _enter_tree — building dock")
	_ensure_next_scene_setting()

	dock = VBoxContainer.new()
	dock.name = "Splashscreen"
	dock.add_theme_constant_override("separation", 8)

	var title := Label.new()
	title.text = "splashscreen cumulet"
	title.add_theme_font_size_override("font_size", 14)
	dock.add_child(title)

	label = Label.new()
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dock.add_child(label)

	pick_button = Button.new()
	pick_button.text = "pick next scene"
	pick_button.pressed.connect(_open_picker)
	dock.add_child(pick_button)

	clear_button = Button.new()
	clear_button.text = "clear"
	clear_button.pressed.connect(_clear_next_scene)
	dock.add_child(clear_button)

	add_control_to_dock(DOCK_SLOT_LEFT_BR, dock)

	dialog = EditorFileDialog.new()
	dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE
	dialog.access = EditorFileDialog.ACCESS_RESOURCES
	dialog.add_filter("*.tscn", "Scene")
	dialog.add_filter("*.scn", "Binary Scene")
	dialog.title = "select scene to load after the splash"
	dialog.file_selected.connect(_on_scene_selected)
	EditorInterface.get_base_control().add_child(dialog)

	_refresh_label()
	print("[splashscreen_cumulet] dock ready — look at the left-bottom dock tabs for 'Splashscreen'")


func _exit_tree() -> void:
	print("[splashscreen_cumulet] _exit_tree")
	if dock:
		remove_control_from_docks(dock)
		dock.queue_free()
		dock = null
	if dialog:
		dialog.queue_free()
		dialog = null


# ---- internals ----

func _ensure_next_scene_setting() -> void:
	if not ProjectSettings.has_setting(NEXT_SCENE_SETTING):
		ProjectSettings.set_setting(NEXT_SCENE_SETTING, "")
		ProjectSettings.add_property_info({
			"name": NEXT_SCENE_SETTING,
			"type": TYPE_STRING,
			"hint": PROPERTY_HINT_FILE,
			"hint_string": "*.tscn,*.scn",
		})
		ProjectSettings.set_initial_value(NEXT_SCENE_SETTING, "")
		ProjectSettings.save()


func _refresh_label() -> void:
	if not is_instance_valid(label):
		return
	var current: String = ProjectSettings.get_setting(NEXT_SCENE_SETTING, "")
	if current.is_empty():
		label.text = "no next scene picked yet"
	else:
		label.text = "next: " + current


func _open_picker() -> void:
	var current: String = ProjectSettings.get_setting(NEXT_SCENE_SETTING, "")
	if not current.is_empty():
		dialog.current_path = current
	dialog.popup_centered_ratio(0.7)


func _on_scene_selected(path: String) -> void:
	ProjectSettings.set_setting(NEXT_SCENE_SETTING, path)
	ProjectSettings.save()
	print("[splashscreen_cumulet] next scene -> ", path)
	_refresh_label()


func _clear_next_scene() -> void:
	ProjectSettings.set_setting(NEXT_SCENE_SETTING, "")
	ProjectSettings.save()
	print("[splashscreen_cumulet] next scene cleared")
	_refresh_label()
