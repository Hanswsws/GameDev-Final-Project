extends Node2D

var level_complete = false

func _ready():
	Gamemanager.current_level = 2
	Musicmanager.play_boss_music()

	# Restore player health carried from Level 1
	var player = get_tree().get_first_node_in_group("player")
	if player and Gamemanager.has_meta("carry_health"):
		var carried = Gamemanager.get_meta("carry_health")
		player.health = clamp(carried, 20, 100)
		player.health_changed.emit(player.health, player.max_health)
		print("Level 2: Restored player health to ", player.health)

	# Connect to the boss signal once scene is fully loaded
	call_deferred("_connect_to_boss")

func _connect_to_boss():
	# Find the robot boss in the scene
	for node in get_tree().get_nodes_in_group("enemies"):
		if node.has_signal("boss_died"):
			node.boss_died.connect(_on_boss_died)
			print("gamemap2: Connected to boss_died signal")

	# Also catch bosses that spawn later
	get_tree().node_added.connect(_on_node_added)

func _on_node_added(node: Node):
	if node.has_signal("boss_died"):
		await get_tree().process_frame
		if is_instance_valid(node) and not node.boss_died.is_connected(_on_boss_died):
			node.boss_died.connect(_on_boss_died)
			print("gamemap2: Connected to newly spawned boss")

func _on_boss_died():
	if level_complete:
		return
	level_complete = true
	print("Robot Boss defeated! Showing The End screen...")

	Gamemanager.complete_level(2)

	# Stop all spawners
	for spawner in get_tree().get_nodes_in_group("spawners"):
		spawner.set_process(false)

	# Short pause before showing end screen
	await get_tree().create_timer(1.5).timeout

	var hud = get_tree().get_first_node_in_group("hud")
	if hud:
		hud.show_end_screen()
	else:
		get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
