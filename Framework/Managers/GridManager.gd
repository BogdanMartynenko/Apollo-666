
# Creates a grid of 9 columns and 5 rows.
# Each cell is 80x100 pixels.
# Tracks which cells are occupied and places selected plants.

extends Node2D

signal selection_changed(plant_data: PlantData)

@onready var energy_manager = get_parent().get_node("EnergyManager")

# GRID SETTINGS
const ROWS: int = 5
const COLUMNS: int = 9

const CELL_SIZE: Vector2 = Vector2(80, 100)
const GRID_ORIGIN: Vector2 = Vector2(100, 100)


# The plant currently selected by the player
var selected_plant: PlantData = null
var _hovered_cell: Vector2i = Vector2i(-1, -1)


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

	if selected_plant != null and is_cell_valid(_hovered_cell):
		var hover_rect := Rect2(
			GRID_ORIGIN + Vector2(_hovered_cell.x, _hovered_cell.y) * CELL_SIZE,
			CELL_SIZE
		)
		var cell_free := not occupied_cells.has(_hovered_cell) or not is_instance_valid(occupied_cells[_hovered_cell])
		var hover_color := Color(0.7, 1.0, 0.55, 0.28) if cell_free else Color(1.0, 0.3, 0.3, 0.32)
		var border_color := Color(0.85, 1.0, 0.7, 0.9) if cell_free else Color(1.0, 0.4, 0.4, 0.9)
		draw_rect(hover_rect, hover_color, true)
		draw_rect(hover_rect, border_color, false, 3.0)


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
	selection_changed.emit(selected_plant)
	queue_redraw()

	if selected_plant != null:
		print("Selected plant: ", selected_plant.plant_name)


func clear_selection() -> void:
	selected_plant = null
	selection_changed.emit(null)
	queue_redraw()


# PLACE THE SELECTED PLANT IN A CELL
func place_plant(cell: Vector2i) -> void:

	if not is_cell_valid(cell):
		return

	if occupied_cells.has(cell):
		if is_instance_valid(occupied_cells[cell]):
			print("Cell already occupied!")
			return
		occupied_cells.erase(cell)

	if selected_plant == null:
		print("No plant selected!")
		return
		
	# Pay for the plant using battery energy
	if not energy_manager.spend_energy(selected_plant.plant_cost):
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
	plant.tree_exited.connect(_on_plant_tree_exited.bind(cell, plant))
	clear_selection()

	print("Plant placed at: ", cell)


func _on_plant_tree_exited(cell: Vector2i, plant: Node) -> void:
	if occupied_cells.get(cell) == plant:
		occupied_cells.erase(cell)


func get_lane_center_y(lane: int) -> float:
	return GRID_ORIGIN.y + lane * CELL_SIZE.y + CELL_SIZE.y / 2.0


func get_grid_left_x() -> float:
	return GRID_ORIGIN.x


func get_grid_right_x() -> float:
	return GRID_ORIGIN.x + COLUMNS * CELL_SIZE.x


# HANDLE MOUSE INPUT
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var new_cell := get_cell_from_position(get_global_mouse_position())
		if new_cell != _hovered_cell:
			_hovered_cell = new_cell
			if selected_plant != null:
				queue_redraw()
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			if selected_plant != null:
				clear_selection()
				get_viewport().set_input_as_handled()
			return

		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var mouse_pos := get_global_mouse_position()

			# Let EnergyOrb handle the click without placing on the grid underneath
			if _is_clicking_energy_orb(mouse_pos):
				return

			var cell = get_cell_from_position(mouse_pos)

			place_plant(cell)


# Check whether an energy orb is under the clicked world position
func _is_clicking_energy_orb(world_pos: Vector2) -> bool:
	var space_state := get_world_2d().direct_space_state
	var query := PhysicsPointQueryParameters2D.new()
	query.position = world_pos
	query.collide_with_areas = true
	query.collide_with_bodies = false

	for hit in space_state.intersect_point(query):
		var collider = hit.get("collider")
		if collider is Node and collider.is_in_group("energy_orbs") and not collider.is_queued_for_deletion():
			return true

	return false
