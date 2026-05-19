extends Control

## TODO: Implement Audio - Let's do the random "cumulet!" things ?

const START_SCREEN_SCENE_PATH: String = "res://main.tscn"
const CUMULET_COLOR := Color("0f34fc")

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
func _ready() -> void:
	background_color.color = CUMULET_COLOR
	cumulet_text.modulate.a = 0.0
	var text_tween: Tween = create_tween()
	text_tween.tween_property(cumulet_text, "modulate:a", 1.0, 1.0).set_trans(Tween.TRANS_CUBIC)
	text_tween.finished.connect(_on_animation_finished)
	splashscreen_finish.connect(on_splash_finished)
	
func _on_animation_finished():
	is_animation_finished = true

func _process(delta: float) -> void:
	timer += delta
	if timer > 1.5 and not has_audio_played:
		$SplashScreenAudio.play()
		has_audio_played = true
	if timer > 10.0:
		splashscreen_finish.emit()
	cumulet_logo.rotation += 3.0 * delta
	if is_animation_finished:
		splashscreen_finish.emit()

func on_splash_finished() -> void:
	var next: String = ProjectSettings.get_setting(NEXT_SCENE_SETTING, "")
	if next == "":
		push_warning("no next scene configured — set one via the editor toolbar button")
		return
	get_tree().change_scene_to_file(next)
