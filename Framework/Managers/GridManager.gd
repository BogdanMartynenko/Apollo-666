
# Creates a grid of 9 columns and 5 rows.
# Each cell is 80x100 pixels.
# Tracks which cells are occupied and places selected plants.

extends Node2D


# GRID SETTINGS
const ROWS: int = 5
const COLUMNS: int = 9

const CELL_SIZE: Vector2 = Vector2(80, 100)
const GRID_ORIGIN: Vector2 = Vector2(100, 100)


# The plant currently selected by the player
var selected_plant: PlantData = null


# Stores occupied cells and the plants inside them
var occupied_cells: Dictionary = {}


func _ready() -> void:
	queue_redraw()


# DRAW THE GRID
func _draw() -> void:

	for row in range(ROWS):
		for column in range(COLUMNS):

			var cell := Rect2(
				GRID_ORIGIN + Vector2(column, row) * CELL_SIZE,
				CELL_SIZE
			)

			var color = Color(0.35, 0.65, 0.25)

			if (row + column) % 2 == 0:
				color = Color(0.40, 0.72, 0.30)

			draw_rect(cell, color, true)
			draw_rect(cell, Color(0.15, 0.35, 0.12), false, 2.0)


# CONVERT MOUSE POSITION INTO GRID COORDINATES
func get_cell_from_position(mouse_pos: Vector2) -> Vector2i:

	var local_pos = mouse_pos - GRID_ORIGIN

	var column = floori(local_pos.x / CELL_SIZE.x)
	var row = floori(local_pos.y / CELL_SIZE.y)

	return Vector2i(column, row)


# CHECK IF A CELL EXISTS INSIDE THE GRID
func is_cell_valid(cell: Vector2i) -> bool:

	return (
		cell.x >= 0 and
		cell.x < COLUMNS and
		cell.y >= 0 and
		cell.y < ROWS
	)


# SELECT A PLANT
func select_plant(plant_data: PlantData) -> void:

	selected_plant = plant_data

	print("Selected plant: ", selected_plant.plant_name)


# PLACE THE SELECTED PLANT IN A CELL
func place_plant(cell: Vector2i) -> void:

	if not is_cell_valid(cell):
		return

	if occupied_cells.has(cell):
		print("Cell already occupied!")
		return

	if selected_plant == null:
		print("No plant selected!")
		return

	if selected_plant.plant_scene == null:
		print("Selected plant has no scene assigned!")
		return

	# Create an instance of the selected plant scene
	var plant = selected_plant.plant_scene.instantiate()

	# Calculate the centre of the cell
	var plant_position = GRID_ORIGIN + Vector2(
		cell.x * CELL_SIZE.x + CELL_SIZE.x / 2,
		cell.y * CELL_SIZE.y + CELL_SIZE.y / 2
	)

	add_child(plant)

	plant.position = plant_position
	plant.occupied_cell = cell

	occupied_cells[cell] = plant

	print("Plant placed at: ", cell)


# HANDLE MOUSE INPUT
func _unhandled_input(event: InputEvent) -> void:

	if event is InputEventMouseButton:

		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:

			var cell = get_cell_from_position(
				get_global_mouse_position()
			)

			place_plant(cell)
