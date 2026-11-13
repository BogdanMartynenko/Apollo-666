
extends Node2D

# References to our existing nodes
@onready var selector = $Selector
@onready var peashooter_button = $CanvasLayer/Control/HBoxContainer/PeashooterButton
@onready var sunflower_button = $CanvasLayer/Control/HBoxContainer/SunflowerButton

# Plant resources
@export var peashooter_data: PlantData
@export var sunflower_data: PlantData


func _ready() -> void:

	# Connect the Peashooter button
	peashooter_button.pressed.connect(_on_peashooter_button_pressed)

	# Connect the Sunflower button
	sunflower_button.pressed.connect(_on_sunflower_button_pressed)


func _on_peashooter_button_pressed() -> void:

	# Select Peashooter
	selector.select_plant(peashooter_data)


func _on_sunflower_button_pressed() -> void:

	# Select Sunflower
	selector.select_plant(sunflower_data)
