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
	if not _activated or stop_duration <= 0.0:
		return

	var ratio := clampf(_remaining_time / stop_duration, 0.0, 1.0)
	var bar_rect := Rect2(-24.0, 35.0, 48.0, 5.0)
	draw_rect(bar_rect, Color(0.1, 0.1, 0.15, 0.8), true)
	draw_rect(Rect2(bar_rect.position, Vector2(bar_rect.size.x * ratio, bar_rect.size.y)), Color(0.15, 0.95, 0.9), true)
