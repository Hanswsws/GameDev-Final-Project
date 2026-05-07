extends Control

# ——— Node references ———
@onready var resume_button    = $Panel/VBox/ResumeButton
@onready var main_menu_button = $Panel/VBox/MainMenuButton

func _ready():
	resume_button.pressed.connect(_on_resume_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)

func open_settings():
	visible = true
	# Pause the entire game while settings is open
	get_tree().paused = true

func close_settings():
	visible = false
	# Unpause the game
	get_tree().paused = false

func _on_resume_pressed():
	close_settings()

func _on_main_menu_pressed():
	# Unpause before switching scene or it stays paused forever
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
