extends Control

const MAIN_MENU_SCENE := "res://Scenes/MainMenu.tscn"

@export var input_delay: float = 0.35

@onready var victory_sound_player: AudioStreamPlayer = $VictorySoundPlayer

var _elapsed: float = 0.0
var _transitioning: bool = false


func _ready() -> void:
	Engine.time_scale = 1.0
	get_tree().paused = false
	_play_victory_sound_once()


func _process(delta: float) -> void:
	_elapsed += delta


func _play_victory_sound_once() -> void:
	if victory_sound_player == null or victory_sound_player.stream == null:
		return
	if victory_sound_player.stream is AudioStreamMP3:
		victory_sound_player.stream.loop = false
	victory_sound_player.play()


func _input(event: InputEvent) -> void:
	if _transitioning or _elapsed < input_delay:
		return

	if _is_return_trigger(event):
		get_viewport().set_input_as_handled()
		_return_to_main_menu()


func _is_return_trigger(event: InputEvent) -> bool:
	if event is InputEventKey:
		return event.pressed and not event.echo and event.keycode != KEY_META
	if event is InputEventMouseButton:
		return event.pressed and event.button_index not in [
			MOUSE_BUTTON_WHEEL_UP,
			MOUSE_BUTTON_WHEEL_DOWN,
			MOUSE_BUTTON_WHEEL_LEFT,
			MOUSE_BUTTON_WHEEL_RIGHT,
		]
	if event is InputEventJoypadButton:
		return event.pressed
	if event is InputEventScreenTouch:
		return event.pressed
	return false


func _return_to_main_menu() -> void:
	if _transitioning:
		return
	_transitioning = true
	if victory_sound_player != null:
		victory_sound_player.stop()
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)
