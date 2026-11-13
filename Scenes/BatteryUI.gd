extends VBoxContainer

# References to the battery and UI elements
@onready var energy_manager = _find_energy_manager()
@onready var energy_label = $EnergyLabel
@onready var energy_bar = $EnergyBar


func _find_energy_manager():
	if owner != null:
		var node = owner.get_node_or_null("EnergyManager")
		if node != null:
			return node
	return get_node_or_null("../../../EnergyManager")


func _ready() -> void:
	if energy_manager == null:
		return

	# Listen for changes in battery energy
	energy_manager.energy_changed.connect(_on_energy_changed)

	# Display the initial battery amount
	_on_energy_changed(energy_manager.current_energy)


func _on_energy_changed(new_amount: int) -> void:
	# Update the numerical counter
	energy_label.text = "Battery: %d / %d" % [
		new_amount,
		energy_manager.max_energy
	]

	# Update the progress bar
	energy_bar.max_value = energy_manager.max_energy
	energy_bar.value = new_amount
