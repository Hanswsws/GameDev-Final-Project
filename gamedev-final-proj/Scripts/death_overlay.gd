extends Control

# ——— Node references ———
@onready var restart_button   = $Panel/VBox/RestartButton
@onready var main_menu_button = $Panel/VBox/MainMenuButton

func _ready():
	restart_button.pressed.connect(_on_restart_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)

func show_death_screen():
	visible = true
	# Pause so enemies stop moving during the screen
	get_tree().paused = true

func _on_restart_pressed():
	get_tree().paused = false
	# Reload the current game scene (restarts the game fresh)
	get_tree().reload_current_scene()

func _on_main_menu_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
