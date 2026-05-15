extends Control

@onready var back_button  = $BackButton
@onready var level1_btn   = $LevelsContainer/Level1Card/VBox/PlayBtn
@onready var level2_btn   = $LevelsContainer/Level2Card/VBox/PlayBtn
@onready var level2_lock  = $LevelsContainer/Level2Card/VBox/ThumbBG/LockIcon
@onready var level2_label = $LevelsContainer/Level2Card/VBox/StatusLabel
@onready var embers       = $Embers
@onready var title_label  = $TitleLabel

var title_pulse_time = 0.0

func _ready():
	back_button.pressed.connect(_on_back_pressed)
	level1_btn.pressed.connect(_on_level1_pressed)
	level2_btn.pressed.connect(_on_level2_pressed)
	_setup_embers()
	_check_unlock_states()

func _setup_embers():
	var mat = ParticleProcessMaterial.new()
	mat.direction = Vector3(0, -1, 0)
	mat.spread = 55.0
	mat.gravity = Vector3(0, -28, 0)
	mat.initial_velocity_min = 20.0
	mat.initial_velocity_max = 55.0
	mat.scale_min = 2.5
	mat.scale_max = 5.0
	mat.color = Color(0.95, 0.22, 0.04, 0.9)
	embers.process_material = mat
	embers.emitting = true

func _check_unlock_states():
	if SaveSystem.is_level2_unlocked():
		level2_btn.disabled = false
		level2_lock.visible = false
		level2_label.text = "UNLOCKED"
		level2_label.modulate = Color(0.15, 0.85, 0.20, 1)
	else:
		level2_btn.disabled = true
		level2_lock.visible = true
		level2_label.text = "Complete Stage 1 to unlock"
		level2_label.modulate = Color(0.55, 0.52, 0.50, 1)

func _process(delta):
	title_pulse_time += delta
	var pulse = sin(title_pulse_time * 1.8) * 0.06 + 0.94
	title_label.modulate = Color(pulse, pulse * 0.09, pulse * 0.09, 1.0)

func _on_back_pressed():
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

func _on_level1_pressed():
	Gamemanager.reset_score()
	Musicmanager.play_battle_music()
	get_tree().change_scene_to_file("res://Scenes/gamemap.tscn")

func _on_level2_pressed():
	if not SaveSystem.is_level2_unlocked():
		return
	Gamemanager.reset_score()
	Musicmanager.play_battle_music()
	get_tree().change_scene_to_file("res://Scenes/gamemap2.tscn")
