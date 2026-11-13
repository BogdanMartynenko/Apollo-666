extends PlantBase

const EnemyBaseScript = preload("res://Framework/Classes/EnemyBase.gd")
const ProjectileBaseScript = preload("res://Framework/Classes/ProjectileBase.gd")

@export var ink_projectile_scene: PackedScene
@export var fire_interval: float = 1.5
@export var ink_damage: float = 25.0
@export var projectile_speed: float = 320.0
@export var detect_max_x: float = 1140.0

@onready var muzzle: Marker2D = get_node_or_null("Muzzle")

var _fire_cooldown: float = 0.25


func _ready() -> void:
	life = 100.0
	life_max = 100.0


func _process(delta: float) -> void:
	if _fire_cooldown > 0.0:
		_fire_cooldown = maxf(_fire_cooldown - delta, 0.0)

	if _fire_cooldown <= 0.0 and _has_enemy_in_lane():
		_shoot_ink()
		_fire_cooldown = fire_interval


func _has_enemy_in_lane() -> bool:
	if occupied_cell.y < 0:
		return false

	for node in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(node) or node.is_queued_for_deletion():
			continue
		var enemy := node as EnemyBaseScript
		if enemy == null:
			continue
		if enemy.lane == occupied_cell.y and enemy.global_position.x >= global_position.x and enemy.global_position.x <= detect_max_x:
			return true

	return false


func _shoot_ink() -> void:
	if ink_projectile_scene == null:
		return

	var projectile := ink_projectile_scene.instantiate() as ProjectileBaseScript
	if projectile == null:
		return

	projectile.lane = occupied_cell.y
	projectile.damage = ink_damage
	projectile.speed = projectile_speed

	var parent_node := get_parent()
	if parent_node == null:
		return

	parent_node.add_child(projectile)
	projectile.global_position = muzzle.global_position if muzzle != null else global_position + Vector2(28.0, -4.0)
