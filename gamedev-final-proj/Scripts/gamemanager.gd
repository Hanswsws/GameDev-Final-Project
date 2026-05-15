extends Node2D

signal score_changed(new_score)
signal level_completed(level_number)

var score = 0
var current_level = 1

func add_score(amount):
	score += amount
	score_changed.emit(score)
	print("Score: ", score)

func reset_score():
	score = 0
	score_changed.emit(score)

func complete_level(level_number: int):
	print("Gamemanager: Level ", level_number, " completed!")
	level_completed.emit(level_number)
	if level_number == 1:
		SaveSystem.unlock_level2()
	if level_number == 2:
		SaveSystem.complete_level2()
