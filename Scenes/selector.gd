
extends Node

# Find GridManager, which is a sibling of Selector
@onready var grid_manager = $"../GridManager"


# Called when the player chooses a plant
func select_plant(plant: PlantData) -> void:

	grid_manager.select_plant(plant)

	print("Selected plant: ", plant.plant_name)


# Clear the current selection
func clear_selection() -> void:

	grid_manager.clear_selection()
