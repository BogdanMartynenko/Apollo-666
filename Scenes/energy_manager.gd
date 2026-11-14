
extends Node

# Emitted whenever the stored energy changes
signal energy_changed(new_amount: int)

# Battery settings
@export var max_energy: int = 1000

# Current energy stored in the battery (starts with 50 like PvZ)
@export var current_energy: int = 50


func _ready() -> void:
	energy_changed.emit(current_energy)


# Add energy to the battery
func add_energy(amount: int) -> void:

	if amount <= 0:
		return

	current_energy += amount

	# Don't allow the battery to exceed its capacity
	current_energy = min(current_energy, max_energy)

	print("Scrollium: ", current_energy, " / ", max_energy)

	# Notify other systems that the energy changed
	energy_changed.emit(current_energy)


# Spend energy to purchase a plant
func spend_energy(amount: int) -> bool:

	# Check whether the player has enough energy
	if amount > current_energy:
		print("Not enough Scrollium!")
		return false

	if amount <= 0:
		return false

	current_energy -= amount

	print("Scrollium: ", current_energy, " / ", max_energy)

	energy_changed.emit(current_energy)

	return true
