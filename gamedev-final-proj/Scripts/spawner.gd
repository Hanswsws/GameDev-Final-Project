extends Node2D

# --- Exported variables ---
@export var enemy_scene: PackedScene        # The enemy scene to spawn
@export var player: Node2D                 # The player node
@export var spawn_radius := 400.0          # Maximum distance from player to spawn
@export var min_spawn_distance := 200.0    # Minimum distance from player to spawn

@export var initial_spawn_rate := 2.5      # Spawn rate at score 0
@export var min_spawn_rate := 0.5          # Spawn rate at score 500
@export var max_score := 500.0             # Score at which spawn rate reaches min

# --- Internal variables ---
var time_passed := 0.0
var current_spawn_rate := initial_spawn_rate

# --- Process function called every frame ---
func _process(delta):
	if player == null:
		return

	# Update spawn rate based on score
	update_spawn_rate()

	# Increment timer
	time_passed += delta

	# Spawn enemy if timer exceeds current rate
	if time_passed >= current_spawn_rate:
		time_passed = 0.0
		spawn_enemy()

# --- Update spawn rate based on player's score ---
func update_spawn_rate():
	var score = 0
	if player.has_method("get_score"):
		score = player.get_score()
	elif "score" in player:
		score = player.score

	score = clamp(score, 0, max_score)
	current_spawn_rate = lerp(initial_spawn_rate, min_spawn_rate, score / max_score)

# --- Spawn a single enemy ---
func spawn_enemy():
	if player == null or enemy_scene == null:
		return

	# Random angle and distance
	var angle = randf() * TAU
	var distance = randf_range(min_spawn_distance, spawn_radius)
	var pos = player.global_position + Vector2(cos(angle), sin(angle)) * distance

	# Instantiate enemy
	var enemy = enemy_scene.instantiate()
	enemy.global_position = pos

	# Set the player as target if enemy has "target" property
	if "target" in enemy:
		enemy.target = player

	# Add enemy to the current scene
	get_tree().current_scene.add_child(enemy)
