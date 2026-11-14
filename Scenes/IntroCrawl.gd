extends Control

@export var crawl_speed: float = 18.5
@export var music_start_offset: float = 28.75
@export var music_end_time: float = 103.5

@onready var crawl_content: VBoxContainer = $SubViewportContainer/SubViewport/CrawlContent
@onready var music_player: AudioStreamPlayer = $MusicPlayer

var _stars: Array[Vector3] = []
var _transitioning: bool = false


func _ready() -> void:
	Engine.time_scale = 1.0
	get_tree().paused = false
	_generate_stars()
	queue_redraw()

	if music_player != null and music_player.stream != null:
		music_player.play(music_start_offset)


func _generate_stars() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 6662300
	for _i in range(110):
		_stars.append(Vector3(
			rng.randf_range(0.0, 1.0),
			rng.randf_range(0.0, 1.0),
			rng.randf_range(0.35, 0.95)
		))


func _draw() -> void:
	var rect := get_viewport_rect()
	draw_rect(rect, Color(0.02, 0.02, 0.05, 1.0), true)

	for star in _stars:
		var pos := Vector2(star.x * rect.size.x, star.y * rect.size.y)
		var radius := 1.5 if star.z > 0.75 else 1.0
		draw_circle(pos, radius, Color(0.92, 0.95, 1.0, star.z))


func _process(delta: float) -> void:
	if _transitioning or crawl_content == null:
		return

	crawl_content.position.y -= crawl_speed * delta

	if music_player != null and music_player.playing:
		var pos := music_player.get_playback_position()
		if pos >= music_end_time - 2.0:
			var fade := clampf((music_end_time - pos) / 2.0, 0.0, 1.0)
			music_player.volume_db = linear_to_db(maxf(fade, 0.001))

	if crawl_content.position.y + crawl_content.size.y < 30.0:
		_start_game()


func _input(event: InputEvent) -> void:
	if _transitioning:
		return

	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_SPACE or event.physical_keycode == KEY_SPACE:
			get_viewport().set_input_as_handled()
			_start_game()


func _start_game() -> void:
	if _transitioning:
		return
	_transitioning = true
	if music_player != null:
		music_player.stop()
	get_tree().change_scene_to_file("res://Scenes/Main.tscn")
