@tool
extends EditorPlugin

const SPLASH_SCREEN = "res://addons/splashscreen_cumulet/splash_screen.tscn"

func _enable_plugin() -> void:
	if ProjectSettings.get_setting("application/run/main_scene") == SPLASH_SCREEN:
		return
	ProjectSettings.set_setting("application/run/main_scene", SPLASH_SCREEN)
	ProjectSettings.save()
	print("hello")


func _disable_plugin() -> void:
	# Remove autoloads here.
	pass


func _enter_tree() -> void:
	pass


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass
