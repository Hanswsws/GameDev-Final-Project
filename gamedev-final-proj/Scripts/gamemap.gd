extends Node2D

const KILLS_TO_COMPLETE = 30

var kill_count = 0
var level_complete = false

var transition_scene = preload("res://Scenes/level_transition.tscn")

func _ready():
	Gamemanager.current_level = 1
	Gamemanager.score_changed.connect(_on_score_changed)

func _on_score_changed(new_score):
	kill_count = new_score / 50
	if kill_count >= KILLS_TO_COMPLETE and not level_complete:
		_trigger_level_complete()

func _trigger_level_complete():
	level_complete = true
	print("Level 1 Complete! Transitioning to Level 2...")

	Gamemanager.complete_level(1)

	for spawner in get_tree().get_nodes_in_group("spawners"):
		spawner.set_process(false)

	var player = get_tree().get_first_node_in_group("player")
	if player:
		Gamemanager.set_meta("carry_health", player.health)

	Musicmanager.play_boss_music()
	await get_tree().create_timer(1.5).timeout

	var transition = transition_scene.instantiate()
	add_child(transition)
	transition.transition_to("res://Scenes/gamemap2.tscn", "STAGE  2")
