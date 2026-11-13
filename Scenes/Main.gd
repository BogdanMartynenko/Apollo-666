extends Node2D

# References to our existing nodes
@onready var selector = $Selector
@onready var grid_manager = $GridManager
@onready var energy_manager = $EnergyManager
@onready var peashooter_button = $CanvasLayer/Control/ShopPanel/MarginContainer/HBoxContainer/PeashooterButton
@onready var sunflower_button = $CanvasLayer/Control/ShopPanel/MarginContainer/HBoxContainer/SunflowerButton
@onready var enemy_spawner = $EnemySpawner
@onready var game_over_panel = $CanvasLayer/GameOverPanel
@onready var restart_button = $CanvasLayer/GameOverPanel/MarginContainer/VBoxContainer/RestartButton

# Plant resources
@export var peashooter_data: PlantData
@export var sunflower_data: PlantData


func _ready() -> void:
	peashooter_button.setup(peashooter_data)
	sunflower_button.setup(sunflower_data)

	# Connect the shop cards
	peashooter_button.pressed.connect(_on_peashooter_button_pressed)
	sunflower_button.pressed.connect(_on_sunflower_button_pressed)

	if energy_manager != null:
		energy_manager.energy_changed.connect(_on_energy_changed)

	if grid_manager != null:
		grid_manager.selection_changed.connect(_on_selection_changed)

	if enemy_spawner != null:
		enemy_spawner.enemy_breached.connect(_on_enemy_breached)

	if restart_button != null:
		restart_button.pressed.connect(_on_restart_pressed)

	_refresh_shop_ui()


func _on_peashooter_button_pressed() -> void:
	_toggle_plant_selection(peashooter_data)


func _on_sunflower_button_pressed() -> void:
	_toggle_plant_selection(sunflower_data)


func _toggle_plant_selection(data: PlantData) -> void:
	if data == null:
		return
	if grid_manager != null and grid_manager.selected_plant == data:
		selector.clear_selection()
	else:
		selector.select_plant(data)


func _on_energy_changed(_new_amount: int) -> void:
	_refresh_shop_ui()


func _on_selection_changed(_plant_data: PlantData) -> void:
	_refresh_shop_ui()


func _refresh_shop_ui() -> void:
	var current_energy: int = energy_manager.current_energy if energy_manager != null else 0
	var selected: PlantData = grid_manager.selected_plant if grid_manager != null else null
	peashooter_button.update_state(current_energy, selected)
	sunflower_button.update_state(current_energy, selected)


func _on_enemy_breached() -> void:
	if game_over_panel != null:
		game_over_panel.visible = true
	get_tree().paused = true


func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
