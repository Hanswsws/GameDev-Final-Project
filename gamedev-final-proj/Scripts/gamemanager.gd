extends Node2D

signal score_changed(new_score)
signal level_completed(level_number)

var score = 0
var current_level = 1
const TARGET_SCORE = 3000  # score threshold to change scene

func add_score(amount):
	score += amount
	score_changed.emit(score)
	print("Score: ", score)
	
	# Check if score reached target
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
		SaveSystem.complete_level2()

# Function to change the scene
func change_to_gamemap2():
		get_tree().change_scene_to_file("res://Scenes/gamemap2.tscn")
