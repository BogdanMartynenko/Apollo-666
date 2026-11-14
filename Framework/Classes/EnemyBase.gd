class_name EnemyBase
extends Area2D

signal died(enemy: Area2D)
signal reached_base(enemy: Area2D)

@export var life_max: float = 100.0
@export var move_speed: float = 28.0
@export var attack_dps: float = 25.0

var life: float = 100.0
var lane: int = 0
var base_breach_x: float = 80.0
var is_distracted: bool = false

@onready var sprite: Sprite2D = get_node_or_null("Sprite2D")
var _hit_flash_timer: float = 0.0
var _is_dead: bool = false


func _ready() -> void:
	life = life_max
	add_to_group("enemies")


func _physics_process(delta: float) -> void:
	if _hit_flash_timer > 0.0:
		_hit_flash_timer = maxf(_hit_flash_timer - delta, 0.0)
		if _hit_flash_timer == 0.0 and sprite != null:
			sprite.modulate = Color.WHITE

	var blocking_plant := _find_blocking_plant()
	if blocking_plant != null:
		if blocking_plant.has_method("attract_human"):
			is_distracted = true
			blocking_plant.call("attract_human", self)
		else:
			is_distracted = false
			blocking_plant.take_damage(attack_dps * delta)
		return

	is_distracted = false
	position.x -= move_speed * delta

	if position.x <= base_breach_x:
		reached_base.emit(self)
		queue_free()


func _find_blocking_plant() -> PlantBase:
	for area in get_overlapping_areas():
		if not is_instance_valid(area):
			continue
		var plant := area.get_parent() as PlantBase
		if plant == null or plant.is_queued_for_deletion():
			continue
		if plant.occupied_cell.y != lane:
			continue
		if plant.global_position.x <= global_position.x + 16.0:
			return plant
	return null


func take_damage(amount: float) -> void:
	if is_queued_for_deletion():
		return

	life = maxf(life - amount, 0.0)
	_trigger_hit_flash()

	if life <= 0.0:
		die()


func _trigger_hit_flash() -> void:
	if sprite == null:
		return
	sprite.modulate = Color(0.75, 0.55, 1.0)
	_hit_flash_timer = 0.1


func die() -> void:
	if _is_dead:
		return
	_is_dead = true
	died.emit(self)
	queue_free()
