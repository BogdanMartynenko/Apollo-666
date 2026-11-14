extends Node

const EnemyBaseScript = preload("res://Framework/Classes/EnemyBase.gd")
const GridManagerScript = preload("res://Framework/Managers/GridManager.gd")

signal enemy_breached
signal all_enemies_defeated
signal wave_progress_changed(defeated_count: int, total_count: int)

@export var enemy_scene: PackedScene
@export var total_enemies_to_spawn: int = 12
@export var initial_delay: float = 8.0
@export var start_spawn_interval: float = 9.0
@export var min_spawn_interval: float = 4.0
@export var interval_decrease_per_spawn: float = 0.25
@export var spawn_offset_x: float = 240.0

@onready var grid_manager := get_parent().get_node_or_null("GridManager") as GridManagerScript

var _elapsed: float = 0.0
var _spawn_timer: float = 0.0
var _current_interval: float = 9.0
var _has_started_spawning: bool = false
var _last_lane: int = -1
var _spawned_count: int = 0
var _defeated_count: int = 0
var _active_enemies: int = 0
var _breached: bool = false


func _ready() -> void:
	_current_interval = start_spawn_interval
	wave_progress_changed.emit(_defeated_count, total_enemies_to_spawn)


func _process(delta: float) -> void:
	if enemy_scene == null or _breached:
		return

	if _spawned_count >= total_enemies_to_spawn:
		return

	_elapsed += delta
	if not _has_started_spawning:
		if _elapsed < initial_delay:
			return
		_has_started_spawning = true
		spawn_enemy()
		_spawn_timer = 0.0
		return

	_spawn_timer += delta
	if _spawn_timer >= _current_interval:
		spawn_enemy()
		_spawn_timer = 0.0
		_current_interval = maxf(min_spawn_interval, _current_interval - interval_decrease_per_spawn)


func spawn_enemy() -> void:
	if _spawned_count >= total_enemies_to_spawn:
		return

	var rows: int = grid_manager.ROWS if grid_manager != null else 5
	var lane := _pick_lane(rows)

	var enemy := enemy_scene.instantiate() as EnemyBaseScript
	if enemy == null:
		return

	var spawn_x: float = (grid_manager.get_grid_right_x() if grid_manager != null else 820.0) + spawn_offset_x
	var spawn_y: float = grid_manager.get_lane_center_y(lane) if grid_manager != null else (100.0 + lane * 100.0 + 50.0)
	var breach_x: float = (grid_manager.get_grid_left_x() if grid_manager != null else 100.0) - 30.0

	enemy.lane = lane
	enemy.base_breach_x = breach_x
	enemy.died.connect(_on_enemy_died)
	enemy.reached_base.connect(_on_enemy_reached_base)

	_spawned_count += 1
	_active_enemies += 1

	get_parent().add_child(enemy)
	enemy.global_position = Vector2(spawn_x, spawn_y)


func _pick_lane(rows: int) -> int:
	if rows <= 1:
		return 0
	var lane := randi_range(0, rows - 1)
	if lane == _last_lane:
		lane = (lane + randi_range(1, rows - 1)) % rows
	_last_lane = lane
	return lane


func _on_enemy_died(_enemy: Area2D) -> void:
	_active_enemies = maxi(0, _active_enemies - 1)
	_defeated_count += 1
	wave_progress_changed.emit(_defeated_count, total_enemies_to_spawn)

	if not _breached and _spawned_count >= total_enemies_to_spawn and _active_enemies == 0:
		all_enemies_defeated.emit()


func _on_enemy_reached_base(_enemy: Area2D) -> void:
	_active_enemies = maxi(0, _active_enemies - 1)
	if _breached:
		return
	_breached = true
	enemy_breached.emit()
