extends Control

## TODO: Implement Audio - Let's do the random "cumulet!" things ?

const START_SCREEN_SCENE_PATH: String = "res://main.tscn"
const CUMULET_COLOR := Color("0f34fc")

@export var splash_screen_timer := 2
@export var splash_screen_end_timer := .6

var timer: float = 0.0
var has_audio_played: bool = false

var is_connexion_attempted: bool = false
var is_animation_finished: bool = false

@onready var background_color: ColorRect = $BackgroundColor
@onready var cumulet_logo: TextureRect = $content/CumuletLogo
@onready var cumulet_text: TextureRect = $content/CumuletText
@onready var splash_screen_audio: AudioStreamPlayer = $SplashScreenAudio

signal splashscreen_finish

const NEXT_SCENE_SETTING := "addons/splashscreen_cumulet/next_scene"
const SKIP_SETTING := "addons/splashscreen_cumulet/skip_splash"

func _ready() -> void:
	splashscreen_finish.connect(on_splash_finished)

	var skip: bool = bool(ProjectSettings.get_setting(SKIP_SETTING, false))
	var next: String = str(ProjectSettings.get_setting(NEXT_SCENE_SETTING, ""))
	print("[splashscreen_cumulet] runtime read — skip=", skip, " next='", next, "'")

	# skip the whole splash if the editor toggle is on and a next scene is set
	if skip:
		if not next.is_empty():
			call_deferred("_skip_to_next", next)
			return
		else:
			push_warning("[splashscreen_cumulet] skip is on but no next scene set — playing splash anyway")

	background_color.color = CUMULET_COLOR
	cumulet_text.modulate.a = 0.0
	var text_tween: Tween = create_tween()

	text_tween.tween_property(cumulet_text, "modulate:a", 1.0, splash_screen_timer).set_trans(Tween.TRANS_CUBIC)
	text_tween.parallel().tween_property(cumulet_logo, "rotation_degrees", 720, splash_screen_timer).set_trans(Tween.TRANS_SINE)
	text_tween.finished.connect(_on_animation_finished)

func _skip_to_next(path: String) -> void:
	get_tree().change_scene_to_file(path)
	
func _on_animation_finished():
	is_animation_finished = true

func _process(delta: float) -> void:
	timer += delta
	if timer > 1.5 and not has_audio_played:
		$SplashScreenAudio.play()
		has_audio_played = true
	if timer > 10.0:
		splashscreen_finish.emit()
	#cumulet_logo.rotation += 3.0 * delta
	if is_animation_finished:
		await get_tree().create_timer(splash_screen_end_timer).timeout
		splashscreen_finish.emit()

func on_splash_finished() -> void:
	var next: String = ProjectSettings.get_setting(NEXT_SCENE_SETTING, "")
	if next == "":
		push_warning("no next scene configured — set one via the editor toolbar button")
		return
	get_tree().change_scene_to_file(next)
