
extends Node

# The scene that we want to spawn
@export var energy_orb_scene: PackedScene

# Time between spawning energy orbs
@export var spawn_interval: float = 7.0

var time_since_last_spawn: float = 0.0

# Find the EnergyManager node
@onready var energy_manager = get_parent().get_node("EnergyManager")


func _process(delta: float) -> void:

	time_since_last_spawn += delta

	if time_since_last_spawn >= spawn_interval:
		spawn_energy_orb()
		time_since_last_spawn = 0.0


func spawn_energy_orb() -> void:

	# Create a new energy orb
	var orb = energy_orb_scene.instantiate()

	# Connect the orb's signal to the battery
	orb.collected.connect(energy_manager.add_energy)

	# Add the orb to the main scene
	get_parent().add_child(orb)

	# Choose a random horizontal position above the grid
	orb.position = Vector2(randf_range(100, 820), 60)
