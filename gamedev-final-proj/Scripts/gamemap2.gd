extends Node2D

const KILLS_TO_COMPLETE = 50

var kill_count = 0
var level_complete = false
var transition_scene = preload("res://Scenes/level_transition.tscn")

func _ready():
	Gamemanager.current_level = 2
	Musicmanager.play_battle_music()

	var player = get_tree().get_first_node_in_group("player")
	if player and Gamemanager.has_meta("carry_health"):
		var carried = Gamemanager.get_meta("carry_health")
		player.health = clamp(carried, 20, 100)
		print("Level 2: Restored player health to ", player.health)

	Gamemanager.score_changed.connect(_on_score_changed)

func _on_score_changed(new_score):
	kill_count = new_score / 50
	if kill_count >= KILLS_TO_COMPLETE and not level_complete:
		_trigger_level_complete()

func _trigger_level_complete():
	level_complete = true
	print("Level 2 Complete!")

	Gamemanager.complete_level(2)

	for spawner in get_tree().get_nodes_in_group("spawners"):
		spawner.set_process(false)

	Musicmanager.play_boss_music()
	await get_tree().create_timer(2.0).timeout

	var hud = get_tree().get_first_node_in_group("hud")
	if hud:
		hud.show_win_screen()
	else:
		get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
