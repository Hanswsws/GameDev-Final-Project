extends Node2D

@export var enemy_scene: PackedScene
@export var player: Node2D
@export var spawn_radius := 400.0
@export var min_spawn_distance := 200.0
@export var spawn_rate := 1.0

var time_passed := 0.0

func _process(delta):
	time_passed += delta

	if time_passed >= spawn_rate:
		time_passed = 0.0
		spawn_enemy()

func spawn_enemy():
	if player == null:
		return

	var angle = randf() * TAU
	var distance = randf_range(min_spawn_distance, spawn_radius)
	var pos = player.global_position + Vector2(cos(angle), sin(angle)) * distance

	var enemy = enemy_scene.instantiate()
	enemy.global_position = pos
	enemy.target = player

	get_tree().current_scene.add_child(enemy)
