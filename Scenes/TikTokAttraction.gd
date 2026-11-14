extends PlantBase

# How long (in seconds) this attraction stops humans once triggered
@export var stop_duration: float = 12.0

var _activated: bool = false
var _remaining_time: float = 0.0


func _ready() -> void:
	life = 200.0
	life_max = 200.0
	_remaining_time = stop_duration
	queue_redraw()


func attract_human(_human: Node) -> void:
	if not _activated:
		_activated = true
		queue_redraw()


func _process(delta: float) -> void:
	if not _activated:
		return

	_remaining_time = maxf(_remaining_time - delta, 0.0)
	queue_redraw()

	if _remaining_time <= 0.0:
		die()


func _draw() -> void:
	if not _activated:
		return

	draw_duration_bar(_remaining_time, stop_duration, Color(0.15, 0.95, 0.9))
