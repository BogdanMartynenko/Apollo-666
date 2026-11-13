
extends Area2D
signal collected(amount: int)
# How much energy this particle contains
@export var energy_value: int = 25

# How quickly it falls
@export var fall_speed: float = 45.0


func _ready() -> void:
	# Tag orb so grid placement ignores clicks on collectible energy
	add_to_group("energy_orbs")

	# Allow the particle to receive mouse clicks
	input_pickable = true

	# Connect the click signal
	input_event.connect(_on_input_event)

	# Draw our energy particle
	queue_redraw()


func _process(delta: float) -> void:
	# Move the particle downward
	position.y += fall_speed * delta


func _draw() -> void:
	# Outer glow
	draw_circle(Vector2.ZERO, 18, Color(1.0, 0.8, 0.1, 0.2))

	# Main golden orb
	draw_circle(Vector2.ZERO, 11, Color(1.0, 0.8, 0.1))

	# Small bright centre
	draw_circle(Vector2(-3, -3), 4, Color(1.0, 1.0, 0.75))


func _on_input_event(
	_viewport: Node,
	event: InputEvent,
	_shape_idx: int
) -> void:

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:

			# Tell the game this particle was collected
			collect()
			get_viewport().set_input_as_handled()


func collect() -> void:

	# Send the orb's energy value to the EnergyManager
	collected.emit(energy_value)

	# Remove the orb from the game
	queue_free()
