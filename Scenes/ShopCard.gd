extends Button

@onready var icon_rect: TextureRect = $MarginContainer/HBoxContainer/IconRect
@onready var name_label: Label = $MarginContainer/HBoxContainer/InfoBox/NameLabel
@onready var cost_label: Label = $MarginContainer/HBoxContainer/InfoBox/CostLabel

var plant_data: PlantData


func setup(data: PlantData) -> void:
	plant_data = data
	if plant_data == null:
		return

	if icon_rect != null:
		icon_rect.texture = plant_data.icon
	if name_label != null:
		name_label.text = plant_data.plant_name
	if cost_label != null:
		cost_label.text = "%d Scrollium" % plant_data.plant_cost


func update_state(current_energy: int, selected_plant: PlantData) -> void:
	if plant_data == null:
		disabled = true
		button_pressed = false
		return

	var can_afford := current_energy >= plant_data.plant_cost
	disabled = not can_afford
	button_pressed = can_afford and selected_plant == plant_data
	modulate = Color.WHITE if can_afford else Color(0.68, 0.68, 0.75, 0.85)

	if cost_label != null:
		cost_label.add_theme_color_override(
			"font_color",
			Color(1.0, 0.85, 0.25) if can_afford else Color(1.0, 0.42, 0.42)
		)
