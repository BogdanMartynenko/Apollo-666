extends Control

@onready var play_button: Button = $PlayButton


func _ready() -> void:
	Engine.time_scale = 1.0
	get_tree().paused = false
	play_button.pressed.connect(_on_play_pressed)


func _on_play_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/IntroCrawl.tscn")
