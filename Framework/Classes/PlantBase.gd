

class_name PlantBase
extends Node2D

# Plant health
var life: float = 100.0
var life_max: float = 100.0

# Grid cell occupied by this plant
var occupied_cell: Vector2i = Vector2i(-1, -1)


func take_damage(amount: float) -> void:
	life -= amount
	life = maxf(life, 0.0)

	if life <= 0:
		die()


func die() -> void:
	queue_free()


func draw_duration_bar(remaining: float, total: float, fill_color: Color) -> void:
	if total <= 0.0:
		return

	var ratio := clampf(remaining / total, 0.0, 1.0)
	var bar_rect := Rect2(-24.0, 35.0, 48.0, 5.0)
	draw_rect(bar_rect, Color(0.1, 0.1, 0.15, 0.8), true)
	draw_rect(Rect2(bar_rect.position, Vector2(bar_rect.size.x * ratio, bar_rect.size.y)), fill_color, true)
