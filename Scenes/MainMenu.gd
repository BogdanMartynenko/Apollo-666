extends Control

@onready var play_button: Button = $PlayButton
@onready var tutorial_button: Button = $TutorialButton


func _ready() -> void:
	Engine.time_scale = 1.0
	get_tree().paused = false
	play_button.pressed.connect(_on_play_pressed)
	tutorial_button.pressed.connect(_on_tutorial_pressed)


func _on_play_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/IntroCrawl.tscn")


func _on_tutorial_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/TutorialScreen.tscn")
