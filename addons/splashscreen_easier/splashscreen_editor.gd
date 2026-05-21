@tool
extends EditorPlugin

const SPLASH_SCREEN = "res://addons/splashscreen_cumulet/splash_screen.tscn"
const NEXT_SCENE_SETTING := "addons/splashscreen_cumulet/next_scene"

var button : Button
var dialog: EditorFileDialog

func _enter_tree() -> void:
	if ProjectSettings.get_setting("application/run/main_scene") == SPLASH_SCREEN:
		return
	ProjectSettings.set_setting("application/run/main_scene", SPLASH_SCREEN)
	ProjectSettings.save()
	print("hello")
	
	ensure_settings()
	print("[splashscreen_cumulet] _enter_tree fired")
	button = Button.new()
	button.text = "next scene"
	button.tooltip_text = "pick the scene loaded after the titlescreen"
	button.custom_minimum_size = Vector2(110, 0)
	button.flat = false
	button.pressed.connect(on_button_pressed)
	add_control_to_container(CONTAINER_TOOLBAR, button)
	
	dialog = EditorFileDialog.new()
	dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	dialog.access = FileDialog.ACCESS_RESOURCES
	dialog.add_filter("*.tscn", "Scene")
	dialog.add_filter("*.scn", "Binary Scene")
	dialog.title = "select the scene to load after the title screen"
	dialog.file_selected.connect(on_scene_selected)
	EditorInterface.get_base_control().add_child(dialog)
	pass


func _exit_tree() -> void:
	if button:
		remove_control_from_container(CONTAINER_TOOLBAR, button)
		button.queue_free()
		button = null
	if dialog:
		dialog.queue_free()
		dialog = null
	# Clean-up of the plugin goes here.
	pass
	
func ensure_settings():
	if not ProjectSettings.has_setting(NEXT_SCENE_SETTING):
		ProjectSettings.set_setting(NEXT_SCENE_SETTING, "")
		
		ProjectSettings.add_property_info({
			"name" : NEXT_SCENE_SETTING,
			"type" : TYPE_STRING,
			"hint" : PROPERTY_HINT_FILE,
			"hint_string": "*.tscn, *scn"
		})
		ProjectSettings.set_initial_value(NEXT_SCENE_SETTING, "")
		ProjectSettings.save()

func on_button_pressed():
	var current:String = ProjectSettings.get_setting(NEXT_SCENE_SETTING,"")
	if current != "":
		dialog.current_path = current
	dialog.popup_centered_ratio()
	
func on_scene_selected(path : String):
	ProjectSettings.set_setting(NEXT_SCENE_SETTING, path)
	ProjectSettings.save()
	print("[splashscreen_cumulet] next scene -> ", path)
