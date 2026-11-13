class_name ProjectileBase
extends Area2D

const EnemyBaseScript = preload("res://Framework/Classes/EnemyBase.gd")

@export var speed: float = 320.0
@export var damage: float = 25.0
@export var max_x: float = 1220.0
@export var ink_color: Color = Color(0.14, 0.06, 0.22)

var lane: int = -1
var _has_hit: bool = false


func _ready() -> void:
	area_entered.connect(_on_area_entered)
	queue_redraw()


func _draw() -> void:
	draw_circle(Vector2.ZERO, 9.0, ink_color)
	draw_circle(Vector2(-7.0, 2.0), 5.0, ink_color)
	draw_circle(Vector2(2.0, -3.0), 2.5, Color(0.45, 0.35, 0.65))


func _physics_process(delta: float) -> void:
	if _has_hit:
		return

	if _check_overlapping_enemies():
		return

	position.x += speed * delta
	if position.x > max_x:
		queue_free()


func _on_area_entered(area: Area2D) -> void:
	_try_hit_enemy(area)


func _check_overlapping_enemies() -> bool:
	for area in get_overlapping_areas():
		if _try_hit_enemy(area):
			return true
	return false


func _try_hit_enemy(area: Area2D) -> bool:
	if _has_hit or not is_instance_valid(area):
		return false

	var enemy := area as EnemyBaseScript
	if enemy == null or enemy.is_queued_for_deletion():
		return false

	if lane >= 0 and enemy.lane != lane:
		return false

	_has_hit = true
	enemy.take_damage(damage)
	queue_free()
	return true
