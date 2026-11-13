

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
