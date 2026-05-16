extends Node2D

signal score_changed(new_score)
signal level_completed(level_number)

var score = 0
var current_level = 1
const TARGET_SCORE = 2000

func add_score(amount):
	score += amount
	score_changed.emit(score)
	print("Score: ", score)

	if score >= TARGET_SCORE:
		change_to_gamemap2()

func reset_score():
	score = 0
	score_changed.emit(score)

func complete_level(level_number: int):
	level_completed.emit(level_number)
	if level_number == 1:
		SaveSystem.unlock_level2()
	if level_number == 2:
		# Completing Level 2 also unlocks it in Arcade Mode
		SaveSystem.unlock_level2()
		SaveSystem.complete_level2()

func change_to_gamemap2():
	# Unlock Level 2 when transitioning from Level 1
	SaveSystem.unlock_level2()
	Bosstransition.transition("res://Scenes/gamemap2.tscn")
	get_tree().change_scene_to_file("res://Scenes/gamemap2.tscn")
