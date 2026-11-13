
extends Node2D

# References to our existing nodes
@onready var selector = $Selector
@onready var peashooter_button = $CanvasLayer/Control/HBoxContainer/PeashooterButton

# The Peashooter resource
@export var peashooter_data: PlantData


func _ready() -> void:

	# Connect the button's pressed signal
	peashooter_button.pressed.connect(_on_peashooter_button_pressed)


func _on_peashooter_button_pressed() -> void:

	# Tell PlantSelector which plant was selected
	selector.select_plant(peashooter_data)
