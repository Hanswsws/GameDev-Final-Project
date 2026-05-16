extends Control

@onready var restart_button   = $Panel/VBox/RestartButton
@onready var main_menu_button = $Panel/VBox/MainMenuButton
@onready var title_label      = $Panel/VBox/TitleLabel
@onready var subtitle_label   = $Panel/VBox/SubtitleLabel

func _ready():
	restart_button.pressed.connect(_on_restart_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)

func show_death_screen():
	title_label.text     = "YOU DIED"
	subtitle_label.text  = "The arena claims another warrior."
	title_label.modulate = Color(0.9, 0.08, 0.08, 1)
	restart_button.text    = "RESTART GAME"
	restart_button.visible = true
	visible = true
	get_tree().paused = true

func show_win_screen():
	title_label.text     = "STAGE CLEAR!"
	subtitle_label.text  = "You conquered the dungeon. Well done, warrior."
	title_label.modulate = Color(0.15, 0.85, 0.20, 1)
	restart_button.text    = "PLAY AGAIN"
	restart_button.visible = true
	visible = true
	get_tree().paused = true

func show_end_screen():
	title_label.text     = "THE END"
	subtitle_label.text  = "You have conquered Gun Chaos.\nThank you for playing!"
	title_label.modulate = Color(0.9, 0.08, 0.08, 1)
	restart_button.visible     = false
	main_menu_button.text      = "RETURN TO MENU"
	visible = true
	get_tree().paused = true

func _on_restart_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_main_menu_pressed():
	get_tree().paused = false
	Gamemanager.reset_score()
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
